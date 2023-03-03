//
//  ContentView.swift
//  SecondHand
//
//  Created by lemin on 3/2/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button(action: {
                UserDefaults.standard.set(true, forKey: "IsEnabled")
            }) {
                Text("Enable")
            }
            
            Button(action: {
                UserDefaults.standard.set(false, forKey: "IsEnabled")
            }) {
                Text("Disable")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
