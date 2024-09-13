//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 28/08/24.
//

import Foundation

import UIKit

class TransparentViewController: UIViewController {
    
    // Properties to control opacity, and button position
    var buttonOpacity: CGFloat = 0.5
    var buttonXPosition: CGFloat = 0
    var buttonYPosition: CGFloat = 0
    var centerXposition: CGFloat = 0
    var maxXposition: CGFloat = 0
    var maxYposition: CGFloat = 0
    var anchoredviewHeight: CGFloat = 0
    var anchoredviewWidth: CGFloat = 0
    var tooltipController: FloatingTooltipController?
    var highlightOverlayView: HighlightOverlayView!

    // Initialize the view controller with specific parameters
    init(opacity: CGFloat, buttonX: CGFloat, buttonY: CGFloat,centerX:CGFloat,maxXAxis:CGFloat,maxyAxis:CGFloat,anchorviewHeight: CGFloat,anchorviewWidth:CGFloat) {
        super.init(nibName: nil, bundle: nil)
        self.buttonOpacity = opacity
        self.buttonXPosition = buttonX
        self.buttonYPosition = buttonY
        self.centerXposition = centerX
        self.maxXposition = maxXAxis
        self.maxYposition = maxyAxis
        self.anchoredviewHeight = anchorviewHeight
        self.anchoredviewWidth = anchorviewWidth
        self.modalPresentationStyle = .overFullScreen
        let black = UIColor.black
//        let blackTrans = UIColor.withAlphaComponent(black)(CGFloat(0.2))
//        self.view.backgroundColor = blackTrans// To overlay on top of other views
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotch()
        addHighlighter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            tooltipController = FloatingTooltipController(tooltipText: "Keep track of items you like",position: "ABSOLUTE",xAxis: self.buttonXPosition,yAxis: self.buttonYPosition - 16,isNotchShown: false)
            tooltipController?.showTooltip()
        }
        // Configure the button
        
    }
    
    private func addHighlighter()
    {
        let highlightFrame = CGRect(x: buttonXPosition, y: buttonYPosition, width: anchoredviewWidth, height: anchoredviewHeight)

                // Initialize and add the highlight overlay view
                highlightOverlayView = HighlightOverlayView(highlightFrame: highlightFrame)
                highlightOverlayView.frame = self.view.bounds
                self.view.addSubview(highlightOverlayView)
    }
    
    private func addNotch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            let notchWidth: CGFloat = 16
               let notchHeight: CGFloat = 16

               // Create the notch view and position it based on button coordinates
               let notchView = NotchView(
                   frame: CGRect(x: centerXposition , y: buttonYPosition - notchHeight, width: notchWidth, height: notchHeight),
                   position: "TOP", // Change to "BOTTOM" if you need the notch at the bottom
                   color: UIColor.darkGray // Set the desired notch color
               )
               self.view.addSubview(notchView)
        }
        }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.tooltipController?.dismissTooltip()
        self.closePage(animated: false)
    }
    
    private func closePage(animated: Bool){
        self.dismiss(animated: animated) {
            CustomerGlu.getInstance.showFloatingButtons()
        }
    }
    // Function to set up the button with position and opacity
 
}

class HighlightOverlayView: UIView {
    
    var highlightFrame: CGRect = .zero
    
    init(highlightFrame: CGRect) {
        super.init(frame: .zero)
        self.highlightFrame = highlightFrame
        self.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Fill the entire view with a semi-transparent overlay color
        context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        context.fill(rect)
        
        // Create a transparent cutout area for the highlight
        let cutoutPath = UIBezierPath(roundedRect: highlightFrame, cornerRadius: 8)
        context.addPath(cutoutPath.cgPath)
        context.setBlendMode(.clear)
        context.fillPath()
        
        
    }
}
