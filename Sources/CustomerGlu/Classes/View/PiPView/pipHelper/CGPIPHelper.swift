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
        
        // User launches the pip First Time
        if pipSavedDate == nil
        {
            return true;
        }
        else{
            let date = Date()
            let df = DateFormatter()
            df.dateFormat = "dd"
            var day = df.string(from: date) as String
            
            
            
            if !day.elementsEqual(pipSavedDate ?? "")
            {
                //save as Date
                UserDefaults.standard.set(day, forKey: CGConstants.CG_PIP_DATE)
                return true
            }
        
            
           

          
//            let df = DateFormatter()
//            df.dateFormat = "dd/MM/yyyy HH:mm"
//            print(df.string(from: date))
            
            
            
        }
        
        return false;
    }
    
}
