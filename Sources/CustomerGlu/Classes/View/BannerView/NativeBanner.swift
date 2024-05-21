import UIKit
import Foundation

public class NativeBanner: UIView {
    
    @IBInspectable var bannerId: String? {
        didSet {
            backgroundColor = UIColor.clear
        }
    }
    
    private let streakView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 40
        view.backgroundColor = .white
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.red.cgColor
        return view
    }()
    
    private let streakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "3/5"
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "23h 53m"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Keep your Streak going"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Earn at least $1 and claim your daily bonus reward. Complete the challenge"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    public init(frame: CGRect, bannerId: String?) {
        self.bannerId = bannerId
        super.init(frame: frame)
        setupView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: CGFloat(200.0))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(streakView)
        streakView.addSubview(streakLabel)
        addSubview(timerLabel)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Streak View
            streakView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            streakView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            streakView.widthAnchor.constraint(equalToConstant: 80),
            streakView.heightAnchor.constraint(equalToConstant: 80),
            
            // Streak Label
            streakLabel.centerXAnchor.constraint(equalTo: streakView.centerXAnchor),
            streakLabel.centerYAnchor.constraint(equalTo: streakView.centerYAnchor),
            
            // Timer Label
            timerLabel.leadingAnchor.constraint(equalTo: streakView.trailingAnchor, constant: 10),
            timerLabel.topAnchor.constraint(equalTo: streakView.topAnchor),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: streakView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 5),
            
            // Description Label
            descriptionLabel.leadingAnchor.constraint(equalTo: streakView.trailingAnchor, constant: 10),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}
