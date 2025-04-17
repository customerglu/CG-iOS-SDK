import Foundation

@objc(SSEClient)
final class SSEClient: NSObject, URLSessionDataDelegate {
    
    static let shared = SSEClient()
    
    private var task: URLSessionDataTask?
    private var session: URLSession!
    public var isConnected = false
    private var retryDelay: TimeInterval = 1
    private let maxRetryDelay: TimeInterval = 30
    private var retryCount = 0
    private let maxRetries = 5
    public var shouldReconnect = true
    private var eventBuffer = ""
    
    private var disconnectTimer: Timer?
    private var reconnectTimer: Timer?
    private var onMessageReceived: ((String) -> Void)?
    
    private override init() {
        super.init()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = .infinity
        config.timeoutIntervalForResource = .infinity
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    @objc func startSSE(urlString: String, onMessage: @escaping (String) -> Void) {
        guard !isConnected, let url = URL(string: urlString), retryCount < maxRetries, shouldReconnect else {
            print("[SSEClient] Max retries reached or shouldReconnect is false")
            return
        }

        print("[SSEClient] Starting SSE connection")

        self.onMessageReceived = onMessage
        eventBuffer = ""

        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.timeoutInterval = .infinity

        task = session.dataTask(with: request)
        task?.resume()
    }
    
    @objc func stopSSE() {
        print("[SSEClient] Stopping SSE...")
        isConnected = false
        retryDelay = 1
        retryCount = 0
        shouldReconnect = false
        reconnectTimer?.invalidate()
        disconnectTimer?.invalidate()
        task?.cancel()
        eventBuffer = ""
        print("[SSEClient] SSE connection stopped")
    }
    
    @objc  private func scheduleReconnect(url: String) {
        guard !isConnected, shouldReconnect, retryCount < maxRetries else {
            print("[SSEClient] Max retries reached or reconnect disabled.")
            return
        }

        retryCount += 1
        retryDelay = min(retryDelay * 2, maxRetryDelay)
        
        print("[SSEClient] Retrying SSE connection in \(Int(retryDelay * 1000)) ms...")

        reconnectTimer?.invalidate()
        DispatchQueue.main.async {
               self.reconnectTimer = Timer.scheduledTimer(withTimeInterval: self.retryDelay, repeats: false) { [weak self] _ in
                   print("[SSEClient] 🔁 Retrying now...")
                   self?.startSSE(urlString: url, onMessage: self?.onMessageReceived ?? { _ in })
               }
           }
    
    }
    
    // MARK: - URLSession Delegate
    
    @objc func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let chunk = String(data: data, encoding: .utf8) else { return }

        if !isConnected {
            isConnected = true
            retryCount = 0
            retryDelay = 1
            print("[SSEClient] ✅ SSE Connected")

            DispatchQueue.main.async {
                self.disconnectTimer?.invalidate()
                self.disconnectTimer = Timer.scheduledTimer(withTimeInterval: 600, repeats: false) { [weak self] _ in
                    print("[SSEClient] Auto-disconnect triggered after 1 minute")
                    self?.stopSSE()
                }
            }
        }

        eventBuffer += chunk
        
        let lines = eventBuffer.components(separatedBy: "\n")
        var eventLines = [String]()
        
        for line in lines {
            if line.isEmpty {
                let eventData = parseEventData(from: eventLines)
                if let message = eventData {
                    DispatchQueue.main.async {
                        self.onMessageReceived?(message)
                    }
                }
                eventLines.removeAll()
            } else {
                eventLines.append(line)
            }
        }

        eventBuffer = eventLines.joined(separator: "\n")
    }
    
    @objc func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        isConnected = false
        print("[SSEClient] Connection error: \(error?.localizedDescription ?? "unknown error")")
        
        if let url = task.originalRequest?.url?.absoluteString {
            scheduleReconnect(url: url)
        }
    }
    
    @objc private func parseEventData(from lines: [String]) -> String? {
        let dataLines = lines
            .filter { $0.hasPrefix("data:") }
            .map { $0.dropFirst(5).trimmingCharacters(in: .whitespaces) }
        
        let result = dataLines.joined(separator: "\n")
        return result.isEmpty ? nil : result
    }
}
