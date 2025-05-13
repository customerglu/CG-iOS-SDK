// Updated AdPopupViewController.swift with proper safe area handling for FULL-DEFAULT

import UIKit
import Lottie

class AdPopupViewController: UIViewController {

    private var entryPointId: String
    private var campaignId: String?
    private var entryPointsData: CGData?
    private var dismissactionglobal = CGDismissAction.UI_BUTTON
    private var cardHeight: CGFloat?
    private var cardBottomMargins: Int = -32
    private let mainView = UIView()
    private let cardView = UIView()
    private let cardBackgroundImageView = UIImageView()
    private let imageView = UIImageView()
    private let primaryCTAButton = UIButton(type: .system)
    private let secondaryCTAButton = UIButton(type: .system)
    private let closeIconView = UIImageView()
    private var videoPlayer = CGVideoPlayer()
    let topSafeAreaView = UIView()
    let bottomSafeAreaView = UIView()

    init(entryPointId: String) {
        self.entryPointId = entryPointId
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEntryPoint()
        setupViews()
        setupLayout()
        applyData()
        registerDismissTap()
        postAnalyticsEvent(type: "WEBVIEW_LOAD")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

       
        let topInset = view.safeAreaInsets.top
        let bottomInset = view.safeAreaInsets.bottom

        if isFullLayout() {
            topSafeAreaView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topInset)
            bottomSafeAreaView.frame = CGRect(x: 0, y: view.bounds.height - bottomInset, width: view.bounds.width, height: bottomInset)
        } else {
            bottomSafeAreaView.frame = CGRect(x: 0, y: view.bounds.height - bottomInset, width: view.bounds.width, height: bottomInset)
        }

        
    }

    private func setupEntryPoint() {
        let jsonData = CGConstants.ad_pop_up_response
        if let data = jsonData.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            entryPointsData = CGData(fromDictionary: json)
        }
    }

    private func isFullLayout() -> Bool {
        return entryPointsData?.mobile.content?.first?.openLayout == "FULL-DEFAULT"
    }

    private func setupViews() {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            view.frame = window.bounds
        }

        view.addSubview(mainView)
        let isDark = CustomerGlu.getInstance.isDarkModeEnabled()

        if isFullLayout() {
            // Add and style top safe area
            view.addSubview(topSafeAreaView)
            view.addSubview(bottomSafeAreaView)

            topSafeAreaView.backgroundColor = isDark ? CustomerGlu.topSafeAreaColorDark : CustomerGlu.topSafeAreaColorLight
            bottomSafeAreaView.backgroundColor = isDark ? CustomerGlu.bottomSafeAreaColorDark : CustomerGlu.bottomSafeAreaColorLight

            // Apply safe area heights immediately
            let topInset = view.safeAreaInsets.top
            let bottomInset = view.safeAreaInsets.bottom
            topSafeAreaView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topInset)
            bottomSafeAreaView.frame = CGRect(x: 0, y: view.bounds.height - bottomInset, width: view.bounds.width, height: bottomInset)
            print("🟠 setupViews — topInset: \(topInset), bottomInset: \(bottomInset)")
               print("🟠 setupViews — topSafeAreaView.frame: \(topSafeAreaView.frame)")
               print("🟠 setupViews — bottomSafeAreaView.frame: \(bottomSafeAreaView.frame)")
           } else {
               view.addSubview(bottomSafeAreaView)

               bottomSafeAreaView.backgroundColor = isDark ? CustomerGlu.bottomSafeAreaColorDark : CustomerGlu.bottomSafeAreaColorLight

               let bottomInset = view.safeAreaInsets.bottom
               bottomSafeAreaView.frame = CGRect(x: 0, y: view.bounds.height - bottomInset, width: view.bounds.width, height: bottomInset)

               print("🟠 setupViews — bottomInset: \(bottomInset)")
               print("🟠 setupViews — bottomSafeAreaView.frame: \(bottomSafeAreaView.frame)")
           }

        mainView.addSubview(cardView)
        cardView.addSubview(cardBackgroundImageView)
        cardView.addSubview(imageView)
        cardView.addSubview(primaryCTAButton)
        cardView.addSubview(secondaryCTAButton)
        cardView.addSubview(closeIconView)
        cardView.addSubview(videoPlayer)
        
        if !isFullLayout() {
            cardView.layer.cornerRadius = 16
            cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white

        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear

        closeIconView.contentMode = .scaleAspectFit
        closeIconView.tintColor = .gray
        closeIconView.isUserInteractionEnabled = true
        cardView.bringSubviewToFront(closeIconView)
        closeIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }

    private func setupLayout() {
        [mainView, cardView, cardBackgroundImageView, imageView, primaryCTAButton, secondaryCTAButton, videoPlayer, closeIconView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let guide = view.safeAreaLayoutGuide
        let screenHeight = UIScreen.main.bounds.height
        let isFull = isFullLayout()
                if isFull {
                    cardHeight = screenHeight
                    cardBottomMargins = 0
                } else {
                    cardHeight = CGFloat(Double(entryPointsData?.mobile.container.height ?? "400") ?? screenHeight * 0.6)
                }
                var constraints: [NSLayoutConstraint] = [
                    mainView.topAnchor.constraint(equalTo: view.topAnchor),
                    mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        
                    cardView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
                    cardView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
        
                    cardBackgroundImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
                    cardBackgroundImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
                    cardBackgroundImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
                    cardBackgroundImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
        
                    imageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
                    imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
                    imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
        
                    videoPlayer.topAnchor.constraint(equalTo: cardView.topAnchor),
                    videoPlayer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
                    videoPlayer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
                    videoPlayer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
        
                    primaryCTAButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
                    primaryCTAButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
                    primaryCTAButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
        
                    secondaryCTAButton.topAnchor.constraint(equalTo: primaryCTAButton.bottomAnchor, constant: 12),
                    secondaryCTAButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
                    secondaryCTAButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
                    secondaryCTAButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
        
                    closeIconView.widthAnchor.constraint(equalToConstant: 32),
                    closeIconView.heightAnchor.constraint(equalToConstant: 32),
                    closeIconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
                    closeIconView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
                ]
        
                if isFull {
                    constraints.append(contentsOf: [
                        cardView.topAnchor.constraint(equalTo: guide.topAnchor),
                        cardView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
                    ])
                } else {
                    constraints.append(contentsOf: [
                        cardView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: CGFloat(cardBottomMargins)),
                        cardView.heightAnchor.constraint(equalToConstant: cardHeight ?? screenHeight)
                    ])
                }
        
                NSLayoutConstraint.activate(constraints)
    }

    private func registerDismissTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        mainView.addGestureRecognizer(tap)
    }

    @objc private func handleDismiss() {
        dismissactionglobal = CGDismissAction.UI_BUTTON
        self.dismiss(animated: true, completion: nil)
    }

    private func postAnalyticsEvent(type: String) {
        guard CustomerGlu.analyticsEvent ?? true else { return }
        let data: [String: Any] = [
            "webview_layout": "Full_NOTIFICATION",
            "campaignId": campaignId ?? "",
            "relative_height": "100",
            "absolute_height": "0",
            "webview_url": ""
        ]
        // CustomerGlu.getInstance.trackEvent(name: type, data: data)
    }

    private func applyData() {
        guard let content = entryPointsData?.mobile?.content.first else { return }

               
               campaignId = content.campaignId
               
               if let opacity = entryPointsData?.mobile?.conditions.backgroundOpacity {
                   
                   let black = UIColor.black
                   let blackTrans = black.withAlphaComponent(CGFloat(opacity))
                   self.view.backgroundColor = blackTrans
               }else{
                   let black = UIColor.black
                   let blackTrans = black.withAlphaComponent(CGFloat(0.5))
                   self.view.backgroundColor = blackTrans
               }


               if let bgColorHex = content.backgroundColor {
                   cardView.backgroundColor = UIColor(hex: bgColorHex)
               }

               if let bgImage = content.backgroundImage {
                   loadImage(from: bgImage, into: cardBackgroundImageView)
               }

               if let type = content.type?.uppercased() {
                   if type == "LOTTIE" {
                       cardBackgroundImageView.isHidden = true
                       print("Lottie starts download")
                       CGFileDownloader.loadFileAsync(url: URL(string: content.url)!) { [weak self] path, error in
                           DispatchQueue.main.async {
                               if(error == nil){
                                   print("Lottie starts downloaded")
                                   
                                   guard let self = self, error == nil, let path = path else { return }
                                   
                               //   let decryptedPath = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: path)
                                   let animationView = LottieAnimationView(filePath: path)
                                         animationView.translatesAutoresizingMaskIntoConstraints = false
                                         animationView.contentMode = .scaleAspectFit
                                         animationView.loopMode = .loop
                                   print("Lottie file path: \(path)")
                                //   print("Lottie dfile path: \(decryptedPath)")
                                   print("File exists: \(FileManager.default.fileExists(atPath: path))")
                                   animationView.isHidden = false
                                   animationView.play()
                                   self.cardView.addSubview(animationView)
                                   self.cardView.sendSubviewToBack(animationView)
                                


                                   // Add constraints
                                   NSLayoutConstraint.activate([
                                       animationView.topAnchor.constraint(equalTo: self.cardView.topAnchor),
                                       animationView.bottomAnchor.constraint(equalTo: self.cardView.bottomAnchor),
                                       animationView.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor),
                                       animationView.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor)
                                   ])
                               }
                           }
                       }
                   } else if type == "VIDEO" {
                       cardBackgroundImageView.isHidden = true
                       videoPlayer.isHidden = false
                       self.cardView.sendSubviewToBack(videoPlayer)

                       print("Video starts downloading")

                       if let videoUrl = URL(string: content.url) {
                           videoPlayer.play(
                               with: videoUrl,
                               behaviour: .autoPlayOnLoad,
                               screenTimeBehaviour: .preventFromIdle
                           )
                               videoPlayer.setVideoShouldLoop(with: entryPointsData?.mobile.conditions.pip?.loopVideoPIP ?? true)
                           if let muteOnDefaultPIP = entryPointsData?.mobile?.conditions?.pip?.muteOnDefaultPIP, muteOnDefaultPIP {
                               videoPlayer.mute()
                           }
                           
                       }
                  
                   } else {
                   }
               }
               if let imageUrl = content.url {
             //      loadImage(from: imageUrl, into: imageView)
               }

               if let closeIcon = content.closeIcon {
                   loadImage(from: closeIcon, into: closeIconView)
               }

               if let btn = content.primaryCta?.button, btn.showButton ?? false {
                   
                   primaryCTAButton.setTitle(btn.buttonText, for: .normal)
                   primaryCTAButton.setTitleColor(UIColor(hex: btn.buttonTextColor ?? "#FFFFFF"), for: .normal)
                   primaryCTAButton.backgroundColor = UIColor(hex: btn.buttonColor ?? "#0000FF")
                   primaryCTAButton.titleLabel?.font = .systemFont(ofSize: CGFloat(Double(btn.textSize ?? "16") ?? 16))
                   primaryCTAButton.layer.cornerRadius = CGFloat(Double(btn.borderRadius ?? "0") ?? 0)
                   if let heightStr = btn.height, let height = Double(heightStr) {
                       primaryCTAButton.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
                      }
               } else {
                   primaryCTAButton.isHidden = true
               }

               if let btn = content.secondaryCta?.button, btn.showButton ?? false  {
                   secondaryCTAButton.setTitle(btn.buttonText, for: .normal)
                   secondaryCTAButton.setTitleColor(UIColor(hex: btn.buttonTextColor ?? "#FFFFFF"), for: .normal)
                   secondaryCTAButton.backgroundColor = UIColor(hex: btn.buttonColor ?? "#0000FF")
                   secondaryCTAButton.titleLabel?.font = .systemFont(ofSize: CGFloat(Double(btn.textSize ?? "16") ?? 16))
                   secondaryCTAButton.layer.cornerRadius = CGFloat(Double(btn.borderRadius ?? "0") ?? 0)
                   if let heightStr = btn.height, let height = Double(heightStr) {
                       secondaryCTAButton.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
                      }
               } else {
                   secondaryCTAButton.isHidden = true
               }
    }

    private func loadImage(from urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = img
                }
            }
        }
    }
}
