//
//  ContentView.swift
//  SecondHand
//
//  Created by lemin on 3/2/23.
//

import SwiftUI

func setTimeSeconds() {
    let calendar = Calendar.current
    let date = Date()
    let hour = calendar.component(.hour, from: date)
    let hourFinal = UserDefaults.standard.bool(forKey: "Time24Hour") ? hour : (hour%12 == 0 ? 12 : hour%12)
    let minutes = calendar.component(.minute, from: date)
    let seconds = calendar.component(.second, from: date)
    
    let newStr: String = "\(hourFinal):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    
    if newStr.utf8CString.count <= 64 {
        StatusManager.sharedInstance().setTime(newStr)
    } else {
        StatusManager.sharedInstance().setTime("Length Error")
    }
}

func setCrumbDate() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = UserDefaults.standard.string(forKey: "DateFormat") ?? "MM/dd"
    
    let newStr: String = dateFormatter.string(from: Date())
    
    if (newStr + " ▶").utf8CString.count <= 256 {
        StatusManager.sharedInstance().setCrumb(newStr)
    } else {
        StatusManager.sharedInstance().setCrumb("Length Error")
    }
}

struct ContentView: View {
    @State private var timeTextEnabled: Bool = StatusManager.sharedInstance().isTimeOverridden()
    @State private var crumbTextEnabled: Bool = StatusManager.sharedInstance().isCrumbOverridden()
    @State private var dateFormat: String = UserDefaults.standard.string(forKey: "DateFormat") ?? "MM/dd"
    
    private var dateFormats: [String] = [
        "MM/dd",
        "MM/dd/yyyy",
        "MMM dd",
        "MMM dd yyyy",
        
        "dd/MM",
        "dd/MM/yyyy",
        "dd MMM",
        "dd MMM yyyy",
        
        "EEE, MMM dd",
        "EEEE"
    ]
    
    private var dateFormattingExamples: [String: String] = [
        "MM/dd": "03/20",
        "MM/dd/yyyy": "03/20/2023",
        "MMM dd": "Mar 20",
        "MMM dd yyyy": "Mar 20 2023",
        
        "dd/MM": "20/03",
        "dd/MM/yyyy": "20/03/2023",
        "dd MMM": "20 Mar",
        "dd MMM yyyy": "20 Mar 2023",
        
        "EEE, MMM dd": "Mon, Mar 20",
        "EEEE": "Monday"
    ]
    
    //@State private var timeAs24: Bool = UserDefaults.standard.bool(forKey: "Time24Hour")
    
    @ObservedObject var backgroundController = BackgroundFileUpdaterController.shared
    
    @State var test: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                Text(timeTextEnabled || crumbTextEnabled ? "Running" : "Stopped")
                    .foregroundColor(timeTextEnabled || crumbTextEnabled ? .green : .red)
                    .font(.title2)
                    .padding(20)
                
                // MARK: Configuration
                // MARK: 24-Hour Time
                //            Toggle("24 Hour Time", isOn: $timeAs24).onChange(of: timeAs24) { new in
                //                UserDefaults.standard.set(new, forKey: "Time24Hour")
                //            }
                
                // MARK: Seconds
                Toggle("Seconds", isOn: $timeTextEnabled).onChange(of: timeTextEnabled) { new in
                    if new {
                        UserDefaults.standard.set(true, forKey: "TimeIsEnabled")
                        setTimeSeconds()
                        backgroundController.time = 1.0
                        backgroundController.restartTimer()
                        timeTextEnabled = StatusManager.sharedInstance().isTimeOverridden()
                    } else {
                        UserDefaults.standard.set(false, forKey: "TimeIsEnabled")
                        backgroundController.time = 3600.0
                        backgroundController.restartTimer()
                        StatusManager.sharedInstance().unsetTime()
                        timeTextEnabled = StatusManager.sharedInstance().isTimeOverridden()
                    }
                }
                .padding(10)
                
                Divider()
                
                // MARK: Date
                Toggle("Date", isOn: $crumbTextEnabled).onChange(of: crumbTextEnabled) { new in
                    if new {
                        UserDefaults.standard.set(true, forKey: "DateIsEnabled")
                        setCrumbDate()
                        crumbTextEnabled = StatusManager.sharedInstance().isCrumbOverridden()
                    } else {
                        UserDefaults.standard.set(false, forKey: "DateIsEnabled")
                        StatusManager.sharedInstance().unsetCrumb()
                        crumbTextEnabled = StatusManager.sharedInstance().isCrumbOverridden()
                    }
                }
                .padding(10)
                
                // MARK: Date Format
                HStack {
                    Text("Date Format")
                        .bold()
                    Spacer()
                    Button(action: {
                        showDateFormatPopup()
                    }) {
                        Text(dateFormat)
                            .foregroundColor(.blue)
                    }
                }
                .padding(10)
            }
            .padding()
            
            VStack {
                Spacer()
                Text("Version \(Bundle.main.releaseVersionNumber ?? "UNKNOWN")")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            if UserDefaults.standard.bool(forKey: "TimeIsEnabled") == true {
                // check if it was disabled elsewhere
                UserDefaults.standard.set(timeTextEnabled, forKey: "TimeIsEnabled")
                if timeTextEnabled == true {
                    backgroundController.time = 1.0
                }
            }
            
            if UserDefaults.standard.bool(forKey: "DateIsEnabled") == true {
                // check if it was disabled elsewhere
                UserDefaults.standard.set(crumbTextEnabled, forKey: "DateIsEnabled")
            }
            
            backgroundController.setup()
        }
    }
    
    func showDateFormatPopup() {
        // create and configure alert controller
        let alert = UIAlertController(title: "Choose a date format", message: "", preferredStyle: .actionSheet)
        
        // create the actions
        for f in dateFormats {
            let newAction = UIAlertAction(title: "\(f) (\(dateFormattingExamples[f] ?? "Error"))", style: .default) { (action) in
                // apply the format
                UserDefaults.standard.set(f, forKey: "DateFormat")
                dateFormat = f
                if crumbTextEnabled {
                    setCrumbDate()
                }
            }
            if dateFormat == f {
                // add a check mark
                newAction.setValue(true, forKey: "checked")
            }
            alert.addAction(newAction)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
            // cancels the action
        }
        
        // add the actions
        alert.addAction(cancelAction)
        
        let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
        // present popover for iPads
        alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
        
        // present the alert
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
