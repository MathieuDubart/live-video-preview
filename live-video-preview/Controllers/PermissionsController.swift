//
//  PermissionsController.swift
//  live-video-preview
//
//  Created by Mathieu Dubart on 03/10/2025.
//

import SwiftUI
import AVFoundation

@MainActor
@Observable
final class PermissionsController {
    var cameraStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    var isCameraAuthorized: Bool { cameraStatus == .authorized }
    
    func refreshCameraStatus() {
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func requestCameraPermission() async {
        let current = AVCaptureDevice.authorizationStatus(for: .video)
        switch current {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            cameraStatus = granted ? .authorized : .denied
        default:
            cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        }
    }
}
