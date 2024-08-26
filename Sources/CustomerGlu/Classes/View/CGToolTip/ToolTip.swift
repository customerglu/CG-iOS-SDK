import UIKit
import Foundation


public class TooltipView: UIView {
    private let tooltipLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let notchSize: CGSize = CGSize(width: 16, height: 8)
    private let color: UIColor
    private let position: TooltipPosition
    
    public init(text: String) {
        self.color = UIColor(hex: "#2196F3") ?? UIColor.black
        self.position = .top
        super.init(frame: .zero)
        tooltipLabel.text = text
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.addSubview(tooltipLabel)
        tooltipLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Constrain the label to fill the entire view without padding
        NSLayoutConstraint.activate([
            tooltipLabel.topAnchor.constraint(equalTo: self.topAnchor),
            tooltipLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -notchSize.height),
            tooltipLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tooltipLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath()
        
        // Draw the rectangle (not rounded)
        let tooltipRect = CGRect(
            x: 0,
            y: position == .top ? 0 : notchSize.height,
            width: rect.width,
            height: rect.height - notchSize.height
        )
        path.append(UIBezierPath(rect: tooltipRect))
        
        // Draw the notch
        let notchStartX = (rect.width - notchSize.width) / 2
        let notchEndX = notchStartX + notchSize.width
        let notchY = position == .top ? rect.height - notchSize.height : 0
        let notchPeakY = position == .top ? rect.height : notchSize.height
        
        path.move(to: CGPoint(x: notchStartX, y: notchY))
        path.addLine(to: CGPoint(x: notchStartX + notchSize.width / 2, y: notchPeakY))
        path.addLine(to: CGPoint(x: notchEndX, y: notchY))
        
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color.cgColor
        self.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    public func adjustSize(forWidth width: CGFloat) {
        let screenWidth = UIScreen.main.bounds.width
        let size = self.sizeThatFits(CGSize(width: screenWidth, height: CGFloat.greatestFiniteMagnitude))
        self.frame = CGRect(origin: .zero, size: CGSize(width: screenWidth, height: size.height + notchSize.height))
    }
}
