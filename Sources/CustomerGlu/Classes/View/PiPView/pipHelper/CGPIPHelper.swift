//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 23/10/23.
//

import Foundation

class CGPIPHelper : NSObject {
    static let shared = CGPIPHelper()
    var isDismmissed = false;
    
    
    func  checkShowOnDailyRefresh() -> Bool
    {
        if isDismmissed
        {
            return false;
        }
        
        var pipSavedDate =   UserDefaults.standard.object(forKey: CGConstants.CG_PIP_DATE) as? String
        let date = Date()
        let df = DateFormatter()
        var day = df.string(from: date) as String
        
        // User launches the pip First Time
        if pipSavedDate == nil
        {
          
            UserDefaults.standard.set(day, forKey: CGConstants.CG_PIP_DATE)
            return true;
        }
        else{
            
            if !day.elementsEqual(pipSavedDate ?? "")
            {
                //save as Date
                UserDefaults.standard.set(day, forKey: CGConstants.CG_PIP_DATE)
                return true
            }
            
            
        }
        
        return false;
    }
    
}
