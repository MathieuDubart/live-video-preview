//
//  Errors.swift
//  live-video-preview
//
//  Created by Mathieu Dubart on 05/10/2025.
//

import Foundation
import AVFoundation

enum CameraError: LocalizedError {
    case noCamera
    case cannotAddInput
    case noDevices
    case deviceNotFound(position: AVCaptureDevice.Position)
    
    var errorDescription: String? {
        switch self {
        case .noCamera:
            return "Aucun appareil photo n’a été détecté sur cet appareil."
        case .cannotAddInput:
            return "Impossible de configurer la caméra."
        case .noDevices:
            return "Aucun appareil photo disponible."
        case .deviceNotFound(let position):
            return position == .front
            ? "La caméra avant est indisponible."
            : "La caméra arrière est indisponible."
        }
    }
}
