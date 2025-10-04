//
//  CameraPreview.swift
//  live-video-preview
//
//  Created by Mathieu Dubart on 21/09/2025.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }

    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        guard let connection = uiView.videoPreviewLayer.connection else { return }
        if #available(iOS 17.0, *) {
            let portraitAngle: CGFloat = 90
            if connection.isVideoRotationAngleSupported(portraitAngle) {
                connection.videoRotationAngle = portraitAngle
            }
        } else {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
    }

    static func dismantleUIView(_ uiView: PreviewView, coordinator: ()) {
        uiView.videoPreviewLayer.session = nil
    }
    
}

#Preview {
    CameraPreview(session: AVCaptureSession())
        .frame(height: 300)
}
