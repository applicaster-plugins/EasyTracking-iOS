//
//  EasyTrackingHelper.swift
//  EasyTrackingAnalytics
//
//  Created by Avi Levin on 16/03/2021.
//

import Foundation
import EasyTracking
import CMP

struct EasyTrackingHelper {
    static var shouldTrackEvent = true
    
    static func EasyTrackingInit(with configurationJSON: NSDictionary?) {
        guard let id = configurationJSON?["client_identifier"] as? String else {
            return
        }
        
        EasyTracker.autoLoadTrackers = false
        let trackersArray = [IVWTracker(),
                             EchoTracker("ivw"),
                             GoogleAnalyticsTrackerSDK(),
                             NuragoTracker(),
                             MixpanelTracker()]
        
        EasyTracker.setup(with: id,
                          trackers: trackersArray) { (error) in
            if error == nil,
               shouldTrackEvent == true {
                
                let debugModeString = configurationJSON?["debug_mode"] as? NSString
                EasyTracker.debug = debugModeString?.boolValue ?? false
            }
        }
        
        //Pass the CMP vendors array to EasyTracking
        let vendors = ConsentManagerImplementation.shared.vendors
        EasyTracker.enableWithVendorList(vendors)
        
        //Parsing IVW Event List from Plugin Configurations
        EasyTrackingProvider.ivwEvents = EasyTrackingProvider.getIVWEvents(with: configurationJSON)
    }
}
