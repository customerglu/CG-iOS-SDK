//
//  CGPictureInPictureViewController.swift
//  
//
//  Created by Kausthubh adhikari on 20/10/23.
//

import Foundation
import UIKit

class CGPictureInPictureViewController : UIViewController, CGPiPMoviePlayerProtocol{
  
    
    
    var pipInfo: CGData?
    private(set) var pipMediaPlayer: CGPiPMoviePlayer!
    
    private var window = PiPWindow()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    init(btnInfo: CGData) {
        super.init(nibName: nil, bundle: nil)
        pipInfo = btnInfo
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = false
        window.rootViewController = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(note:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    
    override func viewDidLoad() {
        let view = UIView()
        
        let screenRect = UIScreen.main.bounds
        var screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        screenWidth = screenWidth * 0.40
        let widthPer  = screenWidth
        let heightPer = 1.78 * screenWidth
        
        let finalHeight = (screenHeight * heightPer)/100
        let finalWidth = (screenWidth * widthPer)/100
        
        let bottomSpace = (screenHeight * 5)/100
        let sideSpace = Int((screenWidth * 5)/100)
        let topSpace = Int((screenHeight * 5)/100)
        let midX = Int(UIScreen.main.bounds.midX)
        let midY = Int(UIScreen.main.bounds.midY)
        
        let pipMoviePlayer = CGPiPMoviePlayer(pipType: CGPiPMoviePlayer.PiPType.compactPlayer)
        
        let pipMoviePlayerHeight = Int(heightPer)
        let pipMoviePlayerWidth = Int(widthPer)
        
        if pipInfo?.mobile.container.position == "BOTTOM-LEFT" {
            pipMoviePlayer.frame = CGRect(x: sideSpace, y: Int(screenHeight - (finalHeight + bottomSpace)), width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else if pipInfo?.mobile.container.position == "BOTTOM-RIGHT" {
            pipMoviePlayer.frame = CGRect(x: Int(screenWidth) - (Int(finalWidth) + sideSpace), y: Int(screenHeight - (finalHeight + bottomSpace)), width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else if pipInfo?.mobile.container.position == "BOTTOM-CENTER" {
            pipMoviePlayer.frame = CGRect(x: midX - (Int(finalWidth) / 2), y: Int(screenHeight - (finalHeight + bottomSpace)), width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else if pipInfo?.mobile.container.position == "TOP-LEFT" {
            pipMoviePlayer.frame = CGRect(x: sideSpace, y: topSpace, width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else if pipInfo?.mobile.container.position == "TOP-RIGHT" {
            pipMoviePlayer.frame = CGRect(x: Int(screenWidth) - (Int(finalWidth) + sideSpace), y: topSpace, width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else if pipInfo?.mobile.container.position == "TOP-CENTER" {
            pipMoviePlayer.frame = CGRect(x: midX - (Int(finalWidth) / 2), y: topSpace, width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else if pipInfo?.mobile.container.position == "CENTER-LEFT" {
            pipMoviePlayer.frame = CGRect(x: sideSpace, y: midY - (Int(finalHeight) / 2), width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else if pipInfo?.mobile.container.position == "CENTER-RIGHT" {
            pipMoviePlayer.frame = CGRect(x: Int(screenWidth) - (Int(finalWidth) + sideSpace), y: midY - (Int(finalHeight) / 2), width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else {
            pipMoviePlayer.frame = CGRect(x: midX - (Int(finalWidth) / 2), y: midY - (Int(finalHeight) / 2), width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        }
 
         pipMoviePlayer.contentMode = .scaleToFill
         pipMoviePlayer.clipsToBounds = true
         pipMoviePlayer.backgroundColor = UIColor.clear
         pipMoviePlayer.layer.shadowColor = UIColor.black.cgColor
         pipMoviePlayer.layer.shadowRadius = 3
         pipMoviePlayer.layer.shadowOpacity = 0.8
         pipMoviePlayer.layer.shadowOffset = CGSize.zero
         pipMoviePlayer.autoresizingMask = []
         pipMoviePlayer.delegate = self
    
         
         if pipInfo?.mobile.container.borderRadius != nil {
             let radius = NumberFormatter().number(from: (pipInfo?.mobile.container.borderRadius)!)
             pipMoviePlayer.layer.cornerRadius = radius as! CGFloat
             pipMoviePlayer.clipsToBounds = true
         }
         
         view.addSubview(pipMoviePlayer)
         self.view = view
         self.pipMediaPlayer = pipMoviePlayer
         window.pipMoviePlayer = pipMoviePlayer
        
        if(pipInfo?.mobile.conditions.draggable == true){
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
            pipMediaPlayer.addGestureRecognizer(panGesture)
        }
    }
    
    
    public func dismissPiPButton(is_remove: Bool){
        if CustomerGlu.getInstance.arrPIPViews.contains(self) {
            
            let finalPiPView = CustomerGlu.getInstance.popupDict.filter {
                $0._id == pipInfo?._id
            }
            if is_remove == true {
                // need to implement the converter
                CustomerGlu.getInstance.updateShowCount(showCount: finalPiPView[0], eventData: pipInfo!)
            }
            if let index = CustomerGlu.getInstance.arrFloatingButton.firstIndex(where: {$0 === self}) {
                CustomerGlu.getInstance.arrFloatingButton.remove(at: index)
                window.dismiss()
            }
        }
    }
    
    public func hidePiPButton(ishidden: Bool) {
//        window.pipMoviePlayer?.isHidden = ishidden
//        self.pipMediaPlayer.isHidden = ishidden
//        window.isUserInteractionEnabled = !ishidden
//        self.pipMediaPlayer.isUserInteractionEnabled = !ishidden
    }
    
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: pipMediaPlayer)
        pipMediaPlayer.center = CGPoint(x: pipMediaPlayer.center.x + translation.x, y: pipMediaPlayer.center.y + translation.y)
                sender.setTranslation(CGPoint.zero, in: pipMediaPlayer)
    }
    
    func onPiPCloseClicked() {
        self.removeFromParent()
    }
    
    func onPiPExpandClicked() {
        
    }
    
    func onPiPPlayerClicked() {
        
    }
    
    @objc func keyboardDidShow(note: NSNotification) {
        window.windowLevel = UIWindow.Level(rawValue: 0)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
    }
}

private class PiPWindow: UIWindow {
    
    var pipMoviePlayer: CGPiPMoviePlayer?
    
    init(){
        super.init(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            self.windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene)!
        }
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
        
    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            guard let pipMoviePlayer = pipMoviePlayer else {
                return false
                
            }
            let pipMoviePoint = convert(point, to: pipMoviePlayer)
            return pipMoviePlayer.point(inside: pipMoviePoint, with: event)
    }
    
}
