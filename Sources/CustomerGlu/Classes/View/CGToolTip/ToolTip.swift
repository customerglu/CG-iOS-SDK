import UIKit
import Foundation

public class CGTooltipView: UIView {
    private let tooltipHeadingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let tooltipLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let stepLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ok", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(hex: "#F0C419") // Yellow background
        button.layer.cornerRadius = 4
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    
    private let notchSize: CGSize = CGSize(width: 16, height: 8)
    private let color: UIColor
    private let position: TooltipPosition
    private var isNotchVisible: Bool = true
    
    public init(heading: String, text: String, isNotchShown:Bool = true) {
        self.color = UIColor.darkGray
        self.position = .bottom
        self.isNotchVisible = isNotchShown
        super.init(frame: .zero)
        tooltipHeadingLabel.text = heading
        tooltipLabel.text = text
        stepLabel.text = "3/3"
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.darkGray
        self.addSubview(tooltipHeadingLabel)
        self.addSubview(tooltipLabel)
        self.addSubview(stepLabel)
        self.addSubview(actionButton)
        
        tooltipHeadingLabel.translatesAutoresizingMaskIntoConstraints = false
        tooltipLabel.translatesAutoresizingMaskIntoConstraints = false
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 16
        
        // Constrain the elements within the view with padding
        NSLayoutConstraint.activate([
            tooltipHeadingLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            tooltipHeadingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            tooltipHeadingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            
            tooltipLabel.topAnchor.constraint(equalTo: tooltipHeadingLabel.bottomAnchor, constant: 8),
            tooltipLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            tooltipLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            
            stepLabel.topAnchor.constraint(equalTo: tooltipLabel.bottomAnchor, constant: 8),
            stepLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            
            actionButton.centerYAnchor.constraint(equalTo: stepLabel.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            actionButton.widthAnchor.constraint(equalToConstant: 50),
            actionButton.heightAnchor.constraint(equalToConstant: 30),
            
            stepLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -notchSize.height - padding) // Adjust for notch and padding
        ])
        
        // Apply rounded corners
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        if (self.isNotchVisible){
            let path = UIBezierPath(roundedRect: rect.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: notchSize.height, right: 0)), cornerRadius: 8)
            
            // Draw the notch below
            let notchStartX = (rect.width - notchSize.width) / 2
            let notchEndX = notchStartX + notchSize.width
            let notchY = rect.height - notchSize.height
            let notchPeakY = rect.height
            
            path.move(to: CGPoint(x: notchStartX, y: notchY))
            path.addLine(to: CGPoint(x: notchStartX + notchSize.width / 2, y: notchPeakY))
            path.addLine(to: CGPoint(x: notchEndX, y: notchY))
            
            path.close()
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = color.cgColor
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
    }
    
//    public func adjustSize(forWidth width: CGFloat) {
//        let padding: CGFloat = 16
//        let maxSize = CGSize(width: width - padding * 2, height: CGFloat.greatestFiniteMagnitude) // Padding from edges
//        let headingSize = tooltipHeadingLabel.sizeThatFits(maxSize)
//        let textSize = tooltipLabel.sizeThatFits(maxSize)
//        let totalHeight = headingSize.height + textSize.height + stepLabel.intrinsicContentSize.height + padding + 8 + 30 + notchSize.height // Adjust for heading, step label, padding, button height, and notch
//        self.frame = CGRect(origin: .zero, size: CGSize(width: max(headingSize.width, textSize.width) + padding * 2, height: totalHeight))
//    }
    
    public func adjustSize(forWidth maxWidth: CGFloat) {
        let padding: CGFloat = 16
        
        // Calculate the maximum width available for the content
        let contentMaxWidth = maxWidth - padding * 2
        
        // Calculate the size of each label
        let headingSize = tooltipHeadingLabel.sizeThatFits(CGSize(width: contentMaxWidth, height: CGFloat.greatestFiniteMagnitude))
        let textSize = tooltipLabel.sizeThatFits(CGSize(width: contentMaxWidth, height: CGFloat.greatestFiniteMagnitude))
        let stepLabelSize = stepLabel.sizeThatFits(CGSize(width: contentMaxWidth, height: CGFloat.greatestFiniteMagnitude))
        let buttonSize = actionButton.intrinsicContentSize
        
        // Calculate total height including padding, labels, button, and notch
        let totalHeight = padding + headingSize.height + 8 + textSize.height + 8 + max(stepLabelSize.height, buttonSize.height) + padding + notchSize.height
        
        // Calculate total width (ensure it accommodates the widest element)
        let totalWidth = max(headingSize.width, textSize.width, stepLabelSize.width + buttonSize.width + 8) + padding * 2
        
        // Set the frame of the tooltip view
        self.frame = CGRect(origin: .zero, size: CGSize(width: totalWidth, height: totalHeight))
    }
}


