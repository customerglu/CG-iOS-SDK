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
    var is50Completd = false;
    var is25Completd = false;
    var is75Completd = false;
    
    func setIs25Completed(value:Bool){
        is25Completd = value
    }
    func setIs75Completed(value:Bool){
        is75Completd = value
    }
    func setIs50Completed(value:Bool){
        is50Completd = value
    }
    func get75Competed() -> Bool {
        return is75Completd
    }
    func get25Competed() -> Bool {
        return is25Completd
    }
    
    func get50Competed() -> Bool {
        return is50Completd
    }
    func  checkShowOnDailyRefresh() -> Bool
    {        
        if isDismmissed
        {
            return false;
        }
        
        var pipSavedDate =   UserDefaults.standard.string(forKey: CGConstants.CG_PIP_DATE)
        let currentDate = Date.getCurrentDate()
        
        // User launches the pip First Time
        if pipSavedDate == nil, ((pipSavedDate?.isEmpty) != nil)
        {
                return true;
        }
        else{
            if !currentDate.elementsEqual(pipSavedDate ?? "")
            {
                return true
            }
            
            
        }
        
        return false;
    }
    
    
    func setDailyRefresh(){
        let currentDate = Date.getCurrentDate()
        UserDefaults.standard.set(currentDate, forKey: CGConstants.CG_PIP_DATE)
    }
    
    
    func allowdVideoRefreshed() -> Bool {
        var pipvVidSavedDate =   UserDefaults.standard.string(forKey: CGConstants.CG_PIP_VID_SYNC_DATA)
        
        let currentDate = Date.getCurrentDate()
        // User launches the pip First Time
        if pipvVidSavedDate == nil, ((pipvVidSavedDate?.isEmpty) != nil)
        {
                UserDefaults.standard.set(currentDate, forKey: CGConstants.CG_PIP_VID_SYNC_DATA)
                return true;
        }
        else{
            if !currentDate.elementsEqual(pipvVidSavedDate ?? "")
            {
                //save as Date
                UserDefaults.standard.set(currentDate, forKey: CGConstants.CG_PIP_VID_SYNC_DATA)
                return true
            }
            
            
        }
        
        return false;
    }
    
}

