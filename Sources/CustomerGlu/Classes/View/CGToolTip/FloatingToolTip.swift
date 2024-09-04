//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 26/08/24.
//

import Foundation

import UIKit
import Foundation
import CustomerGlu
public class FloatingTooltipController: UIViewController {
    
    private(set) var tooltipView: CGTooltipView!
    var viewPosition: String?
    private var dismissTimer: Timer?
    private var x: CGFloat?
    private var y: CGFloat?
    private var isNotchvisible: Bool = true

    private var window = TooltipWindow()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public init(tooltipText: String, position: String, xAxis: CGFloat? = 0.0, yAxis: CGFloat? = 0.0, isNotchShown: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewPosition = position
        self.x = xAxis
        self.y = yAxis
        self.isNotchvisible = isNotchShown
        // Set the window properties
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = false
        window.rootViewController = self
        
        // Initialize the CGTooltipView
        let tooltipView = CGTooltipView(heading: "Tips for the Day",text: tooltipText,isNotchShown: self.isNotchvisible)
        self.tooltipView = tooltipView
        window.tooltipView = tooltipView
        
        self.view = UIView()
        self.view.addSubview(tooltipView)
    }
    
   public override func loadView() {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        self.view = view
    }
    
   public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionTooltip()
    }
    
    private func positionTooltip() {
        guard let tooltipView = tooltipView else { return }
        
        let screenBounds = UIScreen.main.bounds
        let screenHeight = Int(screenBounds.height)
        let screenWidth = Int(screenBounds.width)
        
        // Adjust the size of the CGTooltipView based on the text content
        tooltipView.adjustSize(forWidth: CGFloat(screenWidth))
        tooltipView.setNeedsLayout()
        tooltipView.layoutIfNeeded()
        let finalHeight = tooltipView.frame.height
          let finalWidth = tooltipView.frame.width
        // Use safe area insets to account for areas like the notch
        let safeAreaInsets = view.safeAreaInsets
        
        let bottomSpace = Int(safeAreaInsets.bottom)
        let sideSpace = Int(safeAreaInsets.left)
        let topSpace = Int((screenHeight * 5) / 100)
        let midX = Int(screenBounds.midX)
        let midY = Int(screenBounds.midY)
        
        // Position the tooltip based on the specified position
        switch viewPosition {
        case "BOTTOM-LEFT":
            tooltipView.frame.origin = CGPoint(x: sideSpace, y: screenHeight - Int(finalHeight) - bottomSpace)
        case "BOTTOM-RIGHT":
            tooltipView.frame.origin = CGPoint(x: screenWidth - Int(finalWidth) - sideSpace, y: screenHeight - Int(finalHeight) - bottomSpace)
        case "BOTTOM-CENTER":
            tooltipView.frame.origin = CGPoint(x: midX - Int(finalWidth) / 2, y: screenHeight - Int(finalHeight) - bottomSpace)
        case "TOP-LEFT":
            tooltipView.frame.origin = CGPoint(x: sideSpace, y: topSpace)
        case "TOP-RIGHT":
            tooltipView.frame.origin = CGPoint(x: screenWidth - Int(finalWidth) - sideSpace, y: topSpace)
        case "TOP-CENTER":
            tooltipView.frame.origin = CGPoint(x: midX - Int(finalWidth) / 2, y: topSpace)
        case "CENTER-LEFT":
            tooltipView.frame.origin = CGPoint(x: sideSpace, y: midY - Int(finalHeight) / 2)
        case "CENTER-RIGHT":
            tooltipView.frame.origin = CGPoint(x: screenWidth - Int(finalWidth) - sideSpace, y: midY - Int(finalHeight) / 2)
        case "PERCENTAGE":
            tooltipView.frame.origin = CGPoint(x: CGFloat(screenWidth) * 0.05, y: CGFloat(screenHeight) * 0.20)
        case "ABSOLUTE":
            calculatePosition(finalHeight: finalHeight, finalWidth: finalWidth, x: self.x, y: self.y)
        default:
            tooltipView.frame.origin = CGPoint(x: midX - Int(finalWidth) / 2, y: midY - Int(finalHeight) / 2)
        }
    }
    
    private func calculatePosition(finalHeight:CGFloat,finalWidth:CGFloat, x:CGFloat?, y:CGFloat?)
    {
        print("finalWidth",finalWidth)
        print("UI Bounds X", UIScreen.main.bounds.maxX)
        print("UI Bounds Y", UIScreen.main.bounds.maxY)
        
        var maxWidth = UIScreen.main.bounds.maxX - 20
        
        


        var newX = x! + finalWidth;
        print("newX",newX)

        if newX > maxWidth {
            newX = x! - abs(newX - maxWidth)
            print("newX new",newX)

            tooltipView.frame.origin = CGPoint(x: newX, y: y! - finalHeight)
        }else{
            tooltipView.frame.origin = CGPoint(x: x!, y: y! - finalHeight)
        }
        
        

    }
    
    public func showTooltip() {
         tooltipView.isHidden = false
         window.isHidden = false
         
         // Start the timer to dismiss after 5 seconds
        // startDismissTimer()
     }
     
     private func startDismissTimer() {
         // Invalidate any existing timer
         dismissTimer?.invalidate()
         
         // Schedule a new timer
         dismissTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(dismissTooltip), userInfo: nil, repeats: false)
     }
     
     @objc public func dismissTooltip() {
         hideTooltip(ishidden: true)
     }
     
     public func hideTooltip(ishidden: Bool) {
         tooltipView.isHidden = ishidden
         window.isUserInteractionEnabled = !ishidden
         
         // Invalidate the timer when tooltip is manually hidden
         dismissTimer?.invalidate()
         dismissTimer = nil
     }
     
     @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
         
         hideTooltip(ishidden: true)
     }
}

private class TooltipWindow: UIWindow {
    
    var tooltipView: UIView?
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            self.windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene)!
        }
        backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let tooltipView = tooltipView else {
            return false
        }
        let tooltipViewPoint = convert(point, to: tooltipView)
        return tooltipView.point(inside: tooltipViewPoint, with: event)
    }
}


