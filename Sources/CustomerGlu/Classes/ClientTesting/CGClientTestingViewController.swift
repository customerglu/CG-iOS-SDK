//
//  CGClientTestingViewController.swift
//
//
//  Created by Ankit Jain on 22/02/23.
//

import UIKit

// MARK: - CGClientTestingViewController
public class CGClientTestingViewController: UIViewController {

    // Variables
    var viewModel: CGClientTestingViewModel = CGClientTestingViewModel()
    public static let storyboardVC = StoryboardType.main.instantiate(vcType: CGClientTestingViewController.self)

    // UI Elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topSafeArea: UIView!
    @IBOutlet weak var bottomSafeArea: UIView!
    @IBOutlet weak var topHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!

    // View Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.delegate = self
        
        // Configure Safe Area for Dark Mode
        configureSafeAreaForDevices()
        
        // Execute the client testing
        viewModel.executeClientTesting()
    }
    
    public func configureSafeAreaForDevices() {
        let window = UIApplication.shared.keyWindow
        let topPadding = (window?.safeAreaInsets.top) ?? CGSafeAreaConstants.SAFE_AREA_PADDING
        let bottomPadding = (window?.safeAreaInsets.bottom) ?? CGSafeAreaConstants.SAFE_AREA_PADDING
        
        if topPadding <= 20 || bottomPadding < 20 {
            CustomerGlu.topSafeAreaHeight = 20
            CustomerGlu.bottomSafeAreaHeight = 0
            CustomerGlu.topSafeAreaColor = UIColor.clear
        }
        
        topHeight.constant = CGFloat(CustomerGlu.topSafeAreaHeight == -1 ? Int(topPadding) : CustomerGlu.topSafeAreaHeight)
        bottomHeight.constant = CGFloat(CustomerGlu.bottomSafeAreaHeight == -1 ? Int(bottomPadding) : CustomerGlu.bottomSafeAreaHeight)
        
        
        if CustomerGlu.getInstance.isDarkModeEnabled(){
            topSafeArea.backgroundColor = CustomerGlu.topSafeAreaColorDark
            bottomSafeArea.backgroundColor = CustomerGlu.bottomSafeAreaColorDark
        } else {
            topSafeArea.backgroundColor = CustomerGlu.topSafeAreaColorLight
            bottomSafeArea.backgroundColor = CustomerGlu.bottomSafeAreaColorLight
        }
    }
    
    @IBAction func backButton(sender: UIButton) {
        self.closePage(animated: true)
    }
    
    private func closePage(animated: Bool){
        self.dismiss(animated: animated) {
            CustomerGlu.getInstance.showFloatingButtons()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CGClientTestingViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells(forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCGClientTestingSDKSetupEventsCell(with: tableView, indexPath: indexPath)
    }
    
    public func getCGClientTestingSDKSetupEventsCell(with tableView: UITableView, indexPath: IndexPath) -> CGClientTestingSDKSetupEventsCell {
        var nullableCell = tableView.dequeueReusableCell(withIdentifier: CGClientTestingSDKSetupEventsCell.reuseIdentifier) as? CGClientTestingSDKSetupEventsCell
        
        if nullableCell == nil {
            tableView.register(UINib(nibName: CGClientTestingSDKSetupEventsCell.nibName, bundle: .module), forCellReuseIdentifier: CGClientTestingSDKSetupEventsCell.reuseIdentifier)
            
            nullableCell = tableView.dequeueReusableCell(withIdentifier: CGClientTestingSDKSetupEventsCell.reuseIdentifier, for: indexPath)  as? CGClientTestingSDKSetupEventsCell
        }
        
        guard let cell = nullableCell else {
            assert(true)
            return CGClientTestingSDKSetupEventsCell()
        }
        
        // Selection type
        cell.selectionStyle = .none
        cell.accessoryType = .none
        
        // Setup Cell
        let rowItem = viewModel.getRowItemForEventsSection(withIndexPath: indexPath)
        cell.setupCell(forRowItem: rowItem, delegate: self, clientTestingDataModel: viewModel.clientTestingModel?.data)
        
        return cell
    }
}

// MARK: - CGClientTestingSDKSetupEventsCellDelegate
extension CGClientTestingViewController: CGClientTestingSDKSetupEventsCellDelegate {
    func didTapRetry(forEvent event: CGClientTestingRowItem) {
        switch event {
        case .callbackHanding:
            let itemInfo = viewModel.getIndexOfItem(.callbackHanding(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
            viewModel.eventsSectionsArray[index] = .callbackHanding(status: .pending)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])

            viewModel.executecallbackHanding(isRetry: true)
        case .nudgeHandling:
            let itemInfo = viewModel.getIndexOfItem(.nudgeHandling(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
            
            viewModel.eventsSectionsArray[index] = .nudgeHandling(status: .pending)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])
            
            viewModel.executeNudgeHandling(isRetry: true)
        case .cgDeeplinkHandling:
            let itemInfo = viewModel.getIndexOfItem(.cgDeeplinkHandling(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
            
            viewModel.eventsSectionsArray[index] = .cgDeeplinkHandling(status: .pending)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])
            
            viewModel.executeCGDeeplinkHandling(isRetry: true)
            
        case .entryPointSetup:
            let itemInfo = viewModel.getIndexOfItem(.entryPointSetup(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
            
            viewModel.eventsSectionsArray[index] = .entryPointSetup(status: .pending)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])
            
            viewModel.executeEntryPointSetup(isRetry: true)
            
        case .entryPointScreeNameSetup:
            let itemInfo = viewModel.getIndexOfItem(.entryPointScreeNameSetup(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
            
            viewModel.eventsSectionsArray[index] = .entryPointScreeNameSetup(status: .pending)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])
            
            viewModel.executeEntryPointScreenNameSetup(isRetry: true)
            
        case .entryPointBannerIDSetup:
            let itemInfo = viewModel.getIndexOfItem(.entryPointBannerIDSetup(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
            
            viewModel.eventsSectionsArray[index] = .entryPointBannerIDSetup(status: .pending)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])
            
            viewModel.executeEntryPointBannerIDSetup(isRetry: true)
            
        case .entryPointEmbedIDSetup:
            let itemInfo = viewModel.getIndexOfItem(.entryPointEmbedIDSetup(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
            
            viewModel.eventsSectionsArray[index] = .entryPointEmbedIDSetup(status: .pending)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])
            
            viewModel.executeEntryPointEmbedIDSetup(isRetry: true)
            
        default:
            break
        }
    }
    
    func didTapCheckDoc(forEvent event: CGClientTestingRowItem) {
        guard let url = event.getDocumentationURL() else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

// MARK: - CGClientTestingProtocol
extension CGClientTestingViewController: CGClientTestingProtocol {
    public func updateTable(atIndexPath indexPath: IndexPath, forEvent event: CGClientTestingRowItem) {
        DispatchQueue.main.async {
            // Whenever any event completes execution, update the table UI
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    public func updateTable(atIndexPaths indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            // Whenever any event completes execution, update the table UI
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    
    public func showCallBackAlert(forEvent event: CGClientTestingRowItem, isRetry: Bool) {
        guard let data = event.getAlertTitleAndMessage() else { return }
        let customAlert = CGCustomAlert()
        customAlert.alertTitle = data.title
        customAlert.alertMessage = data.message
        customAlert.alertTag = data.tag
        if data.tag == CGCustomAlertTag.callbackHandingTag.rawValue {
            customAlert.okButtonTitle = "CallBack"
            customAlert.cancelButtonTitle = ""
            customAlert.isCancelButtonHidden = true
        } else {
            customAlert.okButtonTitle = "Yes"
            customAlert.cancelButtonTitle = "No"
            customAlert.isCancelButtonHidden = false
        }
        customAlert.delegate = self
        customAlert.isRetry = isRetry
        customAlert.showOnViewController(self)
    }
    
    public func testOneLinkDeeplink(withDeeplinkURL deeplinkURL: String) {
        guard let url = URL(string: "http://assets.customerglu.com/deeplink-redirect/?redirect=\(deeplinkURL)") else { return}
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    public func reloadOnSDKNotificationConfigSuccess() {
        self.tableView.reloadData()
    }
}

// MARK: - CGCustomAlertDelegate
extension CGClientTestingViewController: CGCustomAlertDelegate {
    func okButtonPressed(_ alert: CGCustomAlert, alertTag: Int) {
        if alertTag == CGCustomAlertTag.callbackHandingTag.rawValue {
            let itemInfo = viewModel.getIndexOfItem(.callbackHanding(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }

            viewModel.eventsSectionsArray[index] = .callbackHanding(status: .success)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])
            
            if !alert.isRetry {
                if let callbackConfigurationUrl = CustomerGlu.getInstance.appconfigdata?.callbackConfigurationUrl {
                    var postdata = [String:Any]()
                    postdata["eventName"] = "OPEN_DEEPLINK"
                    
                    var data = [String:Any]()
                    data["name"] = "home"
                    data["deepLink"] = callbackConfigurationUrl
                    
                    postdata["data"] = data
                    
                    // Show the alert to launch the Client testing back
                    CustomerGlu.getInstance.showClientTestingRedirectAlert()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_DEEPLINK_EVENT").rawValue), object: nil, userInfo: postdata)
                }
                
                //Execute Next Step
                viewModel.executeNudgeHandling()
            }
        } else if alertTag == CGCustomAlertTag.nudgeHandlingTag.rawValue {
            let itemInfo = viewModel.getIndexOfItem(.nudgeHandling(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
            
            viewModel.eventsSectionsArray[index] = .nudgeHandling(status: .success)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])

            if !alert.isRetry {
                //Execute Next Step
                viewModel.executeCGDeeplinkHandling()
            }
        } else if alertTag == CGCustomAlertTag.cgDeeplinkHandlingTag.rawValue {
            let itemInfo = viewModel.getIndexOfItem(.cgDeeplinkHandling(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
            
            viewModel.eventsSectionsArray[index] = .cgDeeplinkHandling(status: .success)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])
            
            if !alert.isRetry {
                //Execute Next Step
                viewModel.executeEntryPointSetup()
            }
        }
    }
    
    func cancelButtonPressed(_ alert: CGCustomAlert, alertTag: Int) {
        if alertTag == CGCustomAlertTag.callbackHandingTag.rawValue {
            let itemInfo = viewModel.getIndexOfItem(.callbackHanding(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }

            viewModel.eventsSectionsArray[index] = .callbackHanding(status: .failure)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])
            
            if !alert.isRetry {
                //Execute Next Step
                viewModel.executeNudgeHandling()
            }
        } else if alertTag == CGCustomAlertTag.nudgeHandlingTag.rawValue {
            let itemInfo = viewModel.getIndexOfItem(.nudgeHandling(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
            
            viewModel.eventsSectionsArray[index] = .nudgeHandling(status: .failure)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])

            if !alert.isRetry {
                //Execute Next Step
                viewModel.executeCGDeeplinkHandling()
            }
        } else if alertTag == CGCustomAlertTag.cgDeeplinkHandlingTag.rawValue {
            let itemInfo = viewModel.getIndexOfItem(.cgDeeplinkHandling(status: .pending))
            guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
            
            viewModel.eventsSectionsArray[index] = .cgDeeplinkHandling(status: .failure)
            self.updateTable(atIndexPath: indexPath, forEvent: viewModel.eventsSectionsArray[index])
            
            if !alert.isRetry {
                //Execute Next Step
                viewModel.executeEntryPointSetup()
            }
        }
    }
}
