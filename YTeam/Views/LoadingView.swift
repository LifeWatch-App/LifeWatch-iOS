//
//  LoadingView.swift
//  YTeam
//
//  Created by Yap Justin on 09/12/23.
//

import SwiftUI

struct LoadingView: View {
    @State var scale = 0.5
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                HStack {
                    Circle()
                        .fill(.accent)
                        .frame(width: 20, height: 20)
                        .scaleEffect(scale)
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever(), value: scale)
                    Circle()
                        .fill(.emergencyPink)
                        .frame(width: 20, height: 20)
                        .scaleEffect(scale)
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.3), value: scale)
                    Circle()
                        .fill(.accent)
                        .frame(width: 20, height: 20)
                        .scaleEffect(scale)
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.6), value: scale)
                }
                Spacer()
            }
            Spacer()
        }
        .onAppear {
            scale = 1.0
        }
    }
}

#Preview {
    LoadingView()
}
