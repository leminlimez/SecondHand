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
    dateFormatter.locale = Locale(identifier: Locale.preferredLanguages.first!)
    
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
                //Toggle("24 Hour Time", isOn: $timeAs24).onChange(of: timeAs24) { new in
                //    UserDefaults.standard.set(new, forKey: "Time24Hour")
                //}
                
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
                        showDateFormatAlert()
                    }) {
                        Text(dateFormat)
                            .foregroundColor(.blue)
                    }
                }
                .padding(10)
                
                Text("""
\"e\": numeric day of week
\"E\"-\"EEE\": short day of week
\"EEEE\": long day of week

\"d\": day of month, without leading zero
\"dd\": day of month, with leading zero

\"M\": numeric month, without leading zero
\"MM\": numeric month, with leading zero
\"MMM\": short month
\"MMMM\": long month

\"yy\": two-digit year
\"y\"/\"yyyy\": four-digit year
""")
                .font(.footnote)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
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
    
    func showDateFormatAlert() {
        let alert = UIAlertController(title: "Input a date format", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = dateFormat
            textField.placeholder = dateFormat
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] _ in
            guard let textField = alert?.textFields?.first,
                  let newDateFormat = textField.text,
                  !newDateFormat.trimmingCharacters(in: .whitespaces).isEmpty
            else {
                return
            }
            
            dateFormat = newDateFormat.trimmingCharacters(in: .whitespaces)
            UserDefaults.standard.set(dateFormat, forKey: "DateFormat")
            
            if crumbTextEnabled {
                setCrumbDate()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
