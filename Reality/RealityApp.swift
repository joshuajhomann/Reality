//
//  RealityApp.swift
//  Reality
//
//  Created by Joshua Homann on 11/18/23.
//

import SwiftUI

@main
struct RealityApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)
    }
}
