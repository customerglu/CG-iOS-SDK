//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 30/08/24.
//

import Foundation

import UIKit

class NotchView: UIView {
    private var position: String
    private var notchColor: UIColor

    // Initializer to set the position and color of the notch
    init(frame: CGRect, position: String, color: UIColor) {
        self.position = position.uppercased() // Convert to uppercase for consistent checks
        self.notchColor = color
        super.init(frame: frame)
        self.backgroundColor = .clear // Make the background transparent
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Draw the notch based on the specified position
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Create a shape layer and a path
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath()
        
        if position == "TOP" {
            // Draw the notch at the top
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        } else if position == "BOTTOM" {
            // Draw the notch at the bottom
            path.move(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width / 2, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        }
        
        // Close the path and set the shape's color
        path.close()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = notchColor.cgColor
        
        // Add the shape layer to the view
        self.layer.addSublayer(shapeLayer)
    }
}
