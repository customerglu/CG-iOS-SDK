//
//  File.swift
//  CustomerGlu
//
//  Created by Hitesh on 23/12/22.
//

import Foundation

class CGFileDownloader {
    
    static func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            CustomerGlu.getInstance.printlog(cglog: String("File already exists [\(destinationUrl.path)]"), isException: false, methodName: "loadFileSync", posttoserver: false)
            completion(destinationUrl.path, nil)
        }
        else if let dataFromURL = NSData(contentsOf: url)
        {
            if dataFromURL.write(to: destinationUrl, atomically: true)
            {
                CustomerGlu.getInstance.printlog(cglog: String("file saved [\(destinationUrl.path)]"), isException: false, methodName: "loadFileSync", posttoserver: false)
                completion(destinationUrl.path, nil)
            }
            else
            {
                CustomerGlu.getInstance.printlog(cglog: String("error saving file"), isException: false, methodName: "loadFileSync", posttoserver: false)
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        }
        else
        {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, error)
        }
    }
    
    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        var documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentsUrl.appendPathComponent("GluFiles", isDirectory: true)
        
        do
        {
            try FileManager.default.createDirectory(atPath: documentsUrl.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error1 as NSError
        {
            completion(documentsUrl.path, error1)
        }
        
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        if FileManager().fileExists(atPath: destinationUrl.path)
        {
                do{
                    try FileManager().removeItem(atPath: destinationUrl.path)
                }catch{
                    
                }
        }
        
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
                                            {
                data, response, error in
                print("Lottie error ", error)
                if error == nil
                {
                    
                    if let response = response as? HTTPURLResponse
                    {
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                do
                                {
                                    try data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                    print("Lottie error ", error)

                                    completion(destinationUrl.path, error)
                                }
                                catch let error2 as NSError
                                {
                                    print("Lottie error ", error)
                                    completion(destinationUrl.path, error2)
                                }
                            }
                            else
                            {
                                print("Lottie error ", error)

                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                }
                else
                {
                    print("Lottie error ", error)
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        
    }
    
    static func loadPIPFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        var documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentsUrl.appendPathComponent("PIPFiles", isDirectory: true)
        
        do
        {
            try FileManager.default.createDirectory(atPath: documentsUrl.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error1 as NSError
        {
            completion(documentsUrl.path, error1)
        }
        
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        if FileManager().fileExists(atPath: destinationUrl.path)
        {
                do{
                    try FileManager().removeItem(atPath: destinationUrl.path)
                }catch{
                    
                }
        }
        
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
                                            {
                data, response, error in
                print("Lottie error ", error)
                if error == nil
                {
                    
                    if let response = response as? HTTPURLResponse
                    {
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                do
                                {
                                    try data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                    print("Lottie error ", error)

                                    completion(destinationUrl.path, error)
                                }
                                catch let error2 as NSError
                                {
                                    print("Lottie error ", error)
                                    completion(destinationUrl.path, error2)
                                }
                            }
                            else
                            {
                                print("Lottie error ", error)

                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                }
                else
                {
                    print("Lottie error ", error)
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        
    }
    
    
    
    static func deletePIPVideo()
    {
        var documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentsUrl.appendPathComponent("PIPFiles", isDirectory: true)
        
        // Check if the directory exists
        if FileManager.default.fileExists(atPath: documentsUrl.path) {
            do {
                // Attempt to remove the directory
                try FileManager.default.removeItem(at: documentsUrl)
                print("GluFiles directory deleted successfully.")
            } catch {
                // Handle the error if deletion fails
                print("Error deleting GluFiles directory: \(error.localizedDescription)")
            }
        } else {
            // If the directory doesn't exist, you can choose to handle it accordingly
            print("GluFiles directory does not exist.")
        }
    }

}
