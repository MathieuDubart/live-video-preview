//
//  CameraNotAllowedView.swift
//  live-video-preview
//
//  Created by Mathieu Dubart on 03/10/2025.
//

import SwiftUI

struct CameraNotAllowedView: View {
    var textToDsiaplay: String = "Camera usage hasn't been allowed, please allow it in settings"
    var body: some View {
        VStack {
            Image(systemName: "camera")
            Spacer()
                .frame(height:20)
            
            Text(textToDsiaplay)
            Spacer()
                .frame(height:20)
            
            Button {
                
            } label: {
                HStack {
                    Text("Allow camera access")
                    Spacer()
                        .frame(width: 10)
                    
                    Image(systemName: "arrow.2.circlepath.circle")
                }
            }
        }
    }
}

#Preview {
    CameraNotAllowedView()
}
