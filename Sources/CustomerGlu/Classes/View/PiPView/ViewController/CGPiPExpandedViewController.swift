//
//  CGPiPViewController.swift
//  
//
//  Created by Kausthubh adhikari on 15/10/23.
//

import Foundation
import UIKit

/***
    - Implement Simple Dragable view
    - Setup tab and click listener
 
 
 */

class CGPiPExpandedViewController : UIViewController, CGPiPMoviePlayerProtocol {
   
 
    
    
    var floatInfo: CGData?
  
    @IBOutlet weak var expandedViewCTA: UIButton!
    @IBOutlet weak var movieView: CGPiPMoviePlayer!
    
    override func loadView() {
        movieView.delegate = self
    }

    func onPiPCloseClicked() {
        dismiss(animated: true)
    }
    
    func onPiPExpandClicked() {
        dismiss(animated: true)
    }
    func onPiPPlayerClicked() {
    
    }
    @IBAction func onPiPCTAClicked(_ sender: Any) {
        
    }
    
}
