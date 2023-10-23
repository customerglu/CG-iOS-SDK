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
        
        var pipSavedDate =  CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CG_PIP_DATE) ?? "NA"
        
        // User launches the pip First Time
        if pipSavedDate.isEmpty || pipSavedDate == "NA"
        {
            return true;
        }else{
            let date = Date()
            
            
        }
        
        return false;
    }
}
