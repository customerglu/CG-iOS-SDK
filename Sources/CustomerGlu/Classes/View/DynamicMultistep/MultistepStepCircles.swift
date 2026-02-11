import UIKit

/// Horizontal step circles with connectors — used by MULTISTEP_2 and MULTISTEP_3.
/// Each circle shows reward text; completed circles show a checkmark icon or filled style.
/// Connectors between circles: solid for _2, dashed for _3.
class MultistepStepCircles: UIView {

    struct StepData {
        let rewardText: String
        let label: String
    }

    enum ConnectorStyle {
        case solid
        case dashed
    }

    // MARK: - Configuration
    var steps: [StepData] = []
    var stepCompleted: Int = 0
    var activityCount: Int = 0
    var connectorStyle: ConnectorStyle = .solid
    var progressBarIconURL: String?

    // Style
    var brandColor: UIColor = UIColor(hex: "#FF0099")
    var lockedColor: UIColor = UIColor(hex: "#999999")
    var lockedBorderColor: UIColor = UIColor(hex: "#FFDFF2")
    var circleSize: CGFloat = 50
    var connectorHeight: CGFloat = 4
    var showLabels: Bool = true
    var labelFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    var completedLabelColor: UIColor = UIColor(hex: "#242220")
    var currentLabelColor: UIColor = UIColor(hex: "#FF0099")
    var inactiveLabelColor: UIColor = UIColor(hex: "#757575")

    // MARK: - Internal
    private var circleViews: [UIView] = []
    private var labelViews: [UILabel] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func reload() {
        subviews.forEach { $0.removeFromSuperview() }
        circleViews.removeAll()
        labelViews.removeAll()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard activityCount > 0 else { return }
        subviews.forEach { $0.removeFromSuperview() }

        let count = activityCount
        let labelHeight: CGFloat = showLabels ? 20 : 0
        let labelGap: CGFloat = showLabels ? 8 : 0
        let totalAvailableWidth = bounds.width - CGFloat(count) * circleSize
        let connectorWidth = count > 1 ? totalAvailableWidth / CGFloat(count - 1) : 0
        let circlesY: CGFloat = 0
        let labelsY = circlesY + circleSize + labelGap

        for i in 0..<count {
            let step = i < steps.count ? steps[i] : StepData(rewardText: "", label: "Step \(i + 1)")
            let xOffset = CGFloat(i) * (circleSize + connectorWidth)

            // Circle
            let circleView = UIView(frame: CGRect(x: xOffset, y: circlesY, width: circleSize, height: circleSize))
            circleView.layer.cornerRadius = circleSize / 2
            circleView.clipsToBounds = true

            if i < stepCompleted {
                // Completed
                if connectorStyle == .dashed {
                    // MULTISTEP_3 style: filled brand color with checkmark
                    circleView.backgroundColor = brandColor
                    circleView.layer.borderWidth = 0
                    let iconView = UIImageView(frame: circleView.bounds.insetBy(dx: 6, dy: 6))
                    iconView.contentMode = .scaleAspectFit
                    let iconURL = progressBarIconURL ?? "https://assets.customerglu.com/d051269a-05d7-4722-9e25-7e031655b4d0/08a52ec5-6483-421c-b478-04172f799478.svg"
                    iconView.downloadImage(urlString: iconURL, success: nil, failure: nil)
                    circleView.addSubview(iconView)
                } else {
                    // MULTISTEP_2 style: white bg with brand border
                    circleView.backgroundColor = .white
                    circleView.layer.borderWidth = 4
                    circleView.layer.borderColor = brandColor.cgColor
                    addRewardLabel(to: circleView, text: step.rewardText, color: brandColor)
                }
            } else if i == stepCompleted {
                // Current
                circleView.backgroundColor = .white
                circleView.layer.borderWidth = connectorStyle == .dashed ? 1 : 4
                circleView.layer.borderColor = brandColor.cgColor
                let textColor = connectorStyle == .dashed ? brandColor : brandColor
                addRewardLabel(to: circleView, text: step.rewardText, color: textColor)
            } else {
                // Locked
                circleView.backgroundColor = .white
                circleView.layer.borderWidth = connectorStyle == .dashed ? 1 : 4
                circleView.layer.borderColor = (connectorStyle == .dashed ? lockedColor : lockedBorderColor).cgColor
                let textColor = lockedColor
                addRewardLabel(to: circleView, text: step.rewardText, color: textColor)
            }

            addSubview(circleView)

            // Connector (not after last)
            if i < count - 1 {
                let connX = xOffset + circleSize
                let connY = circlesY + circleSize / 2 - connectorHeight / 2
                let connFrame = CGRect(x: connX, y: connY, width: connectorWidth, height: connectorHeight)

                if connectorStyle == .dashed {
                    let connView = UIView(frame: connFrame)
                    let shapeLayer = CAShapeLayer()
                    let path = UIBezierPath()
                    path.move(to: CGPoint(x: 0, y: connectorHeight / 2))
                    path.addLine(to: CGPoint(x: connectorWidth, y: connectorHeight / 2))
                    shapeLayer.path = path.cgPath
                    shapeLayer.strokeColor = (i < stepCompleted ? brandColor : lockedColor).cgColor
                    shapeLayer.lineWidth = 1
                    shapeLayer.lineDashPattern = [4, 4]
                    shapeLayer.fillColor = nil
                    connView.layer.addSublayer(shapeLayer)
                    addSubview(connView)
                } else {
                    let connView = UIView(frame: connFrame)
                    connView.backgroundColor = i < stepCompleted - 1 ? brandColor : UIColor(hex: "#FCEEF8")
                    addSubview(connView)
                }
            }

            // Label
            if showLabels {
                let labelWidth: CGFloat = 60
                let labelX = xOffset + circleSize / 2 - labelWidth / 2
                let label = UILabel(frame: CGRect(x: labelX, y: labelsY, width: labelWidth, height: labelHeight))
                label.text = step.label
                label.font = labelFont
                label.textAlignment = .center
                label.numberOfLines = 2
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.7

                if i < stepCompleted {
                    label.textColor = completedLabelColor
                    label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
                } else if i == stepCompleted {
                    label.textColor = currentLabelColor
                    label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
                } else {
                    label.textColor = inactiveLabelColor
                    label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                }

                addSubview(label)
            }
        }
    }

    private func addRewardLabel(to circle: UIView, text: String, color: UIColor) {
        let label = UILabel(frame: circle.bounds)
        label.text = text
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: connectorStyle == .dashed ? 12 : 16, weight: .semibold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        circle.addSubview(label)
    }

    override var intrinsicContentSize: CGSize {
        let labelHeight: CGFloat = showLabels ? 28 : 0
        return CGSize(width: UIView.noIntrinsicMetric, height: circleSize + labelHeight)
    }
}
