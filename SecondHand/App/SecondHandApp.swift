//
//  SecondHandApp.swift
//  SecondHand
//
//  Created by lemin on 3/2/23.
//

import SwiftUI
import Darwin

@main
struct SecondHandApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear {
                checkAndEscape()
                
                // credit: TrollTools
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/leminlimez/SecondHand/releases/latest") {
                    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                        guard let data = data else { return }
                        
                        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                            if (json["tag_name"] as? String)?.compare(version, options: .numeric) == .orderedDescending {
                                UIApplication.shared.confirmAlert(title: "Update available", body: "SecondHand version \(json["tag_name"] as? String ?? "update") is available, do you want to visit releases page?", onOK: {
                                    UIApplication.shared.open(URL(string: "https://github.com/leminlimez/SecondHand/releases/latest")!)
                                }, noCancel: false)
                            }
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    func checkAndEscape() {
    #if targetEnvironment(simulator)
            StatusManager.sharedInstance().setIsMDCMode(false)
    #else
        var supported = false
        if #unavailable(iOS 15.6.1) {
            supported = true
        }
        
        if !supported {
            UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported. Please close the app.", withButton: false)
        } else {
            getRootFS(needsTrollStore: true)
        }
    #endif
    }
    
    func getRootFS(needsTrollStore: Bool) {
            do {
                // Check if application is entitled
                try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile"), includingPropertiesForKeys: nil)
                if UserDefaults.standard.bool(forKey: "ForceMDC") {
                    throw "Forced MDC"
                } else {
                    StatusManager.sharedInstance().setIsMDCMode(false)
                }
            } catch {
                if needsTrollStore {
                    UIApplication.shared.alert(title: "Use TrollStore", body: "You must install this app with TrollStore for it to work. Please close the app.", withButton: false)
                    return
                }
                // Use MacDirtyCOW to gain r/w
                grant_full_disk_access() { error in
                    if (error != nil) {
                        UIApplication.shared.alert(body: "\(String(describing: error?.localizedDescription))\nPlease close the app and retry.", withButton: false)
                        return
                    }
                    StatusManager.sharedInstance().setIsMDCMode(true)
                }
            }
            
            let fm = FileManager.default
            if fm.fileExists(atPath: "/var/mobile/Library/SpringBoard/statusBarOverridesEditing") {
                do {
                    try fm.removeItem(at: URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/statusBarOverridesEditing"))
                } catch {
                    UIApplication.shared.alert(body: "\(error)")
                }
            }
        }
}
