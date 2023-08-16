//
//  CGCustomAlert.swift
//  CGCustomAlert
//
//  Created by Ankit Jain on 01/03/23.
//

import UIKit

// MARK: - CGCustomAlertDelegate
protocol CGCustomAlertDelegate: AnyObject {
    func okButtonPressed(_ alert: CGCustomAlert, alertTag: Int)
    func cancelButtonPressed(_ alert: CGCustomAlert, alertTag: Int)
}

// MARK: - CGCustomAlert
class CGCustomAlert: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var alertView: UIView!
    
    var alertTitle = ""
    var alertMessage = ""
    var okButtonTitle = "YES"
    var cancelButtonTitle = "NO"
    var alertTag = 0
    var isCancelButtonHidden = false
    var isRetry = false
    
    weak var delegate: CGCustomAlertDelegate?

    init() {
        super.init(nibName: "CGCustomAlert", bundle: .module)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAlert()
    }
    
    func showOnViewController(_ vc: UIViewController) {
        vc.present(self, animated: true)
    }
    
    func setupAlert() {
        alertView.layer.cornerRadius = 12
        titleLabel.text = alertTitle
        messageLabel.text = alertMessage
        okButton.setTitle(okButtonTitle, for: .normal)
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        cancelButton.isHidden = isCancelButtonHidden
    }
    
    @IBAction func actionOnOkButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.okButtonPressed(self, alertTag: alertTag)
    }
    
    @IBAction func actionOnCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.cancelButtonPressed(self, alertTag: alertTag)
    }
}
