//
//  CoreMotionAppApp.swift
//  CoreMotionApp
//
//  Created by Hlwan Aung Phyo on 10/17/24.
//

import SwiftUI
import FirebaseCore
@main
struct CoreMotionAppApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            StartScreenView()
        }
    }
}
