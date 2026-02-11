import UIKit

/// Main container view that renders DYNAMIC_MULTISTEP_1, _2, or _3 based on typeId.
/// Programmatic UIKit — no storyboards/xibs.
class DynamicMultistepView: UIView {

    // MARK: - Properties
    private let content: CGContent
    private let banner: CGBanner?
    private let typeId: String

    // Derived data
    private var stepCompleted: Int = 0
    private var activityCount: Int = 1
    private var userStatus: String = "pristine"
    private var selectedWidgetState: CGWidgetState?
    private var nativeStyle: CGNativeStyle?

    // MARK: - Init
    init(frame: CGRect, content: CGContent, banner: CGBanner?, typeId: String) {
        self.content = content
        self.banner = banner
        self.typeId = typeId
        super.init(frame: frame)

        self.nativeStyle = content.nativeStyle
        self.stepCompleted = banner?.stepCompleted ?? 0
        self.activityCount = max(banner?.activityCount ?? 1, 1)
        self.userStatus = banner?.userCampaignStatus ?? "pristine"

        selectWidgetState()
        buildLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    // MARK: - Widget State Selection (matches JS-UI-SDK exactly)
    private func selectWidgetState() {
        guard let states = content.widgetStates, !states.isEmpty else { return }

        if userStatus == "completed" {
            selectedWidgetState = states.first(where: { $0.state == "completed" })
        } else {
            selectedWidgetState = states.first(where: { $0.step == stepCompleted && $0.state == userStatus })
            if selectedWidgetState == nil {
                selectedWidgetState = states.first(where: { $0.step == stepCompleted && $0.state == "in-progress" })
            }
        }
        if selectedWidgetState == nil {
            selectedWidgetState = states.first
        }
    }

    // MARK: - Layout Builder
    private func buildLayout() {
        backgroundColor = .clear
        if typeId.hasSuffix("_1") || typeId == "DYNAMIC_MULTISTEP_1" {
            buildMultistep1()
        } else if typeId.hasSuffix("_2") || typeId == "DYNAMIC_MULTISTEP_2" {
            buildMultistep2()
        } else if typeId.hasSuffix("_3") || typeId == "DYNAMIC_MULTISTEP_3" {
            buildMultistep3()
        }
    }

    // MARK: - Style Helpers
    private var brandColor: UIColor { UIColor(hex: nativeStyle?.brandColor ?? "#FF0099") }
    private var bgColor: UIColor { UIColor(hex: nativeStyle?.backgroundColor ?? "#FFFFFF") }
    private var titleColorVal: UIColor { UIColor(hex: nativeStyle?.titleColor ?? "#242220") }
    private var bodyColorVal: UIColor { UIColor(hex: nativeStyle?.bodyColor ?? "#242220") }
    private var ctaBgColor: UIColor { UIColor(hex: nativeStyle?.ctaBackgroundColor ?? "#4F4DF8") }
    private var ctaTextColorVal: UIColor { UIColor(hex: nativeStyle?.ctaTextColor ?? "#FFFFFF") }
    private var trackColor: UIColor { UIColor(hex: nativeStyle?.progressTrackColor ?? "#FCEEF8") }
    private var fillColor: UIColor { UIColor(hex: nativeStyle?.progressFillColor ?? "#FF0099") }
    private var inProgressColorVal: UIColor { UIColor(hex: nativeStyle?.progressInProgressColor ?? "#FDBEE5") }
    private var cornerRadiusVal: CGFloat { CGFloat(nativeStyle?.cornerRadius ?? 0) }
    private var barHeight: CGFloat { CGFloat(nativeStyle?.progressBarHeight ?? 16) }
    private var titleFontSize: CGFloat { CGFloat(nativeStyle?.titleFontSize ?? 16) }
    private var bodyFontSize: CGFloat { CGFloat(nativeStyle?.bodyFontSize ?? 14) }

    // MARK: - Title/body from widget state or content state
    private var resolvedTitle: String {
        if let t = selectedWidgetState?.title, !t.isEmpty { return t }
        return contentStateItem?.title ?? ""
    }

    private var resolvedBody: String {
        if let b = selectedWidgetState?.body, !b.isEmpty { return b }
        return contentStateItem?.body ?? ""
    }

    private var contentStateItem: CGContentStateItem? {
        guard let cs = content.contentState else { return nil }
        switch userStatus {
        case "completed": return cs.completed
        case "in-progress": return cs.inProgress
        case "in-progress-daycompleted": return cs.inProgressDayCompleted
        case "pristine": return cs.pristine
        default: return cs.inProgress
        }
    }

    // MARK: - MULTISTEP_1
    private func buildMultistep1() {
        let container = UIView(frame: bounds)
        container.backgroundColor = bgColor
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(container)

        let padding: CGFloat = 16

        // Title
        let titleLabel = UILabel()
        titleLabel.text = resolvedTitle
        titleLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .semibold)
        titleLabel.textColor = titleColorVal
        titleLabel.numberOfLines = 0

        // Body
        let bodyLabel = UILabel()
        bodyLabel.text = resolvedBody
        bodyLabel.font = UIFont.systemFont(ofSize: bodyFontSize, weight: .regular)
        bodyLabel.textColor = bodyColorVal
        bodyLabel.numberOfLines = 0

        // Progress bar
        let progressBar = MultistepProgressBar()
        progressBar.stepCompleted = stepCompleted
        progressBar.activityCount = activityCount
        progressBar.progressMeterIconURL = content.progressMeterIcon
        progressBar.rewardText = selectedWidgetState?.progressMeter?.completedText
        progressBar.trackColor = trackColor
        progressBar.inProgressColor = inProgressColorVal
        progressBar.completedColor = fillColor
        progressBar.rewardTextColor = brandColor
        progressBar.barHeight = barHeight

        // Right arrow icon
        let arrowView = UIImageView()
        arrowView.contentMode = .scaleAspectFit
        arrowView.tintColor = UIColor(hex: "#242220")
        if #available(iOS 13.0, *) {
            arrowView.image = UIImage(systemName: "chevron.right")
        }

        // Layout manually
        let arrowSize: CGFloat = 24
        let arrowX = bounds.width - padding - arrowSize
        let contentWidth = arrowX - padding * 2

        titleLabel.frame = CGRect(x: padding, y: padding, width: contentWidth, height: 0)
        titleLabel.sizeToFit()
        titleLabel.frame.size.width = contentWidth

        bodyLabel.frame = CGRect(x: padding, y: titleLabel.frame.maxY + 4, width: contentWidth, height: 0)
        bodyLabel.sizeToFit()
        bodyLabel.frame.size.width = contentWidth

        progressBar.frame = CGRect(x: padding, y: bodyLabel.frame.maxY + 12, width: bounds.width - padding * 2, height: barHeight)

        arrowView.frame = CGRect(x: arrowX, y: (bounds.height - arrowSize) / 2, width: arrowSize, height: arrowSize)

        container.addSubview(titleLabel)
        container.addSubview(bodyLabel)
        container.addSubview(progressBar)
        container.addSubview(arrowView)
    }

    // MARK: - MULTISTEP_2
    private func buildMultistep2() {
        let container = UIView(frame: bounds)
        container.backgroundColor = UIColor(hex: nativeStyle?.backgroundColor ?? "#F4F4F4")
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(container)

        let cardView = UIView()
        cardView.backgroundColor = bgColor
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true

        let padding: CGFloat = 16
        let cardInset: CGFloat = 16
        let cardWidth = bounds.width - cardInset * 2
        var yOffset: CGFloat = 0

        // Header image
        let headerImageView = UIImageView()
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        let imageHeight = cardWidth * 0.4 // aspect ratio estimate
        headerImageView.frame = CGRect(x: 0, y: 0, width: cardWidth, height: imageHeight)

        if let imgURL = selectedWidgetState?.headerImage, !imgURL.isEmpty {
            headerImageView.downloadImage(urlString: imgURL, success: nil, failure: nil)
        }
        cardView.addSubview(headerImageView)
        yOffset = imageHeight + padding

        // Title
        let titleLabel = UILabel()
        titleLabel.text = resolvedTitle
        titleLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .semibold)
        titleLabel.textColor = titleColorVal
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.frame = CGRect(x: padding, y: yOffset, width: cardWidth - padding * 2, height: 0)
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: padding, y: yOffset, width: cardWidth - padding * 2, height: titleLabel.frame.height)
        cardView.addSubview(titleLabel)
        yOffset = titleLabel.frame.maxY + 24

        // Progress bar with reward text
        let progressBar = MultistepProgressBar()
        progressBar.stepCompleted = stepCompleted
        progressBar.activityCount = activityCount
        progressBar.progressMeterIconURL = content.progressMeterIcon
        progressBar.rewardText = selectedWidgetState?.progressMeter?.completedText
        progressBar.trackColor = trackColor
        progressBar.inProgressColor = inProgressColorVal
        progressBar.completedColor = fillColor
        progressBar.rewardTextColor = brandColor
        progressBar.barHeight = barHeight
        progressBar.frame = CGRect(x: padding, y: yOffset, width: cardWidth - padding * 2, height: barHeight)
        cardView.addSubview(progressBar)
        yOffset = progressBar.frame.maxY + 24

        // Step circles
        let stepCircles = MultistepStepCircles()
        stepCircles.connectorStyle = .solid
        stepCircles.brandColor = brandColor
        stepCircles.stepCompleted = stepCompleted
        stepCircles.activityCount = activityCount

        var stepData: [MultistepStepCircles.StepData] = []
        if let ws = content.widgetStates {
            for i in 0..<activityCount {
                // Find widget state for this step
                let widget = ws.first(where: { $0.step == i && $0.state == userStatus })
                    ?? ws.first(where: { $0.step == i && $0.state == "in-progress" })
                    ?? ws.first(where: { $0.step == 0 && $0.state == "pristine" })
                    ?? ws.first
                let rewardText = widget?.progressBar?.progressRewardText ?? ""
                let label = widget?.progressBar?.progressLabel ?? "Step \(i + 1)"
                stepData.append(.init(rewardText: rewardText, label: label))
            }
        }
        stepCircles.steps = stepData
        let circlesPadding: CGFloat = 8
        let circlesWidth = cardWidth - padding - circlesPadding
        let circlesHeight: CGFloat = 78 // 50 circle + 8 gap + 20 label
        stepCircles.frame = CGRect(x: circlesPadding, y: yOffset, width: circlesWidth, height: circlesHeight)
        stepCircles.reload()
        cardView.addSubview(stepCircles)
        yOffset = stepCircles.frame.maxY + 24

        // CTA Button
        let ctaButton = UIButton(type: .system)
        ctaButton.setTitle(selectedWidgetState?.ctaText ?? "Check my progress", for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        ctaButton.setTitleColor(ctaTextColorVal, for: .normal)
        ctaButton.backgroundColor = ctaBgColor
        ctaButton.layer.cornerRadius = 25
        ctaButton.frame = CGRect(x: padding, y: yOffset, width: cardWidth - padding * 2, height: 50)
        cardView.addSubview(ctaButton)
        yOffset = ctaButton.frame.maxY + padding

        cardView.frame = CGRect(x: cardInset, y: 0, width: cardWidth, height: yOffset)
        container.addSubview(cardView)
    }

    // MARK: - MULTISTEP_3
    private func buildMultistep3() {
        let container = UIView(frame: bounds)
        container.backgroundColor = bgColor
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(container)

        let padding: CGFloat = 16
        let expandableCard = MultistepExpandableCard(frame: CGRect(x: padding, y: 24, width: bounds.width - padding * 2, height: bounds.height - 40))
        expandableCard.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        expandableCard.badgeText = selectedWidgetState?.badgeTag ?? ""
        expandableCard.titleText = resolvedTitle
        expandableCard.bodyText = resolvedBody
        expandableCard.ctaText = selectedWidgetState?.ctaText ?? ""
        expandableCard.stepCompleted = stepCompleted
        expandableCard.activityCount = activityCount
        expandableCard.widgetStates = content.widgetStates
        expandableCard.progressBarIconURL = content.progressBarIcon
        expandableCard.ctaAction = selectedWidgetState?.ctaAction
        expandableCard.content = content

        // Apply styles
        expandableCard.brandColor = UIColor(hex: nativeStyle?.brandColor ?? "#E00087")
        expandableCard.ctaBgColor = UIColor(hex: nativeStyle?.ctaBackgroundColor ?? "#E00087")
        expandableCard.ctaTextColor = ctaTextColorVal
        expandableCard.titleColor = titleColorVal
        expandableCard.bodyColor = UIColor(hex: nativeStyle?.bodyColor ?? "#757575")

        // Check if should start expanded
        expandableCard.isExpanded = false // Default collapsed on mobile

        expandableCard.configure()
        container.addSubview(expandableCard)
    }
}

// MARK: - UIColor hex extension
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let length = hexSanitized.count
        let r, g, b, a: CGFloat
        if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
