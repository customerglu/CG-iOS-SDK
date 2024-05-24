import UIKit

class CircularProgressBar: UIView {
    
    private var backgroundLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    private var progressLabel: UILabel!
    private var imageView: UIImageView!
    
    var progressColor: UIColor = .blue {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var backgroundColorLayer: UIColor = .lightGray {
        didSet {
            backgroundLayer.strokeColor = backgroundColorLayer.cgColor
        }
    }
    
    var lineWidth: CGFloat = 10.0 {
        didSet {
            backgroundLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
        }
    }
    
    var progress: CGFloat = 0 {
        didSet {
            setProgress(progress)
        }
    }
    
    var centerImage: UIImage? {
        didSet {
            imageView.image = centerImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        // Create the circular path
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: bounds.width / 2 - lineWidth / 2, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        
        // Background layer
        backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = backgroundColorLayer.cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)
        
        // Progress layer
        progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
        
        // ImageView
        imageView = UIImageView()
        imageView.image = UIImage(named: "streak_challenge", in: .module, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        // Progress label
        progressLabel = UILabel()
        progressLabel.textAlignment = .center
        progressLabel.textColor = .black
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = bounds
        progressLayer.frame = bounds
        
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: bounds.width / 2 - lineWidth / 2, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        backgroundLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
        
        let imageSize = bounds.width / 2
        imageView.frame = CGRect(x: (bounds.width - imageSize) / 2, y: (bounds.height - imageSize) / 2, width: imageSize, height: imageSize)
        
        progressLabel.frame = bounds
    }
    
    func setProgress(_ progress: CGFloat) {
        progressLayer.strokeEnd = progress
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = value
        progressLayer.add(animation, forKey: "animateProgress")
    }
}
