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
    
    /*
     * Discovers an array of available devices
     */
    func discoverAvailableDevices() throws -> AVCaptureDevice.DiscoverySession {
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInWideAngleCamera,
                .builtInTelephotoCamera,
                .builtInTrueDepthCamera,
                .builtInDualCamera
            ],
            mediaType: .video,
            position: .unspecified
        )
        
        return session
    }
    
    /*
     * Returns the best device
     */
    func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let devices = self.videoDevices()
        
        
        guard !devices.isEmpty else { fatalError("Missing capture devices.")}
        return devices.first(where: { device in device.position == position })!
    }
    
    /*
     * Return an array of devices available
     */
    func videoDevices() -> [AVCaptureDevice] {
        (try? discoverAvailableDevices().devices) ?? []
    }
    

    /*
     * Switch between available devices by Position (front or back)
     */
    func switchToDevice(withPosition position: AVCaptureDevice.Position, completion: @escaping (Error?) -> Void) {
        queue.async {
            do {
                // Choisir un device pour cette position
                let discovery = try self.discoverAvailableDevices()
                guard let device = discovery.devices.first(where: { $0.position == position }) else {
                    throw CameraError.deviceNotFound(position: position)
                }
                try self.reconfigureSession(with: device)
                DispatchQueue.main.async { completion(nil) }
            } catch {
                DispatchQueue.main.async { completion(error) }
            }
        }
    }
    
    /*
     * Switch between available devices by ID
     */
    func switchToDevice(withID uniqueID: String, completion: @escaping (Error?) -> Void) {
        queue.async {
            do {
                let discovery = try self.discoverAvailableDevices()
                guard let device = discovery.devices.first(where: { $0.uniqueID == uniqueID }) else {
                    throw CameraError.noDevices
                }
                try self.reconfigureSession(with: device)
                DispatchQueue.main.async { completion(nil) }
            } catch {
                DispatchQueue.main.async { completion(error) }
            }
        }
    }
    
    /*
     * Reconfigure AVFoundation Session
     */
    private func reconfigureSession(with device: AVCaptureDevice) throws {
        let newInput = try AVCaptureDeviceInput(device: device)
        
        session.beginConfiguration()
        // Retirer uniquement les inputs vidéo existants
        for input in session.inputs {
            if let input = input as? AVCaptureDeviceInput,
               input.device.hasMediaType(.video) {
                session.removeInput(input)
            }
        }
        guard session.canAddInput(newInput) else {
            session.commitConfiguration()
            throw CameraError.cannotAddInput
        }
        session.addInput(newInput)
        session.commitConfiguration()
    }
}
