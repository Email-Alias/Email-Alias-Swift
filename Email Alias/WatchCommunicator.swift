//
//  WatchCommunicator.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 23.02.24.
//

#if os(iOS)
import WatchConnectivity

final class WatchCommunicator: NSObject, WCSessionDelegate {
    static let shared = WatchCommunicator()
    
    private let session = WCSession.default
    
    private var cachedUserInfo: [String: Any]?
    
    func initialize() {
        session.delegate = self
    }
    
    func send(userInfo: [String: Any]) {
        if session.isPaired {
            if session.activationState == .activated {
                session.transferUserInfo(userInfo)
            }
            else {
                cachedUserInfo = userInfo
                session.activate()
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let cachedUserInfo {
            send(userInfo: cachedUserInfo)
            self.cachedUserInfo = nil
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
}
#endif
