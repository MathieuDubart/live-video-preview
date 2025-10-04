//
//  CameraManager.swift
//  live-video-preview
//
//  Created by Mathieu Dubart on 04/10/2025.
//

import Foundation
import AVFoundation

@Observable
class CameraManager {
    static var shared: CameraManager = {
        let instance = CameraManager()
        return instance
    }()
    
    let session: AVCaptureSession
    private var isConfigured = false
    private let queue = DispatchQueue(label: "camera.session.queue")
    
    enum CameraError: Error { case noCamera, cannotAddInput }
    
    private init() {
        self.session = AVCaptureSession()
    }
    
    func configureSession() throws {
        self.session.beginConfiguration()
        self.session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back) else {
            throw CameraError.noCamera
        }
        
        let input = try AVCaptureDeviceInput(device: device)
        guard self.session.canAddInput(input) else { throw CameraError.cannotAddInput }
        self.session.addInput(input)
        
        self.session.commitConfiguration()
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.session.isRunning { self.session.startRunning() }
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }
}

extension CameraManager: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
