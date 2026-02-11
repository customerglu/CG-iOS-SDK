import UIKit

/// MULTISTEP_3 collapsible card with expand/collapse animation.
/// Header: badge tag + title + chevron. Expanded: step circles + description + CTA button.
class MultistepExpandableCard: UIView {

    // MARK: - Data
    var badgeText: String = "" { didSet { badgeLabel.text = badgeText } }
    var titleText: String = "" { didSet { titleLabel.text = titleText } }
    var bodyText: String = "" { didSet { descriptionLabel.text = bodyText } }
    var ctaText: String = "" { didSet { ctaButton.setTitle(ctaText, for: .normal) } }
    var isExpanded: Bool = false

    var stepCompleted: Int = 0
    var activityCount: Int = 0
    var widgetStates: [CGWidgetState]?
    var progressBarIconURL: String?
    var ctaAction: CGWidgetCtaAction?
    var content: CGContent?

    // Style
    var brandColor: UIColor = UIColor(hex: "#E00087")
    var ctaBgColor: UIColor = UIColor(hex: "#E00087")
    var ctaTextColor: UIColor = .white
    var titleColor: UIColor = UIColor(hex: "#242220")
    var bodyColor: UIColor = UIColor(hex: "#757575")

    // Callback
    var onCtaTapped: (() -> Void)?
    var onExpandToggle: ((Bool) -> Void)?

    // MARK: - Subviews
    private let cardContainer = UIView()
    private let headerView = UIView()
    private let headerContentStack = UIStackView()
    private let badgeLabel = UILabel()
    private let badgeContainer = UIView()
    private let titleLabel = UILabel()
    private let chevronImageView = UIImageView()
    private let contentContainer = UIView()
    private let stepCircles = MultistepStepCircles()
    private let descriptionLabel = UILabel()
    private let ctaButtonContainer = UIView()
    private let ctaButton = UIButton(type: .system)

    private var contentHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // Card container with shadow
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.backgroundColor = .white
        cardContainer.layer.cornerRadius = 12
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.2
        cardContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardContainer.layer.shadowRadius = 8
        cardContainer.clipsToBounds = false
        addSubview(cardContainer)

        // Header
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 12
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = UIColor(hex: "#D8D8D8").cgColor
        headerView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleExpand))
        headerView.addGestureRecognizer(tap)
        cardContainer.addSubview(headerView)

        // Header content stack (badge + title)
        headerContentStack.translatesAutoresizingMaskIntoConstraints = false
        headerContentStack.axis = .vertical
        headerContentStack.spacing = 8
        headerView.addSubview(headerContentStack)

        // Badge
        badgeContainer.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        badgeLabel.textColor = UIColor(hex: "#E00087")
        badgeContainer.backgroundColor = UIColor(hex: "#FCEEF8")
        badgeContainer.layer.cornerRadius = 4
        badgeContainer.layer.borderWidth = 1
        badgeContainer.layer.borderColor = UIColor(hex: "#E00087").cgColor
        badgeContainer.addSubview(badgeLabel)
        headerContentStack.addArrangedSubview(badgeContainer)

        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: badgeContainer.topAnchor, constant: 1),
            badgeLabel.bottomAnchor.constraint(equalTo: badgeContainer.bottomAnchor, constant: -1),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -8),
        ])

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = titleColor
        titleLabel.numberOfLines = 0
        headerContentStack.addArrangedSubview(titleLabel)

        // Chevron
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.tintColor = UIColor(hex: "#E00087")
        // Draw a simple chevron
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        if #available(iOS 13.0, *) {
            chevronImageView.image = UIImage(systemName: "chevron.down", withConfiguration: chevronConfig)
        }
        headerView.addSubview(chevronImageView)

        // Content container (expandable)
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.clipsToBounds = true
        contentContainer.backgroundColor = .white
        cardContainer.addSubview(contentContainer)

        // Step circles
        stepCircles.translatesAutoresizingMaskIntoConstraints = false
        stepCircles.connectorStyle = .dashed
        stepCircles.circleSize = 24
        stepCircles.connectorHeight = 1
        stepCircles.showLabels = false
        contentContainer.addSubview(stepCircles)

        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = bodyColor
        descriptionLabel.numberOfLines = 0
        contentContainer.addSubview(descriptionLabel)

        // CTA button container
        ctaButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        ctaButtonContainer.backgroundColor = ctaBgColor
        contentContainer.addSubview(ctaButtonContainer)

        // CTA button
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        ctaButton.setTitleColor(ctaTextColor, for: .normal)
        ctaButton.backgroundColor = .clear
        ctaButton.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)
        ctaButtonContainer.addSubview(ctaButton)

        // Content border
        let contentBorder = UIView()
        contentBorder.translatesAutoresizingMaskIntoConstraints = false
        contentBorder.layer.borderWidth = 1
        contentBorder.layer.borderColor = UIColor(hex: "#D8D8D8").cgColor
        contentBorder.isUserInteractionEnabled = false
        contentContainer.addSubview(contentBorder)

        // Layout
        contentHeightConstraint = contentContainer.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: topAnchor),
            cardContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

            headerView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),

            headerContentStack.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            headerContentStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerContentStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            headerContentStack.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -10),

            chevronImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -9),
            chevronImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 24),
            chevronImageView.heightAnchor.constraint(equalToConstant: 24),

            contentContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),

            stepCircles.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 16),
            stepCircles.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            stepCircles.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -19),

            descriptionLabel.topAnchor.constraint(equalTo: stepCircles.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),

            ctaButtonContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            ctaButtonContainer.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            ctaButtonContainer.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            ctaButtonContainer.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            ctaButtonContainer.heightAnchor.constraint(equalToConstant: 40),

            ctaButton.topAnchor.constraint(equalTo: ctaButtonContainer.topAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: ctaButtonContainer.bottomAnchor),
            ctaButton.leadingAnchor.constraint(equalTo: ctaButtonContainer.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: ctaButtonContainer.trailingAnchor),

            contentBorder.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            contentBorder.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            contentBorder.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            contentBorder.bottomAnchor.constraint(equalTo: ctaButtonContainer.topAnchor),
        ])

        if !isExpanded {
            contentHeightConstraint?.isActive = true
        }
    }

    func configure() {
        badgeLabel.text = badgeText
        titleLabel.text = titleText
        descriptionLabel.text = bodyText
        ctaButton.setTitle(ctaText, for: .normal)
        ctaButtonContainer.backgroundColor = ctaBgColor
        ctaButton.setTitleColor(ctaTextColor, for: .normal)
        titleLabel.textColor = titleColor
        descriptionLabel.textColor = bodyColor
        badgeLabel.textColor = brandColor
        badgeContainer.layer.borderColor = brandColor.cgColor

        // Configure step circles
        var stepData: [MultistepStepCircles.StepData] = []
        if let ws = widgetStates {
            for i in 0..<activityCount {
                let widget = ws.first(where: { $0.step == i }) ?? ws.first
                let rewardText = widget?.progressBar?.progressRewardText ?? ""
                let label = widget?.progressBar?.progressLabel ?? "Step \(i + 1)"
                stepData.append(.init(rewardText: rewardText, label: label))
            }
        } else {
            for i in 0..<activityCount {
                stepData.append(.init(rewardText: "", label: "Step \(i + 1)"))
            }
        }

        stepCircles.steps = stepData
        stepCircles.stepCompleted = stepCompleted
        stepCircles.activityCount = activityCount
        stepCircles.brandColor = brandColor
        stepCircles.progressBarIconURL = progressBarIconURL
        stepCircles.reload()

        updateExpandState(animated: false)
    }

    @objc private func toggleExpand() {
        isExpanded = !isExpanded
        updateExpandState(animated: true)
        onExpandToggle?(isExpanded)
    }

    private func updateExpandState(animated: Bool) {
        let update = {
            if self.isExpanded {
                self.contentHeightConstraint?.isActive = false
            } else {
                self.contentHeightConstraint?.isActive = true
            }
            self.chevronImageView.transform = self.isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            self.headerView.layer.maskedCorners = self.isExpanded
                ? [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: update)
        } else {
            update()
        }
    }

    @objc private func ctaTapped() {
        onCtaTapped?()
    }
}
