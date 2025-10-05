//
//  ContentView.swift
//  live-video-preview
//
//  Created by Mathieu Dubart on 21/09/2025.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @Environment(PermissionsController.self) var permissionsController
    let cameraController = CameraController.shared

    var body: some View {
        ZStack {
            if permissionsController.isCameraAuthorized {
                #if targetEnvironment(simulator)
                let simulatorHint = "No camera inside simulator environment 😢"
                #else
                let simulatorHint = ""
                #endif
                
                Text(simulatorHint)
                CameraPreview(session: cameraController.session)
                    .ignoresSafeArea()
                
            } else {
                CameraNotAllowedView()
            }
        }

        .task {
            await permissionsController.requestCameraPermission()
            if permissionsController.isCameraAuthorized {
                cameraController.configureOnQueueIfNeeded { error in
                    if let error {
                        print("Camera config error: \(error)")
                    } else {
                        cameraController.startSession()
                    }
                }
            }
        }
        .onChange(of: permissionsController.isCameraAuthorized, initial: true) { _, newValue in
            if newValue == true {
                cameraController.configureOnQueueIfNeeded { error in
                    if let error {
                        print("Camera config error: \(error)")
                    } else {
                        cameraController.startSession()
                    }
                }
            } else {
                cameraController.stopSession()
            }
        }
        .onDisappear {
            cameraController.stopSession()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            permissionsController.refreshCameraStatus()
        }
    }
    
    
}

#Preview {
    ContentView()
}
