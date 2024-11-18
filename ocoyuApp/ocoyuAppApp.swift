//
//  ocoyuAppApp.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 02/10/24.
//

import SwiftUI
import Firebase

@main
struct ocoyuAppApp: App {
    @State private var locationManager = LocationManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            if locationManager.isAuthorized {
                RootView()
            }else{
                LocationDeniedView()
            }
            
        }
        .environment(locationManager)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

