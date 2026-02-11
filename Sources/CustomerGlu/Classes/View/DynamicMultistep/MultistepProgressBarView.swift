import UIKit

class MultistepProgressBarView: UIView {

    var stepCompleted: Int = 0
    var activityCount: Int = 1
    var progressBarIcon: String?
    var trackColor: UIColor = UIColor(red: 252/255, green: 238/255, blue: 248/255, alpha: 1)
    var inProgressColor: UIColor = UIColor(red: 253/255, green: 190/255, blue: 229/255, alpha: 1)
    var completedColor: UIColor = UIColor(red: 255/255, green: 0/255, blue: 153/255, alpha: 1)
    var barHeight: CGFloat = 16

    private let trackView = UIView()
    private let inProgressView = UIView()
    private let completedView = UIView()
    private var checkmarkViews: [UIImageView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        [trackView, inProgressView, completedView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.cornerRadius = barHeight / 2
            $0.clipsToBounds = true
            addSubview($0)
        }
        trackView.backgroundColor = trackColor
        inProgressView.backgroundColor = inProgressColor
        completedView.backgroundColor = completedColor
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

        trackView.frame = CGRect(x: 0, y: y, width: w, height: h)
        trackView.layer.cornerRadius = h / 2

        var inProgressWidth = CGFloat(stepCompleted + 1) / CGFloat(activityCount) * w
        if inProgressWidth > w { inProgressWidth = w }
        inProgressView.frame = CGRect(x: 0, y: y, width: inProgressWidth, height: h)
        inProgressView.layer.cornerRadius = h / 2

        let completedWidth = CGFloat(stepCompleted) / CGFloat(activityCount) * w
        completedView.frame = CGRect(x: 0, y: y, width: completedWidth, height: h)
        completedView.layer.cornerRadius = h / 2

        // Remove old checkmarks
        checkmarkViews.forEach { $0.removeFromSuperview() }
        checkmarkViews.removeAll()

        // Add checkmarks at completed step positions
        guard stepCompleted > 0 else { return }
        let iconSize: CGFloat = 13.33
        for i in 1...stepCompleted {
            if i > activityCount { break }
            let iconView = UIImageView()
            iconView.contentMode = .scaleAspectFit
            let xPos = CGFloat(i) / CGFloat(activityCount) * w - iconSize / 2
            iconView.frame = CGRect(x: xPos, y: y + 1.33, width: iconSize, height: iconSize)

            if let iconUrl = progressBarIcon, !iconUrl.isEmpty {
                iconView.downloadImage(urlString: iconUrl, completion: { _ in }, failure: { _ in })
            } else {
                iconView.image = UIImage(systemName: "checkmark")
                iconView.tintColor = .white
            }

            addSubview(iconView)
            checkmarkViews.append(iconView)
        }
    }
}
