import UIKit
import Foundation

public class NativeBanner: UIView {
    
    @IBInspectable var bannerId: String? {
        didSet {
            backgroundColor = UIColor.clear
        }
    }
    
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let circularProgressBar: CircularProgressBar = {
        let progressBar = CircularProgressBar()
        progressBar.lineWidth = 5
        progressBar.progressColor = UIColor(hex: "#FF089D") ?? .red
        progressBar.backgroundColorLayer = .lightGray
        progressBar.setProgress(0.65)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let streakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "3/5"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "23h 53m"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Keep your Streak going"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Earn at least $1 and claim your daily bonus reward. Complete the challenge"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "chevron.right") // Using system forward arrow icon
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    public init(frame: CGRect, bannerId: String?) {
        self.bannerId = bannerId
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    public override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: CGFloat(140.0))
    }
    
    private func setupView() {
        addSubview(cardView)
        cardView.addSubview(circularProgressBar)
        cardView.addSubview(streakLabel)
        cardView.addSubview(timerLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(iconView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Card View
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            cardView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            // Circular Progress Bar
            circularProgressBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            circularProgressBar.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            circularProgressBar.widthAnchor.constraint(equalToConstant: 50),
            circularProgressBar.heightAnchor.constraint(equalToConstant: 50),
            
            // Streak Label
            streakLabel.centerXAnchor.constraint(equalTo: circularProgressBar.centerXAnchor),
            streakLabel.topAnchor.constraint(equalTo: circularProgressBar.bottomAnchor, constant: 10),
            
            // Timer Label
            timerLabel.leadingAnchor.constraint(equalTo: circularProgressBar.trailingAnchor, constant: 10),
            timerLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: circularProgressBar.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 5),
            
            // Description Label
            descriptionLabel.leadingAnchor.constraint(equalTo: circularProgressBar.trailingAnchor, constant: 10),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -10),
            
            // Icon View
            iconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
}
