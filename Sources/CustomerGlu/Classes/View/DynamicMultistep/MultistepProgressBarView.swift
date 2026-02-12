import UIKit

class MultistepProgressBarView: UIView {

    var stepCompleted: Int = 0
    var activityCount: Int = 1
    var progressBarIcon: String?
    var trackColor: UIColor = UIColor(red: 252/255, green: 238/255, blue: 248/255, alpha: 1)
    var inProgressColor: UIColor = UIColor(red: 253/255, green: 190/255, blue: 229/255, alpha: 1)
    var completedColor: UIColor = UIColor(red: 255/255, green: 0/255, blue: 153/255, alpha: 1)
    var barHeight: CGFloat = 12

    private let trackView = UIView()
    private let inProgressView = UIView()
    private let completedView = UIView()
    private var checkmarkViews: [UIImageView] = []
    private var hasAnimated = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = .clear
        [trackView, inProgressView, completedView].forEach {
            $0.clipsToBounds = true
            addSubview($0)
        }
    }

    func configure(stepCompleted: Int, activityCount: Int, nativeStyle: CGNativeStyle?, progressBarIcon: String?) {
        self.stepCompleted = stepCompleted
        self.activityCount = max(activityCount, 1)
        self.progressBarIcon = progressBarIcon

        if let style = nativeStyle {
            if let tc = style.progressTrackColor { trackColor = UIColor(hex: tc) ?? trackColor }
            if let ip = style.progressInProgressColor { inProgressColor = UIColor(hex: ip) ?? inProgressColor }
            if let fc = style.progressFillColor { completedColor = UIColor(hex: fc) ?? completedColor }
            if let bh = style.progressBarHeight { barHeight = CGFloat(bh) }
        }

        trackView.backgroundColor = trackColor
        inProgressView.backgroundColor = inProgressColor
        completedView.backgroundColor = completedColor

        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        let h = barHeight
        let y = (bounds.height - h) / 2
        let radius = h / 2

        // Track (full width, pill shaped)
        trackView.frame = CGRect(x: 0, y: y, width: w, height: h)
        trackView.layer.cornerRadius = radius

        // In-progress (one step ahead of completed)
        let inProgressFrac = min(CGFloat(stepCompleted + 1) / CGFloat(activityCount), 1.0)
        let inProgressW = stepCompleted == 0 && activityCount > 1 ? min(h, w) : inProgressFrac * w
        inProgressView.frame = CGRect(x: 0, y: y, width: inProgressW, height: h)
        inProgressView.layer.cornerRadius = radius

        // Completed fill
        let completedFrac = CGFloat(stepCompleted) / CGFloat(activityCount)
        let completedW = completedFrac * w
        completedView.frame = CGRect(x: 0, y: y, width: hasAnimated ? completedW : 0, height: h)
        completedView.layer.cornerRadius = radius

        // Animate fill on first layout
        if !hasAnimated {
            hasAnimated = true
            UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.completedView.frame.size.width = completedW
            }
        }

        // Checkmarks at completed positions
        checkmarkViews.forEach { $0.removeFromSuperview() }
        checkmarkViews.removeAll()

        guard stepCompleted > 0 else { return }
        let iconSize: CGFloat = min(h * 0.8, 14)
        for i in 1...min(stepCompleted, activityCount) {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFit
            let xPos = CGFloat(i) / CGFloat(activityCount) * w - iconSize / 2
            iv.frame = CGRect(x: xPos, y: y + (h - iconSize) / 2, width: iconSize, height: iconSize)

            if let iconUrl = progressBarIcon, !iconUrl.isEmpty {
                iv.downloadImage(urlString: iconUrl, success: { _ in }, failure: { _ in })
            } else {
                iv.image = UIImage(systemName: "checkmark")
                iv.tintColor = .white
            }

            addSubview(iv)
            checkmarkViews.append(iv)
        }
    }
}
