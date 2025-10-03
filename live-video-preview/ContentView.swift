//
//  ContentView.swift
//  live-video-preview
//
//  Created by Mathieu Dubart on 21/09/2025.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @Environment(PermissionsManager.self) var permissionsManager

    var body: some View {
        ZStack {
            if permissionsManager.cameraUsageIsAllowed() {
                
            } else {
                CameraNotAllowedView();
            }
        }

        .onAppear {
            Task
            {
                await permissionsManager.requestCameraPermission()
            }
        }
    }
    
    
}

#Preview {
    ContentView()
}
