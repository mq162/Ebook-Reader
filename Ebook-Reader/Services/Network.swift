//
//  Network.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import Reachability
import Foundation

class Network {
    
    enum NetworkState: Int {
        case wifi
        case cellular
        case unavailable
    }
    
    static let shared: Network = Network()
    
    let reachability = try! Reachability()
    var networkState = NetworkState.unavailable
    
    func startNotifier() {
        addNotifications()
        do{
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    func stopNotifier() {
        reachability.stopNotifier()
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    }
    
    @objc private func reachabilityChanged(note: Notification) {

        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            networkState = .wifi
            print("Reachable via WiFi")
        case .cellular:
            networkState = .cellular
            print("Reachable via Cellular")
        case .unavailable:
            networkState = .unavailable
            print("Network not reachable")
        case .none:
            print("Network connection unknown")
        }
        NotificationCenter.default.post(name: .networkStateChanged, object: self, userInfo: nil)
    }
}
