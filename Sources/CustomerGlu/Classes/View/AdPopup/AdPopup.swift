import UIKit
import Lottie

class AdPopupViewController: UIViewController {
    
    private var entryPointId: String
    private var campaignId: String?
    private var cardHeight: CGFloat?
    private var cardBottomMargins: Int = -32
    private var entryPointsData: CGData?
    private var dismissactionglobal = CGDismissAction.UI_BUTTON
    
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayer.cleanUp()
        if isBeingDismissed {
            postAnalyticsEvent(type: "WEBVIEW_DISMISS")
        }
    }

    private func setupEntryPoint() {
        let jsonData = CGConstants.ad_pop_up_response
        if let data = jsonData.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            entryPointsData = CGData(fromDictionary: json)
        }
    }

//    private func setupViews() {
//        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
//            view.frame = window.bounds
//        }
//
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//
//        cardView.layer.cornerRadius = 16
//        cardView.clipsToBounds = true
//        cardView.backgroundColor = .white
//
//        cardBackgroundImageView.contentMode = .scaleAspectFill
//        cardBackgroundImageView.clipsToBounds = true
//
//        imageView.contentMode = .scaleAspectFit
//        imageView.backgroundColor = .clear
//
//        closeIconView.contentMode = .scaleAspectFit
//        closeIconView.tintColor = .gray
//        closeIconView.isUserInteractionEnabled = true
//        closeIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
//
//        view.addSubview(mainView)
//        view.addSubview(topSafeAreaView)
//        view.addSubview(bottomSafeAreaView)
//        mainView.addSubview(cardView)
//        cardView.addSubview(cardBackgroundImageView)
//        cardView.addSubview(imageView)
//        cardView.addSubview(primaryCTAButton)
//        cardView.addSubview(secondaryCTAButton)
//        cardView.addSubview(closeIconView)
//        cardView.addSubview(videoPlayer)
//        self.cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.ignoreTap)))
//
//    }
    
    private func setupViews() {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            view.frame = window.bounds
        }

        // Setup top/bottom safe area overlays
//        topSafeAreaView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        bottomSafeAreaView.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        view.addSubview(mainView)
        view.addSubview(topSafeAreaView)
        view.addSubview(bottomSafeAreaView)

        mainView.addSubview(cardView)
        cardView.addSubview(cardBackgroundImageView)
        cardView.addSubview(imageView)
        cardView.addSubview(primaryCTAButton)
        cardView.addSubview(secondaryCTAButton)
        cardView.addSubview(closeIconView)
        cardView.addSubview(videoPlayer)

        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white

        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear

        closeIconView.contentMode = .scaleAspectFit
        closeIconView.tintColor = .gray
        closeIconView.isUserInteractionEnabled = true
        closeIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
     
    
    }

//    private func setupLayout() {
//        [mainView, cardView, cardBackgroundImageView, imageView, primaryCTAButton, secondaryCTAButton,videoPlayer, closeIconView].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//        }
//        topSafeAreaView.translatesAutoresizingMaskIntoConstraints = false
//        bottomSafeAreaView.translatesAutoresizingMaskIntoConstraints = false
//        let screenHeight = UIScreen.main.bounds.height
//        
//            
//        if entryPointsData?.mobile.content?.first?.openLayout == "FULL-DEFAULT" {
//            cardHeight = screenHeight
//            cardBottomMargins = 0
//
//        }else{
//             cardHeight = CGFloat(Double(entryPointsData?.mobile.container.height ?? "400") ?? screenHeight * 0.6)
//        }
//        NSLayoutConstraint.activate([
//            mainView.topAnchor.constraint(equalTo: view.topAnchor),
//            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            
//            topSafeAreaView.topAnchor.constraint(equalTo: view.topAnchor),
//            topSafeAreaView.leftAnchor.constraint(equalTo: view.leftAnchor),
//            topSafeAreaView.rightAnchor.constraint(equalTo: view.rightAnchor),
//            topSafeAreaView.heightAnchor.constraint(equalToConstant: UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20),
//            
//            bottomSafeAreaView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            bottomSafeAreaView.leftAnchor.constraint(equalTo: view.leftAnchor),
//            bottomSafeAreaView.rightAnchor.constraint(equalTo: view.rightAnchor),
//            bottomSafeAreaView.heightAnchor.constraint(equalToConstant: UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0),
//
//            cardView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
//            cardView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
//            
//            cardView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: CGFloat(cardBottomMargins)),
//            cardView.heightAnchor.constraint(equalToConstant: cardHeight ?? screenHeight),
//
//            cardBackgroundImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
//            cardBackgroundImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
//            cardBackgroundImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
//            cardBackgroundImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
//
//            
//            imageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
//            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
//            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
//
//            videoPlayer.topAnchor.constraint(equalTo: cardView.topAnchor),
//                videoPlayer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
//                videoPlayer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
//                videoPlayer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
//            
//            primaryCTAButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
//            primaryCTAButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
//            primaryCTAButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
//       //     primaryCTAButton.heightAnchor.constraint(equalToConstant: 40),
//
//            secondaryCTAButton.topAnchor.constraint(equalTo: primaryCTAButton.bottomAnchor, constant: 12),
//            secondaryCTAButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
//            secondaryCTAButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
//            secondaryCTAButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
//        //    secondaryCTAButton.heightAnchor.constraint(equalToConstant: 40),
//
//            closeIconView.widthAnchor.constraint(equalToConstant: 32),
//            closeIconView.heightAnchor.constraint(equalToConstant: 32),
//            closeIconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
//            closeIconView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
//        ])
//    }
    
    private func setupLayout() {
        [mainView, cardView, cardBackgroundImageView, imageView, primaryCTAButton, secondaryCTAButton, videoPlayer, closeIconView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let guide = view.safeAreaLayoutGuide
        let isFullLayout = entryPointsData?.mobile.content?.first?.openLayout == "FULL-DEFAULT"

        NSLayoutConstraint.activate([
            // Main view fills the entire screen
            mainView.topAnchor.constraint(equalTo: view.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Card view respects safe area top and bottom if FULL-DEFAULT
            cardView.topAnchor.constraint(equalTo: guide.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            cardView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),

            // Background image fills card
            cardBackgroundImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            cardBackgroundImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            cardBackgroundImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cardBackgroundImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),

            // Image view placement
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            // Video player fills card
            videoPlayer.topAnchor.constraint(equalTo: cardView.topAnchor),
            videoPlayer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            videoPlayer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            videoPlayer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),

            // Primary CTA
            primaryCTAButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            primaryCTAButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            primaryCTAButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            // Secondary CTA
            secondaryCTAButton.topAnchor.constraint(equalTo: primaryCTAButton.bottomAnchor, constant: 12),
            secondaryCTAButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            secondaryCTAButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            secondaryCTAButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20), // key fix

            // Close icon
            closeIconView.widthAnchor.constraint(equalToConstant: 32),
            closeIconView.heightAnchor.constraint(equalToConstant: 32),
            closeIconView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16), // respect top safe area
            closeIconView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let topInset = view.safeAreaInsets.top
        let bottomInset = view.safeAreaInsets.bottom

        print("✅ Top Safe Area Height: \(topInset)")
        print("✅ Bottom Safe Area Height: \(bottomInset)")
        
        
        let topHeight = topSafeAreaView.frame.height
        let bottomHeight = bottomSafeAreaView.frame.height

        print("✅ TopSafeAreaView height: \(topHeight)")
        print("✅ BottomSafeAreaView height: \(bottomHeight)")
        
        let isDark = CustomerGlu.getInstance.isDarkModeEnabled()
         topSafeAreaView.backgroundColor = isDark ? CustomerGlu.topSafeAreaColorDark : CustomerGlu.topSafeAreaColorLight
         bottomSafeAreaView.backgroundColor = isDark ? CustomerGlu.bottomSafeAreaColorDark : CustomerGlu.bottomSafeAreaColorLight
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
    @objc private func ignoreTap() {
        // Intentionally empty to consume the tap and prevent dismissal
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
}
