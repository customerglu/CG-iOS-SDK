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
        
        
        let bottomSpace = (screenHeight * 5)/100
        let sideSpace = Int((screenWidth * 5)/100)
        let topSpace = Int((screenHeight * 5)/100)
        
        let pipMoviePlayer = CGPiPMoviePlayer(pipType: CGPiPMoviePlayer.PiPType.compactPlayer)
        pipMoviePlayer.backgroundColor = .black
        
        let pipMoviePlayerHeight = Int(heightPer)
        let pipMoviePlayerWidth = Int(widthPer)
    
        
        if pipInfo?.mobile.container.position == "BOTTOM-LEFT" {
            pipMoviePlayer.frame = CGRect(x: sideSpace, y: Int(screenHeight - (CGFloat(pipMoviePlayerHeight) + bottomSpace)), width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else if pipInfo?.mobile.container.position == "BOTTOM-RIGHT" {
            pipMoviePlayer.frame = CGRect(x: Int(screenWidth - CGFloat(pipMoviePlayerWidth) + CGFloat(sideSpace)), y: Int(screenHeight - (CGFloat(pipMoviePlayerHeight) + bottomSpace)), width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        }  else if pipInfo?.mobile.container.position == "TOP-LEFT" {
            pipMoviePlayer.frame = CGRect(x: sideSpace, y: topSpace, width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else if pipInfo?.mobile.container.position == "TOP-RIGHT" {
            pipMoviePlayer.frame = CGRect(x: Int(CGFloat(screenWidth) - (CGFloat(pipMoviePlayerWidth) + CGFloat(sideSpace))), y: topSpace, width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else {
            pipMoviePlayer.frame = CGRect(x: sideSpace, y: Int(screenHeight - (CGFloat(pipMoviePlayerHeight) + bottomSpace)), width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        }
 
         pipMoviePlayer.contentMode = .scaleToFill
         pipMoviePlayer.clipsToBounds = true
         pipMoviePlayer.backgroundColor = UIColor.black
        pipMoviePlayer.layer.shadowColor = UIColor.black.cgColor
         pipMoviePlayer.layer.shadowRadius = 3
         pipMoviePlayer.layer.shadowOpacity = 1
         pipMoviePlayer.layer.cornerRadius = 8
         pipMoviePlayer.layer.shadowOffset = CGSize(width: 15, height: 15)
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
        window.pipMoviePlayer?.isHidden = ishidden
        self.pipMediaPlayer.isHidden = ishidden
        window.isUserInteractionEnabled = !ishidden
        self.pipMediaPlayer.isUserInteractionEnabled = !ishidden
    }
    
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        
        if let pipMediSuperView  = pipMediaPlayer.superview {
            let point: CGPoint = sender.location(in: pipMediSuperView)
            
            let boundsRect = CGRect(x: pipMediSuperView.bounds.origin.x - 50 , y: pipMediSuperView.bounds.origin.y - 50, width: pipMediSuperView.frame.width , height: pipMediSuperView.frame.height)
            
            if boundsRect.contains(point) {
                pipMediaPlayer.center = point
            }
        }
        
//        let translation = sender.translation(in: pipMediaPlayer)
//        if pipMediaPlayer.superview!.bounds.contains(pipMediaPlayer.frame)
//        {
//            pipMediaPlayer.center = CGPoint(x: pipMediaPlayer.center.x + translation.x, y: pipMediaPlayer.center.y + translation.y)
//            sender.setTranslation(CGPoint.zero, in: pipMediaPlayer)
//        }
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
    
    override func viewDidLayoutSubviews() {
        pipMediaPlayer.setupFrame()
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
        pipMoviePlayer?.backgroundColor = .black
        pipMoviePlayer?.layer.cornerRadius = 8
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
