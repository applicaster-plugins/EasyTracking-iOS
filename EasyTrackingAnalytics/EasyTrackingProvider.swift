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
    private var lastIVWEvent: IVWEvent?
    
    private static var ivwEvents: [IVWEvent] = []
    private var predifinedEvents: [IVWEvent] {
        return EasyTrackingProvider.ivwEvents
    }
    
    public required init(configurationJSON: NSDictionary?) {
        super.init()
        self.configurationJSON = configurationJSON
        //Easy tracking init
        if let id = configurationJSON?["client_identifier"] as? String{
            EasyTracker.setup(with: id, trackers: [EchoTracker("googleAnalytics")], completion: { error in
                if (error == nil) {
                    EasyTracker.debug = true
                    if self.shouldTrackEvent {
                        EasyTracker.enable()
                    }
                }
            })
        }
        
        if EasyTrackingProvider.ivwEvents.isEmpty,
           let ivwEventConfiguration = configurationJSON?["ivw_config_json"] as? String,
           let ivwEventsJsonString = ivwEventConfiguration.data(using: .utf8),
           let ivwEvents = try? JSONDecoder().decode(IVWEvents.self, from: ivwEventsJsonString) {
            EasyTrackingProvider.ivwEvents = ivwEvents.events
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackScreenEventNotification(_:)),
                                               name: Notification.Name("logScreenEvent"),
                                               object: nil)
    }
    
    public required override init() {}
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name("logScreenEvent"),
                                                  object: nil)
    }
    
    public func getTrackPermission(){
        let dic = UserDefaults.standard.dictionary(forKey: "CMPConsents")
        if let canTrack = dic?["Google Analytics"] as? Bool{
            shouldTrackEvent = canTrack
        }
    }
    
    public func trackEvent(_ eventName: String, parameters: [String : NSObject], completion: ((Bool, String?) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            var modifiedParameters: [String: Any] = parameters
            
            if case let .screen(name, _, _) = self.lastIVWEvent {
                let event = self.predifinedEvents.first { (event) -> Bool in
                    guard case let .action(_, _, sourceEventNames) = event else {
                        return false
                    }
                    
                    return sourceEventNames.contains(where: { $0.isRegExMatched(to: name) })
                        && event.isRegExMatching(to: eventName)
                }
                
                if let code = event?.code {
                    modifiedParameters["marketingCategory"] = code
                }
            }
            
            if let isPlayerEvent = parameters["isPlayerEvent"] as? Bool,
               isPlayerEvent == true,
               let payload = modifiedParameters["payload"] as? String {
                EasyTracker.trackMediaEvent(name: eventName, payload: payload)
            } else {
                EasyTracker.trackEvent(name: eventName, payload: modifiedParameters)
            }
            
            completion?(true, nil)
        }
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
        DispatchQueue.global(qos: .userInitiated).async {
            var modifiedParameters: [String: Any] = parameters
            
            if let ivwEvent = self.predifinedEvents.first(where: { $0.isRegExMatching(to: screenName) }),
               case .screen(_, let code, let trackOnce) = ivwEvent {
                if let previousEvent = self.lastIVWEvent,
                   previousEvent == ivwEvent,
                   trackOnce {
                    return
                }
                
                modifiedParameters["marketingCategory"] = code
                self.lastIVWEvent = ivwEvent
            }
                
            EasyTracker.trackScreen(name: screenName, payload: modifiedParameters)
            
            completion?(true, nil)
        }
    }
    
    @objc private func trackScreenEventNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any],
           let eventName = userInfo["eventName"] as? String,
           let isScreenView = userInfo["screenView"] as? Bool,
           isScreenView == true {
            trackScreenView(eventName, parameters: [:], completion: nil)
        }
    }
  
}

struct IVWEvents: Decodable {
    let events: [IVWEvent]
}

enum IVWEvent: Decodable, Equatable {
    
    case screen(name: String, code: String, trackOnce: Bool)
    case action(name: String, code: String, sourceEventNames: [String])
    
    var code: String {
        switch self {
        case .action(_, let code, _),
             .screen(_, let code, _):
            return code
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case event = "event"
        case code = "code"
        case trackOnce = "track_once"
        case fromEvents = "from_events"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let event = try values.decode(String.self, forKey: .event)
        let code = try values.decode(String.self, forKey: .code)
        let trackOnce = (try? values.decode(Bool.self, forKey: .trackOnce)) ?? false
        let fromEvents = try? values.decode([String].self, forKey: .fromEvents)
        
        if let sourceEventNames = fromEvents {
            self = .action(name: event, code: code, sourceEventNames: sourceEventNames)
        } else {
            self = .screen(name: event, code: code, trackOnce: trackOnce)
        }
    }
    
    func isRegExMatching(to string: String) -> Bool {
        let name: String
        switch self {
        case .screen(let value, _, _),
             .action(let value, _, _):
            name = value
        }
        
        return string.isRegExMatched(to: name)
    }
}

private extension String {
    func isRegExMatched(to string: String) -> Bool {
        return self.lowercased().range(of: string.lowercased(),
                                       options: .regularExpression) != nil
    }
}
