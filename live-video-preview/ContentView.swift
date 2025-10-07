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

    @State private var cameraSwitchErrorMessage = ""
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
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            cameraController.switchToDevice(withType: .builtInUltraWideCamera) { e in
                                cameraController.resetDefaultCamera(withError: e)
                            }
                        } label: {
                            Text(".5")
                        }
                        .buttonStyle(.glass)
                        .padding([.all], 15)
                        .buttonBorderShape(.circle)
                        
                        Spacer()
                            .frame(width: 35)
                        
                        Button {
                            cameraController.switchToDevice(withType: .builtInDualCamera) { e in
                                cameraController.resetDefaultCamera(withError: e)
                            }
                        } label: {
                            Text("1")
                        }
                        .buttonStyle(.glass)
                        .padding([.all], 15)
                        .buttonBorderShape(.circle)
                        
                        Spacer()
                            .frame(width: 35)
                        
                        Button {
                            cameraController.switchToDevice(withType: .builtInTelephotoCamera) { e in
                                cameraController.resetDefaultCamera(withError: e)
                            }
                        } label: {
                            Text("25")
                        }
                        .buttonStyle(.glass)
                        .padding([.all], 15)
                        .buttonBorderShape(.circle)
                        
                    }
                    .padding([.bottom], 150)
                }
                            
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
