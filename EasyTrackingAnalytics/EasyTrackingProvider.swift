//
// EasyTrackingProvider.swift
// EasyTrackingProvider
//
// Created by Roei on 20/05/2020.
//
import Foundation
import ZappPlugins
import EasyTracking

@objc public class EasyTrackingProvider: NSObject, AnalyticsProviderProtocol {
    
    let IVW_CODE = "marketingCategory"
    
    public var model: ZPPluginModel?
    public var providerName: String = ""
    public var configurationJSON: NSDictionary?
    private var shouldTrackEvent = true
    private var lastScreenEvent: String?
    private static var ivwEvents: [IVWEvent] = []
    
    public required init(configurationJSON: NSDictionary?) {
        super.init()
        self.configurationJSON = configurationJSON
        //Easy tracking init
        if let id = configurationJSON?["client_identifier"] as? String {
            EasyTracker.autoLoadTrackers = false
            EasyTracker.setup(with: id, trackers: [IVWTracker(),
                                                   EchoTracker("ivw"),
                                                   GoogleAnalyticsTrackerSDK(),
                                                   NuragoTracker(),
                                                   MixpanelTracker()]) { [weak self] (error) in
                if error == nil, self?.shouldTrackEvent == true {
                    EasyTracker.enable {
                        let debugModeString = configurationJSON?["debug_mode"] as? NSString
                        let isDebugEnabled = debugModeString?.boolValue ?? false
                        EasyTracker.debug = isDebugEnabled
                        
                    }
                }
            }
        }
        
        //Parsing IVW Event List from Plugin Configurations
        EasyTrackingProvider.ivwEvents = getIVWEvents()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackScreenEventNotification(_:)),
                                               name: Notification.Name("logScreenEvent"),
                                               object: nil)
    }
    
    public required init(pluginModel: ZPPluginModel) {
        
    }
    
    public required override init() {}
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name("logScreenEvent"),
                                                  object: nil)
    }
    
    public func getTrackPermission() {
        let dic = UserDefaults.standard.dictionary(forKey: "CMPConsents")
        if let canTrack = dic?["Google Analytics"] as? Bool{
            shouldTrackEvent = canTrack
        }
    }

    public func sendEvent(_ eventName: String, parameters: [String: Any]?) {
        var parametersToPass: [String: NSObject] = [:]
        if let parameters = parameters as? [String: NSObject] {
            parametersToPass = parameters
        }
        trackEvent(eventName, parameters: parametersToPass, completion: nil)
    }

    public func sendScreenEvent(_ screenName: String, parameters: [String: Any]?) {
        var parametersToPass: [String: NSObject] = [:]
        if let parameters = parameters as? [String: NSObject] {
            parametersToPass = parameters
        }
        trackScreenView(screenName, parameters: parametersToPass, completion: nil)
    }

    @objc public func startObserveTimedEvent(_ eventName: String, parameters: [String: Any]?) {
        trackEvent(eventName, timed: true)
    }

    @objc public func stopObserveTimedEvent(_ eventName: String, parameters: [String: Any]?) {
        var parametersToPass: [String: NSObject] = [:]
        if let parameters = parameters as? [String: NSObject] {
            parametersToPass = parameters
        }
        endTimedEvent(eventName, parameters: parametersToPass)
        
    }
    
    @objc public func trackEvent(_ eventName:String, timed:Bool) {
        
    }
    
    @objc public func endTimedEvent(_ eventName:String, parameters:[String:NSObject]) {
        
    }
    
    public func trackEvent(_ eventName: String, parameters: [String : NSObject], completion: ((Bool, String?) -> Void)?) {
        var modifiedParameters: [String: Any] = parameters
        
        //If necessary add IVW code
        modifiedParameters = self.addIVWCode(event: eventName,
                                             parameters: parameters,
                                             eventType: .Action)
        
        if let isPlayerEvent = parameters["isPlayerEvent"] as? Bool,
           isPlayerEvent == true,
           let payload = modifiedParameters["payload"] as? String {
            EasyTracker.trackMediaEvent(name: eventName, payload: payload)
        } else {
            EasyTracker.trackEvent(name: eventName, payload: modifiedParameters)
        }
        
        completion?(true, nil)
    }

    public func trackScreenView(_ screenName: String, parameters: [String : NSObject], completion: ((Bool, String?) -> Void)?) {
        
        var modifiedParameters: [String: Any] = parameters
        
        //If necessary add IVW code
        modifiedParameters = self.addIVWCode(event: screenName,
                                             parameters: parameters,
                                             eventType: .Screen)
        
        EasyTracker.trackScreen(name: screenName, payload: modifiedParameters)
        
        //Update screen name
        self.lastScreenEvent = screenName
        
        completion?(true, nil)
    }
    
    @objc private func trackScreenEventNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any],
           let eventName = userInfo["eventName"] as? String,
           let isScreenView = userInfo["screenView"] as? Bool,
           isScreenView == true {
            trackScreenView(eventName, parameters: [:], completion: nil)
        }
    }
    
    public func prepareProvider(_ defaultParams: [String : Any], completion: ((Bool) -> Void)?) {
        
    }
    
    public func disable(completion: ((Bool) -> Void)?) {
        
    }
    
    // MARK: IVW Logic
    enum EventType {
        case Screen
        case Action
    }
    
    func getIVWEvents() -> [IVWEvent] {
        guard let json = configurationJSON?["ivw_config_json"] as? String else {
            return []
        }
        
        let decoder = JSONDecoder()
        
        guard let jsonData = json.data(using: .utf8) else {
            return []
        }
        
        do {
            let decode = try decoder.decode(IVWEvents.self, from: jsonData)
            return decode.events
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func addIVWCode(event: String, parameters: [String : NSObject], eventType: EventType) -> [String: Any] {
        
        var modifiedParameters: [String: Any] = parameters
        
        if !EasyTrackingProvider.ivwEvents.isEmpty {
            guard let ivwEvent = findIVWEventRegex(eventName: event) else {
                return modifiedParameters
            }
            
            //Screen
            if isNotMatchTrackOnceRule(currentEventName: event, ivwEvent: ivwEvent, eventType: eventType) //Screen
                || isMatchFromEventRule(event: ivwEvent, eventType: eventType) {//Action {
                //Add IVW code
                modifiedParameters[IVW_CODE] = ivwEvent.code
            }
            
            
            return modifiedParameters
            
        } else {
            return modifiedParameters
        }
    }
    
    func findIVWEventRegex(eventName: String) -> IVWEvent? {
        return EasyTrackingProvider.ivwEvents.first{ (ivwEvent) -> Bool in
            return isRegExMatch(event: eventName, regEx: ivwEvent.event)
        }
    }
    
    func isRegExMatch(event:String, regEx:String) -> Bool {
        let eventLowerCase = event.lowercased()
        let regExLowerCase = regEx.lowercased()
        
        return eventLowerCase.range(of: regExLowerCase.lowercased(),
                                    options: .regularExpression) != nil
    }
    
    private func isNotMatchTrackOnceRule(currentEventName:String, ivwEvent: IVWEvent, eventType: EventType) -> Bool {
        if eventType != .Screen && isScreenEvent(event: ivwEvent){
            return false
        }
        
        return ((ivwEvent.trackOnce == nil)
                    || ivwEvent.trackOnce == false
                    || (ivwEvent.trackOnce == true &&
                            self.lastScreenEvent != nil &&
                            currentEventName != self.lastScreenEvent))
    }
    
    //For actions only
    private func isMatchFromEventRule(event: IVWEvent, eventType: EventType) -> Bool {
        if eventType != .Action {
            return false
        }
        
        guard let fromEventList = event.fromEvents,
              let lastScreenEvent = self.lastScreenEvent else {
            return false
        }
        
        return ((fromEventList.first{ (fromEvent) -> Bool in
            isRegExMatch(event: lastScreenEvent, regEx: fromEvent)
        }) != nil)
    }
    
    private func isActionEvent(event: IVWEvent) -> Bool {
        guard let fromEvent = event.fromEvents else {
            return false
        }
        
        return !fromEvent.isEmpty
    }
    
    private func isScreenEvent(event: IVWEvent) -> Bool {
        return !isActionEvent(event: event)
    }
}
