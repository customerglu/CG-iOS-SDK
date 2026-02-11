import UIKit

class DynamicMultistepView: UIView {

    private let content: CGContent
    private let banner: CGBanner?
    private let typeId: String

    // For MULTISTEP_3 expand/collapse
    private var isExpanded = false
    private var contentContainer: UIView?

    init(frame: CGRect, content: CGContent, banner: CGBanner?, typeId: String) {
        self.content = content
        self.banner = banner
        self.typeId = typeId
        super.init(frame: frame)
        clipsToBounds = true

        if let bgColor = content.nativeStyle?.backgroundColor {
            backgroundColor = UIColor(hex: bgColor) ?? .white
        } else {
            backgroundColor = .white
        }

        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    private func setupView() {
        switch typeId {
        case "DYNAMIC_MULTISTEP_1": setupMultistep1()
        case "DYNAMIC_MULTISTEP_2": setupMultistep2()
        case "DYNAMIC_MULTISTEP_3": setupMultistep3()
        default: break
        }
    }

    // MARK: - Helpers

    private var stepCompleted: Int { banner?.stepCompleted ?? 0 }
    private var activityCount: Int { banner?.activityCount ?? 1 }

    private func getSelectedWidgetState() -> CGWidgetState? {
        return WidgetStateSelector.select(from: content.widgetStates, banner: banner)
    }

    // MARK: - MULTISTEP_1: Horizontal Progress Bar

    private func setupMultistep1() {
        guard let ws = getSelectedWidgetState() else { return }

        let padding: CGFloat = 16
        var yOffset: CGFloat = 12

        // Title
        if let titleText = ws.title {
            let titleLabel = UILabel(frame: CGRect(x: padding, y: yOffset, width: bounds.width - padding * 2, height: 20))
            titleLabel.text = titleText
            titleLabel.font = UIFont.boldSystemFont(ofSize: content.nativeStyle?.titleFontSize.map { CGFloat($0) } ?? 16)
            titleLabel.textColor = UIColor(hex: content.nativeStyle?.titleColor ?? "#242220") ?? UIColor(red: 36/255, green: 34/255, blue: 32/255, alpha: 1)
            titleLabel.numberOfLines = 0
            titleLabel.sizeToFit()
            titleLabel.frame.size.width = bounds.width - padding * 2
            addSubview(titleLabel)
            yOffset = titleLabel.frame.maxY + 4
        }

        // Body
        if let bodyText = ws.body {
            let bodyLabel = UILabel(frame: CGRect(x: padding, y: yOffset, width: bounds.width - padding * 2, height: 18))
            bodyLabel.text = bodyText
            bodyLabel.font = UIFont.systemFont(ofSize: content.nativeStyle?.bodyFontSize.map { CGFloat($0) } ?? 14)
            bodyLabel.textColor = UIColor(hex: content.nativeStyle?.bodyColor ?? "#242220") ?? UIColor(red: 36/255, green: 34/255, blue: 32/255, alpha: 1)
            bodyLabel.numberOfLines = 0
            bodyLabel.sizeToFit()
            bodyLabel.frame.size.width = bounds.width - padding * 2
            addSubview(bodyLabel)
            yOffset = bodyLabel.frame.maxY + 8
        }

        // Progress bar + reward text
        let rewardText = ws.progressMeter?.completedText
        let rewardWidth: CGFloat = rewardText != nil ? 80 : 0
        let barWidth = bounds.width - padding * 2 - rewardWidth - (rewardText != nil ? 8 : 0)
        let barHeight: CGFloat = content.nativeStyle?.progressBarHeight.map { CGFloat($0) } ?? 16

        let progressBar = MultistepProgressBarView(frame: CGRect(x: padding, y: yOffset, width: barWidth, height: barHeight + 4))
        progressBar.configure(stepCompleted: stepCompleted, activityCount: activityCount, nativeStyle: content.nativeStyle, progressBarIcon: content.progressBarIcon)
        addSubview(progressBar)

        if let rewardText = rewardText {
            let rewardLabel = UILabel(frame: CGRect(x: progressBar.frame.maxX + 8, y: yOffset, width: rewardWidth, height: barHeight + 4))
            rewardLabel.text = rewardText
            rewardLabel.font = UIFont.boldSystemFont(ofSize: 12)
            rewardLabel.textColor = UIColor(hex: content.nativeStyle?.brandColor ?? "#FF0099") ?? UIColor(red: 255/255, green: 0/255, blue: 153/255, alpha: 1)
            rewardLabel.textAlignment = .left
            addSubview(rewardLabel)
        }
    }

    // MARK: - MULTISTEP_2: Vertical Step List

    private func setupMultistep2() {
        guard let ws = getSelectedWidgetState() else { return }

        let padding: CGFloat = 16
        var yOffset: CGFloat = 0

        // Header image
        if let headerImg = ws.headerImage, !headerImg.isEmpty {
            let imageView = UIImageView(frame: CGRect(x: 0, y: yOffset, width: bounds.width, height: 120))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.downloadImage(urlString: headerImg, completion: { _ in }, failure: { _ in })
            addSubview(imageView)
            yOffset = imageView.frame.maxY
        }

        yOffset += 12

        // Title
        if let titleText = ws.title {
            let titleLabel = UILabel(frame: CGRect(x: padding, y: yOffset, width: bounds.width - padding * 2, height: 22))
            titleLabel.text = titleText
            titleLabel.font = UIFont.boldSystemFont(ofSize: content.nativeStyle?.titleFontSize.map { CGFloat($0) } ?? 16)
            titleLabel.textColor = UIColor(hex: content.nativeStyle?.titleColor ?? "#242220") ?? UIColor(red: 36/255, green: 34/255, blue: 32/255, alpha: 1)
            titleLabel.numberOfLines = 0
            titleLabel.sizeToFit()
            titleLabel.frame.size.width = bounds.width - padding * 2
            addSubview(titleLabel)
            yOffset = titleLabel.frame.maxY + 8
        }

        // Progress bar + reward text
        let rewardText = ws.progressMeter?.completedText
        let rewardWidth: CGFloat = rewardText != nil ? 80 : 0
        let barWidth = bounds.width - padding * 2 - rewardWidth - (rewardText != nil ? 8 : 0)
        let barHeight: CGFloat = content.nativeStyle?.progressBarHeight.map { CGFloat($0) } ?? 16

        let progressBar = MultistepProgressBarView(frame: CGRect(x: padding, y: yOffset, width: barWidth, height: barHeight + 4))
        progressBar.configure(stepCompleted: stepCompleted, activityCount: activityCount, nativeStyle: content.nativeStyle, progressBarIcon: content.progressBarIcon)
        addSubview(progressBar)

        if let rewardText = rewardText {
            let rewardLabel = UILabel(frame: CGRect(x: progressBar.frame.maxX + 8, y: yOffset, width: rewardWidth, height: barHeight + 4))
            rewardLabel.text = rewardText
            rewardLabel.font = UIFont.boldSystemFont(ofSize: 12)
            rewardLabel.textColor = UIColor(hex: content.nativeStyle?.brandColor ?? "#FF0099") ?? UIColor(red: 255/255, green: 0/255, blue: 153/255, alpha: 1)
            addSubview(rewardLabel)
        }

        yOffset = progressBar.frame.maxY + 16

        // Step circles row
        let count = activityCount
        let circleSize: CGFloat = content.nativeStyle?.stepIconSize.map { CGFloat($0) } ?? 50
        let connectorGap: CGFloat = 20
        let totalWidth = CGFloat(count) * circleSize + CGFloat(max(count - 1, 0)) * connectorGap
        var xPos = (bounds.width - totalWidth) / 2
        if xPos < padding { xPos = padding }

        let completedColor = UIColor(hex: content.nativeStyle?.completedStepColor ?? "#FF0099") ?? UIColor(red: 255/255, green: 0/255, blue: 153/255, alpha: 1)
        let currentColor = UIColor(hex: content.nativeStyle?.currentStepColor ?? "#FF0099") ?? UIColor(red: 255/255, green: 0/255, blue: 153/255, alpha: 1)
        let lockedColor = UIColor(hex: content.nativeStyle?.lockedStepColor ?? "#999999") ?? UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        let connectorHeight: CGFloat = 4

        for step in 0..<count {
            let circleView = UIView(frame: CGRect(x: xPos, y: yOffset, width: circleSize, height: circleSize))
            circleView.layer.cornerRadius = circleSize / 2
            circleView.clipsToBounds = true

            if step < stepCompleted {
                circleView.backgroundColor = completedColor
                let checkIcon = UIImageView(frame: CGRect(x: circleSize * 0.25, y: circleSize * 0.25, width: circleSize * 0.5, height: circleSize * 0.5))
                checkIcon.image = UIImage(systemName: "checkmark")
                checkIcon.tintColor = .white
                checkIcon.contentMode = .scaleAspectFit
                circleView.addSubview(checkIcon)
            } else if step == stepCompleted {
                circleView.backgroundColor = .white
                circleView.layer.borderColor = currentColor.cgColor
                circleView.layer.borderWidth = 2
            } else {
                circleView.backgroundColor = .white
                circleView.layer.borderColor = lockedColor.cgColor
                circleView.layer.borderWidth = 1.5
            }

            // Reward text inside circle for non-completed steps
            if step >= stepCompleted {
                if let pb = ws.progressBar, let rewardTxt = pb.progressRewardText {
                    let rewardLbl = UILabel(frame: circleView.bounds)
                    rewardLbl.text = rewardTxt
                    rewardLbl.font = UIFont.boldSystemFont(ofSize: 10)
                    rewardLbl.textAlignment = .center
                    rewardLbl.textColor = step == stepCompleted ? currentColor : lockedColor
                    circleView.addSubview(rewardLbl)
                }
            }

            addSubview(circleView)

            // Label below circle
            let labelY = yOffset + circleSize + 4
            let label = UILabel(frame: CGRect(x: xPos - 10, y: labelY, width: circleSize + 20, height: 16))
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = .center
            label.textColor = step < stepCompleted ? UIColor(hex: "#242220") : UIColor(hex: "#757575")
            if let pb = ws.progressBar, let plabel = pb.progressLabel {
                label.text = plabel
            }
            addSubview(label)

            xPos += circleSize

            // Connector
            if step < count - 1 {
                let connector = UIView(frame: CGRect(x: xPos, y: yOffset + circleSize / 2 - connectorHeight / 2, width: connectorGap, height: connectorHeight))
                connector.backgroundColor = step < stepCompleted ? completedColor : UIColor(hex: "#E0E0E0")
                connector.layer.cornerRadius = connectorHeight / 2
                addSubview(connector)
                xPos += connectorGap
            }
        }

        yOffset += circleSize + 24 + 16

        // CTA Button
        if let ctaText = ws.ctaText, !ctaText.isEmpty {
            let ctaButton = UIButton(frame: CGRect(x: padding, y: yOffset, width: bounds.width - padding * 2, height: 44))
            ctaButton.setTitle(ctaText, for: .normal)
            ctaButton.setTitleColor(UIColor(hex: content.nativeStyle?.ctaTextColor ?? "#FFFFFF") ?? .white, for: .normal)
            ctaButton.backgroundColor = UIColor(hex: content.nativeStyle?.ctaBackgroundColor ?? "#4F4DF8") ?? UIColor(red: 79/255, green: 77/255, blue: 248/255, alpha: 1)
            ctaButton.layer.cornerRadius = content.nativeStyle?.cornerRadius.map { CGFloat($0) } ?? 8
            ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            addSubview(ctaButton)
        }
    }

    // MARK: - MULTISTEP_3: Expandable Card

    private func setupMultistep3() {
        guard let ws = getSelectedWidgetState() else { return }

        let padding: CGFloat = 16
        let headerHeight: CGFloat = 56

        // Header container
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: headerHeight))
        headerView.backgroundColor = .white
        addSubview(headerView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleExpand))
        headerView.addGestureRecognizer(tapGesture)

        // Badge
        var badgeEndX: CGFloat = padding
        if let badgeText = ws.badgeTag, !badgeText.isEmpty {
            let badgeLabel = UILabel()
            badgeLabel.text = badgeText
            badgeLabel.font = UIFont.boldSystemFont(ofSize: content.nativeStyle?.badgeFontSize.map { CGFloat($0) } ?? 11)
            badgeLabel.textColor = UIColor(hex: "#E00087")
            badgeLabel.sizeToFit()
            let badgeW = badgeLabel.frame.width + 16
            let badgeH: CGFloat = 24
            let badgeContainer = UIView(frame: CGRect(x: padding, y: (headerHeight - badgeH) / 2, width: badgeW, height: badgeH))
            badgeContainer.backgroundColor = UIColor(hex: "#FCEEF8")
            badgeContainer.layer.cornerRadius = badgeH / 2
            badgeContainer.layer.borderColor = UIColor(hex: "#E00087")?.cgColor
            badgeContainer.layer.borderWidth = 1
            badgeLabel.frame = CGRect(x: 8, y: (badgeH - badgeLabel.frame.height) / 2, width: badgeLabel.frame.width, height: badgeLabel.frame.height)
            badgeContainer.addSubview(badgeLabel)
            headerView.addSubview(badgeContainer)
            badgeEndX = badgeContainer.frame.maxX + 8
        }

        // Title in header
        let chevronSize: CGFloat = 20
        if let titleText = ws.title {
            let titleLabel = UILabel(frame: CGRect(x: badgeEndX, y: 0, width: bounds.width - badgeEndX - chevronSize - padding * 2, height: headerHeight))
            titleLabel.text = titleText
            titleLabel.font = UIFont.boldSystemFont(ofSize: content.nativeStyle?.titleFontSize.map { CGFloat($0) } ?? 16)
            titleLabel.textColor = UIColor(hex: content.nativeStyle?.titleColor ?? "#242220") ?? UIColor(red: 36/255, green: 34/255, blue: 32/255, alpha: 1)
            titleLabel.numberOfLines = 1
            headerView.addSubview(titleLabel)
        }

        // Chevron
        let chevronImageView = UIImageView(frame: CGRect(x: bounds.width - padding - chevronSize, y: (headerHeight - chevronSize) / 2, width: chevronSize, height: chevronSize))
        chevronImageView.image = UIImage(systemName: "chevron.down")
        chevronImageView.tintColor = UIColor(hex: "#757575")
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.tag = 999
        headerView.addSubview(chevronImageView)

        // Content container (starts collapsed)
        let container = UIView(frame: CGRect(x: 0, y: headerHeight, width: bounds.width, height: 0))
        container.clipsToBounds = true
        addSubview(container)
        self.contentContainer = container

        // Build content inside container
        var yOffset: CGFloat = 8

        // Step circles (smaller, 24x24)
        let count = activityCount
        let circleSize: CGFloat = content.nativeStyle?.stepIconSize.map { CGFloat($0) } ?? 24
        let connectorWidth: CGFloat = 20
        let totalWidth = CGFloat(count) * circleSize + CGFloat(max(count - 1, 0)) * connectorWidth
        var xPos = (bounds.width - totalWidth) / 2
        if xPos < padding { xPos = padding }

        let completedColor = UIColor(hex: content.nativeStyle?.completedStepColor ?? "#FF0099") ?? UIColor(red: 255/255, green: 0/255, blue: 153/255, alpha: 1)
        let currentColor = UIColor(hex: content.nativeStyle?.currentStepColor ?? "#FF0099") ?? UIColor(red: 255/255, green: 0/255, blue: 153/255, alpha: 1)
        let lockedColor = UIColor(hex: content.nativeStyle?.lockedStepColor ?? "#999999") ?? UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)

        for step in 0..<count {
            let circleView = UIView(frame: CGRect(x: xPos, y: yOffset, width: circleSize, height: circleSize))
            circleView.layer.cornerRadius = circleSize / 2
            circleView.clipsToBounds = true

            if step < stepCompleted {
                circleView.backgroundColor = completedColor
                let iconSize = circleSize * 0.5
                let checkIcon = UIImageView(frame: CGRect(x: (circleSize - iconSize) / 2, y: (circleSize - iconSize) / 2, width: iconSize, height: iconSize))
                if let iconUrl = content.progressBarIcon, !iconUrl.isEmpty {
                    checkIcon.downloadImage(urlString: iconUrl, completion: { _ in }, failure: { _ in })
                } else {
                    checkIcon.image = UIImage(systemName: "checkmark")
                    checkIcon.tintColor = .white
                }
                checkIcon.contentMode = .scaleAspectFit
                circleView.addSubview(checkIcon)
            } else if step == stepCompleted {
                circleView.backgroundColor = .white
                circleView.layer.borderColor = currentColor.cgColor
                circleView.layer.borderWidth = 2
            } else {
                circleView.backgroundColor = .white
                circleView.layer.borderColor = lockedColor.cgColor
                circleView.layer.borderWidth = 1.5
            }

            container.addSubview(circleView)
            xPos += circleSize

            // Dashed connector
            if step < count - 1 {
                let connectorView = UIView(frame: CGRect(x: xPos, y: yOffset + circleSize / 2 - 2, width: connectorWidth, height: 4))
                let shapeLayer = CAShapeLayer()
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: 2))
                path.addLine(to: CGPoint(x: connectorWidth, y: 2))
                shapeLayer.path = path.cgPath
                shapeLayer.strokeColor = (step < stepCompleted ? completedColor : lockedColor).cgColor
                shapeLayer.lineWidth = 2
                shapeLayer.lineDashPattern = [4, 4]
                connectorView.layer.addSublayer(shapeLayer)
                container.addSubview(connectorView)
                xPos += connectorWidth
            }
        }

        yOffset += circleSize + 12

        // Description
        if let bodyText = ws.body {
            let bodyLabel = UILabel(frame: CGRect(x: padding, y: yOffset, width: bounds.width - padding * 2, height: 40))
            bodyLabel.text = bodyText
            bodyLabel.font = UIFont.systemFont(ofSize: content.nativeStyle?.bodyFontSize.map { CGFloat($0) } ?? 14)
            bodyLabel.textColor = UIColor(hex: content.nativeStyle?.bodyColor ?? "#242220") ?? UIColor(red: 36/255, green: 34/255, blue: 32/255, alpha: 1)
            bodyLabel.numberOfLines = 0
            bodyLabel.sizeToFit()
            bodyLabel.frame.size.width = bounds.width - padding * 2
            container.addSubview(bodyLabel)
            yOffset = bodyLabel.frame.maxY + 12
        }

        // CTA Button with shine
        if let ctaText = ws.ctaText, !ctaText.isEmpty {
            let ctaButton = UIButton(frame: CGRect(x: padding, y: yOffset, width: bounds.width - padding * 2, height: 44))
            ctaButton.setTitle(ctaText, for: .normal)
            ctaButton.setTitleColor(UIColor(hex: content.nativeStyle?.ctaTextColor ?? "#FFFFFF") ?? .white, for: .normal)
            ctaButton.backgroundColor = UIColor(hex: content.nativeStyle?.ctaBackgroundColor ?? "#E00087") ?? UIColor(red: 224/255, green: 0/255, blue: 135/255, alpha: 1)
            ctaButton.layer.cornerRadius = content.nativeStyle?.cornerRadius.map { CGFloat($0) } ?? 8
            ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            ctaButton.clipsToBounds = true
            container.addSubview(ctaButton)

            // Shine animation
            addShineAnimation(to: ctaButton)

            yOffset = ctaButton.frame.maxY + 12
        }

        // Store total content height
        container.tag = Int(yOffset)
    }

    @objc private func toggleExpand() {
        guard let container = contentContainer else { return }
        isExpanded.toggle()

        let targetHeight: CGFloat = isExpanded ? CGFloat(container.tag) : 0

        // Update chevron
        if let headerView = subviews.first,
           let chevron = headerView.viewWithTag(999) as? UIImageView {
            chevron.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
        }

        UIView.animate(withDuration: 0.3) {
            container.frame.size.height = targetHeight
        }
    }

    private func addShineAnimation(to button: UIButton) {
        let shine = CAGradientLayer()
        shine.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.4).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        shine.locations = [0, 0.5, 1]
        shine.startPoint = CGPoint(x: 0, y: 0.5)
        shine.endPoint = CGPoint(x: 1, y: 0.5)
        shine.frame = CGRect(x: -button.bounds.width, y: 0, width: button.bounds.width * 0.5, height: button.bounds.height)
        button.layer.addSublayer(shine)

        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = -button.bounds.width * 0.25
        animation.toValue = button.bounds.width * 1.25
        animation.duration = 2.0
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shine.add(animation, forKey: "shineAnimation")
    }
}
