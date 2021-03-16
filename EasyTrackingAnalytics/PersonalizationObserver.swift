//
//  PersonalizationObserver.swift
//  ZappATTPreparation
//
//  Created by Avi Levin on 14/03/2021.
//

import Foundation
import EasyTracking
import CMP

public class PersonalizationObserver: NSObject {
    static let shared = PersonalizationObserver()
    
    let CMP_VENDROID = "CMPVendorsKey"
    
    private var isSubscribed = false
    private var configurationJSON: NSDictionary?
    
    private override init() {
        super.init()
    }
    
    open override func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey : Any]?,
                                    context: UnsafeMutableRawPointer?) {
        if keyPath == CMP_VENDROID {
            EasyTracker.destroy()
            EasyTrackingHelper.EasyTrackingInit(with: self.configurationJSON)
        }
    }
    
    public func subscribe(with configurationJSON: NSDictionary?) {
        self.configurationJSON = configurationJSON
        
        if isSubscribed == false {
            UserDefaults.standard.addObserver(self,
                                              forKeyPath: CMP_VENDROID,
                                              options: .new,
                                              context: nil)
            
            isSubscribed = true
        }
    }
}
