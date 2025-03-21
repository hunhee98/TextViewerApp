//
//  WatchApp.swift
//  MyTextViewer
//
//  Created by HUNHEE LEE on 19.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//

import SwiftUI

@main
struct sampleWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}
