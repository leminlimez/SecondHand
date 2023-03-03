//
//  BackgroundFileUpdaterController.swift
//  Cowabunga
//
//  Created by lemin on 1/17/23.
//

// credits to sourcelocation and Evyrest

import Foundation
import SwiftUI
import notify
import SystemConfiguration
import Combine

struct BackgroundOption: Identifiable {
    var id = UUID()
    var key: String
    var title: String
    var enabled: Bool = true
}

class BackgroundFileUpdaterController: ObservableObject {
    static let shared = BackgroundFileUpdaterController()
    public var time = 3600.0
    public var timer: Timer? = nil
    
    func setup() {
        startTimer()
    }
    
    func startTimer() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: time, repeats: true) { timer in
            BackgroundFileUpdaterController.shared.updateTime()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func restartTimer() {
        stopTimer()
        startTimer()
    }
    
    func stop() {
        // lol
    }
    
    func updateTime() {
        Task {
            // apply to the timer
            if UserDefaults.standard.bool(forKey: "TimeIsEnabled") == true {
                setTimeSeconds()
            }
            
            // apply to breadcrumb
            if UserDefaults.standard.bool(forKey: "DateIsEnabled") == true {
                setCrumbDate()
            }
        }
    }
}
