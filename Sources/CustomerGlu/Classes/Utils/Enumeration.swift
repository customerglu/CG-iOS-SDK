//
//  File.swift
//
//
//  Created by kapil on 04/11/21.
//

import Foundation
import UIKit

#if !SPM
extension Bundle {
    static var module:Bundle { Bundle(identifier: "org.cocoapods.CustomerGlu") ?? Bundle(for: CustomerGlu.self) }
}
#endif

#if SPM

import class Foundation.Bundle

private class BundleFinder {}

extension Bundle {
    static var modulee: Bundle = {
            let bundleName = "CustomerGlu"

            let candidates = [
                // Bundle should be present here when the package is linked into an App.
                Bundle.main.resourceURL,

                // Bundle should be present here when the package is linked into a framework.
                Bundle(for: BundleFinder.self).resourceURL,

                // For command-line tools.
                Bundle.main.bundleURL,
            ]

            for candidate in candidates {
                let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
                if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                    return bundle
                }
            }
        }()
}
#endif

protocol StoryboardIdentifiable where Self: UIViewController {
    static func getInstance(storyBoardType: StoryboardType) -> UIViewController
}

enum StoryboardType: String {
    
    case main = "Storyboard"
    
    func instance() -> UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: .module)
    }
    
    func instantiate<VC: UIViewController>(vcType: VC.Type) -> VC {
        return (instance().instantiateViewController(withIdentifier: String(describing: vcType.self)) as? VC)!
    }
}
