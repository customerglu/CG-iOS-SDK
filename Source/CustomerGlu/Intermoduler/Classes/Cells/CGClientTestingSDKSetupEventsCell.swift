//
//  CGClientTestingSDKSetupEventsCell.swift
//  
//
//  Created by Ankit Jain on 23/02/23.
//

import UIKit

// MARK: - CGClientTestingSDKSetupEventsCellDelegate
protocol CGClientTestingSDKSetupEventsCellDelegate: NSObjectProtocol {
    func didTapRetry(forEvent event: CGClientTestingRowItem)
    func didTapCheckDoc(forEvent event: CGClientTestingRowItem)
}

// MARK: - CGClientTestingSDKSetupEventsCell
public class CGClientTestingSDKSetupEventsCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tickImageView: UIImageView! // Hidden by default
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
        
    @IBOutlet weak var checkDocLabel: UILabel! // Hidden by default
    @IBOutlet weak var retryLabel: UILabel! // Hidden by default
    @IBOutlet weak var titleLabelLeadingConstraint: NSLayoutConstraint! // 16px by default & for subtask 32px
    
    private weak var delegate: CGClientTestingSDKSetupEventsCellDelegate?
    private var eventItem: CGClientTestingRowItem?
    
    private func setupTheme() {
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .blue
    }
    
    func setupCell(forRowItem rowItem: CGClientTestingRowItem, delegate: CGClientTestingSDKSetupEventsCellDelegate?, clientTestingDataModel: CGClientTestingDataModel?) {
        // Setup Theme
        setupTheme()
        self.delegate = delegate
        eventItem = rowItem
        titleLabel.font = .systemFont(ofSize: 12)
        
        checkDocLabel.isHidden = true
        retryLabel.isHidden = true
        checkDocLabel.isUserInteractionEnabled = false
        retryLabel.isUserInteractionEnabled = false
        
        // Theme
        titleLabel.textColor = .black
        checkDocLabel.backgroundColor = .black
        checkDocLabel.textColor = .white
        retryLabel.backgroundColor = .black
        retryLabel.textColor = .white
        checkDocLabel.layer.cornerRadius = 12
        retryLabel.layer.cornerRadius = 12
        
        // Subtask show with bullet point and padding
        if rowItem.isSubTask() {
            titleLabel.attributedText = addBullet(toText: rowItem.getTitle())
            titleLabelLeadingConstraint.constant = 32
        } else {
            titleLabel.text = rowItem.getTitle()
            titleLabelLeadingConstraint.constant = 16
        }

        switch rowItem.getStatus() {
        case .header:
            titleLabel.font = .boldSystemFont(ofSize: 14)
            tickImageView.isHidden = false
            indicatorView.isHidden = false
            indicatorView.stopAnimating()
            tickImageView.image = nil
            
        case .success:
            tickImageView.isHidden = false
            indicatorView.isHidden = true
            indicatorView.stopAnimating()
            let greenTickImage = UIImage(named: "greenTick", in: .module, compatibleWith: nil)
            tickImageView.image = greenTickImage
            
        case .failure:
            tickImageView.isHidden = false
            indicatorView.isHidden = true
            indicatorView.stopAnimating()
            let redCrossImage = UIImage(named: "redCross", in: .module, compatibleWith: nil)
            tickImageView.image = redCrossImage
                        
            checkDocLabel.text = "Check Doc"
            checkDocLabel.isHidden = false
            
            retryLabel.text = "Retry"
            retryLabel.isHidden = false
            
            checkDocLabel.isUserInteractionEnabled = true
            retryLabel.isUserInteractionEnabled = true
            
            let checkDocGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnCheckDoc))
            checkDocLabel.addGestureRecognizer(checkDocGesture)
            
            let retryGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnRetry))
            retryLabel.addGestureRecognizer(retryGesture)
            
        case .pending:
            tickImageView.isHidden = true
            indicatorView.isHidden = false
            indicatorView.startAnimating()
        }
    }
    
    @objc func didTapOnRetry() {
        if let delegate = delegate, let eventItem = eventItem {
                delegate.didTapRetry(forEvent: eventItem)
        }
    }
    
    @objc func didTapOnCheckDoc() {
        if let delegate = delegate, let eventItem = eventItem {
            delegate.didTapCheckDoc(forEvent: eventItem)
        }
    }
    
    private func addBullet(toText text: String) -> NSMutableAttributedString {
        let firstLineAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
        let firstLineString = NSMutableAttributedString(string: "• ",
                                                        attributes: firstLineAttribute)
        
        let secondLineAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        let secondLineString = NSMutableAttributedString(string: text,
                                                         attributes: secondLineAttribute)
        firstLineString.append(secondLineString)
        return firstLineString
    }
}
