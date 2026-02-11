import UIKit

/// Reusable horizontal layered progress bar with checkmark icons at completed steps.
/// Layers: total track (background) → in-progress fill → completed fill → checkmark icons
class MultistepProgressBar: UIView {

    // MARK: - Configuration
    var stepCompleted: Int = 0 { didSet { setNeedsLayout() } }
    var activityCount: Int = 1 { didSet { setNeedsLayout() } }
    var progressMeterIconURL: String?
    var rewardText: String? { didSet { rewardLabel.text = rewardText } }

    // Style
    var trackColor: UIColor = UIColor(hex: "#FCEEF8")
    var inProgressColor: UIColor = UIColor(hex: "#FDBEE5")
    var completedColor: UIColor = UIColor(hex: "#FF0099")
    var rewardTextColor: UIColor = UIColor(hex: "#FF0099")
    var barHeight: CGFloat = 16

    // MARK: - Subviews
    private let trackLayer = UIView()
    private let inProgressLayer = UIView()
    private let completedLayer = UIView()
    private let checkmarkContainer = UIView()
    private let rewardLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // Bar container
        addSubview(trackLayer)
        addSubview(inProgressLayer)
        addSubview(completedLayer)
        addSubview(checkmarkContainer)
        addSubview(rewardLabel)

        trackLayer.clipsToBounds = true
        inProgressLayer.clipsToBounds = true
        completedLayer.clipsToBounds = true

        rewardLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        rewardLabel.textAlignment = .right
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let rewardWidth: CGFloat = rewardText != nil ? 80 : 0
        let gap: CGFloat = rewardText != nil ? 8 : 0
        let barWidth = bounds.width - rewardWidth - gap
        let barY = (bounds.height - barHeight) / 2
        let cornerRadius = barHeight / 2

        // Track
        trackLayer.frame = CGRect(x: 0, y: barY, width: barWidth, height: barHeight)
        trackLayer.backgroundColor = trackColor
        trackLayer.layer.cornerRadius = cornerRadius

        // In-progress fill
        let count = max(activityCount, 1)
        var inProgressWidth = CGFloat(stepCompleted + 1) / CGFloat(count) * barWidth
        inProgressWidth = min(inProgressWidth, barWidth)
        inProgressLayer.frame = CGRect(x: 0, y: barY, width: inProgressWidth, height: barHeight)
        inProgressLayer.backgroundColor = inProgressColor
        inProgressLayer.layer.cornerRadius = cornerRadius

        // Completed fill
        let completedWidth = CGFloat(stepCompleted) / CGFloat(count) * barWidth
        completedLayer.frame = CGRect(x: 0, y: barY, width: completedWidth, height: barHeight)
        completedLayer.backgroundColor = completedColor
        completedLayer.layer.cornerRadius = cornerRadius

        // Checkmarks
        checkmarkContainer.subviews.forEach { $0.removeFromSuperview() }
        checkmarkContainer.frame = CGRect(x: 0, y: barY, width: barWidth, height: barHeight)
        let iconSize: CGFloat = 13.33
        for i in 1...max(stepCompleted, 0) {
            guard i <= activityCount else { break }
            let xPos = CGFloat(i) / CGFloat(count) * barWidth - iconSize / 2
            let yPos = (barHeight - iconSize) / 2

            let iconView = UIImageView(frame: CGRect(x: xPos, y: yPos, width: iconSize, height: iconSize))
            iconView.contentMode = .scaleAspectFit

            let iconURL = progressMeterIconURL ?? "https://assets.customerglu.com/d051269a-05d7-4722-9e25-7e031655b4d0/08a52ec5-6483-421c-b478-04172f799478.svg"
            iconView.downloadImage(urlString: iconURL, success: nil, failure: nil)

            checkmarkContainer.addSubview(iconView)
        }

        // Reward label
        rewardLabel.frame = CGRect(x: barWidth + gap, y: 0, width: rewardWidth, height: bounds.height)
        rewardLabel.textColor = rewardTextColor
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: barHeight)
    }
}
