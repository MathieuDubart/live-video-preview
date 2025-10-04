//
//  CameraController.swift
//  live-video-preview
//
//  Created by Mathieu Dubart on 04/10/2025.
//

import Foundation
import AVFoundation

@Observable
final class CameraController {
    static let shared = CameraController()
    
    let session: AVCaptureSession
    private var isConfigured = false
    private let queue = DispatchQueue(label: "camera.session.queue")
    
    enum CameraError: Error { case noCamera, cannotAddInput }
    
    private init() {
        self.session = AVCaptureSession()
    }
    
    func configureSessionIfNeeded() throws {
        guard !isConfigured else { return }
        isConfigured = true
        
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back) else {
            isConfigured = false
            session.commitConfiguration()
            throw CameraError.noCamera
        }
        
        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else {
            isConfigured = false
            session.commitConfiguration()
            throw CameraError.cannotAddInput
        }
        session.addInput(input)
        
        session.commitConfiguration()
    }
    
    func configureOnQueueIfNeeded(completion: @escaping (Error?) -> Void) {
        queue.async {
            do {
                try self.configureSessionIfNeeded()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func startSession() {
        queue.async {
            if !self.session.isRunning { self.session.startRunning() }
        }
    }
    
    func stopSession() {
        queue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }
}
