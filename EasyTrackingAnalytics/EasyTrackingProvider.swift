//
// EasyTrackingProvider.swift
// EasyTrackingProvider
//
// Created by Roei on 20/05/2020.
//
import Foundation
import ZappPlugins
import EasyTracking

@objc public class EasyTrackingProvider: NSObject, ZPAnalyticsProviderProtocol {
   
    public var configurationJSON: NSDictionary?
    private var shouldTrackEvent = true
    
    public required init(configurationJSON: NSDictionary?) {
        super.init()
        self.configurationJSON = configurationJSON
        //Easy tracking init
        if let id = configurationJSON?["client_identifier"] as? String{
            EasyTracker.setup(with: id, trackers: [EchoTracker("googleAnalytics")], completion: { error in
                if (error == nil){
                    EasyTracker.debug = true
                    if(self.shouldTrackEvent){
                        EasyTracker.enable()
                    }
                }
            })
        }
    }
    
    public required override init() {}
    
    public func getTrackPermission(){
        let dic = UserDefaults.standard.dictionary(forKey: "CMPConsents")
        if let canTrack = dic?["Google Analytics"] as? Bool{
            shouldTrackEvent = canTrack
        }
    }
    
    public func trackEvent(_ eventName: String, parameters: [String : NSObject], completion: ((Bool, String?) -> Void)?) {
        EasyTracker.trackEvent(name: eventName, payload: parameters)
    }
    
    public func presentToastForLoggedEvent(_ eventDescription: String?) {
        
    }
    
    public func canPresentToastForLoggedEvents() -> Bool {
        return false
    }
    
    public func shouldTrackEvent(_ eventName: String) -> Bool {
        return true
    }
    
    public func analyticsMaxParametersAllowed() -> Int {
        return 100
    }
    
    public func setBaseParameter(_ value: NSObject?, forKey key: String) {
        
    }
    
    public func sortPropertiesAlphabeticallyAndCutThemByLimitation(_ properties: [String : NSObject]) -> [String : NSObject] {
        return ["":NSObject()]
    }
    
    public func createAnalyticsProvider(_ allProvidersSetting: [String : NSObject]) -> Bool {
        return true
    }
    
    public func configureProvider() -> Bool {
        return true
    }
    
    public func getKey() -> String {
        return ""
    }
    
    public func updateGenericUserProperties(_ genericUserProfile: [String : NSObject]) {
        
    }
    
    public func updateDefaultEventProperties(_ eventProperties: [String : NSObject]) {
        
    }
    
    public func trackScreenView(_ screenName: String, parameters: [String : NSObject], completion: ((Bool, String?) -> Void)?) {
        EasyTracker.trackScreen(name: screenName, payload: parameters)
    }
  
}
