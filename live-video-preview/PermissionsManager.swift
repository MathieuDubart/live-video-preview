//
//  PermissionsManager.swift
//  live-video-preview
//
//  Created by Mathieu Dubart on 03/10/2025.
//

import SwiftUI
import AVFoundation

@Observable
class PermissionsManager {
    @ObservationIgnored
    @AppStorage("cameraPermissionIsAllowed") private var isCameraPermissionGranted: Bool = false
   
    public func requestCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            self.isCameraPermissionGranted = granted
        case .authorized:
            self.isCameraPermissionGranted = true
        default:
            self.isCameraPermissionGranted = false
        }
    }
    
    public func cameraUsageIsAllowed() -> Bool {
        return isCameraPermissionGranted
    }
}
