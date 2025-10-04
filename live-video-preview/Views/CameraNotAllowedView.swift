//
//  CameraNotAllowedView.swift
//  live-video-preview
//
//  Created by Mathieu Dubart on 03/10/2025.
//

import SwiftUI

import SwiftUI

struct CameraNotAllowedView: View {
    @Environment(\.openURL) private var openURL
    var textToDisplay: String = "Camera usage hasn't been allowed, please allow it in Settings."
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera")
                .font(.largeTitle)
            
            Text(textToDisplay)
                .multilineTextAlignment(.center)
            
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            } label: {
                Label("Allow camera access", systemImage: "arrow.2.circlepath.circle")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    CameraNotAllowedView()
}
