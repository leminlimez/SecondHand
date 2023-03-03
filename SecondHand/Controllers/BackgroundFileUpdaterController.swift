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

struct BackgroundOption: Identifiable {
    var id = UUID()
    var key: String
    var title: String
    var enabled: Bool = true
}

class BackgroundFileUpdaterController: ObservableObject {
    static let shared = BackgroundFileUpdaterController()
    
    func setup() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            BackgroundFileUpdaterController.shared.updateTime()
        }
    }
    
    func stop() {
        // lol
    }
    
    func updateTime() {
        Task {
            // apply to the timer
            if UserDefaults.standard.bool(forKey: "IsEnabled") == true {
                let calendar = Calendar.current
                let date = Date()
                let hour = calendar.component(.hour, from: date)
                let minutes = calendar.component(.minute, from: date)
                let seconds = calendar.component(.second, from: date)
                
                StatusManager.sharedInstance().setTime("\(hour):\(minutes)\(seconds)")
            }
        }
    }
}
