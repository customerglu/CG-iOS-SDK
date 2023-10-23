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
   
 
    var pipInfo: CGData?
  
    @IBOutlet weak var expandedViewCTA: UIButton!
    @IBOutlet weak var movieView: CGPiPMoviePlayer!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    init(btnInfo: CGData) {
        super.init(nibName: nil, bundle: nil)
        pipInfo = btnInfo
    }
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
