//
//  WalkieTalkieView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 03/11/23.
//

import SwiftUI

struct WalkieTalkieView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var walkieTalkieViewModel = WalkieTalkieViewModel()
    @State var hasPressed = false
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.accent)
                .frame(width: Screen.width, height: Screen.height)
                .ignoresSafeArea()
            
            ZStack {
                Circle()
                    .stroke(walkieTalkieViewModel.isPlaying! || hasPressed ? Color(UIColor.lightGray) : .white, lineWidth: 2)
                    .frame(width: Screen.width / 1.2)
                
                Circle()
                    .fill(walkieTalkieViewModel.isPlaying! || hasPressed ? Color(UIColor.lightGray) : .white)
                    .frame(width: Screen.width / 1.3)
                
                Image(systemName: "flipphone")
                    .font(.system(size: 140))
                    .foregroundStyle(.accent)
            }
            .frame(width: Screen.width, height: Screen.height)
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: 100, pressing: {
                pressing in
                self.hasPressed = pressing
                if !walkieTalkieViewModel.isPlaying! {
                    if pressing {
                        walkieTalkieViewModel.startRecording()
                    }
                    if !pressing {
                        walkieTalkieViewModel.stopRecording()
                    }
                }
            }, perform: {})
            
            VStack(spacing: 4) {
                Text(walkieTalkieViewModel.isPlaying! ? "\(walkieTalkieViewModel.speakerName)..." : walkieTalkieViewModel.status!)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.top, 190)
            .padding(.horizontal)
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.largeTitle)
                            .bold()
                            .padding(.leading, 20)
                            .padding(.top, 40)
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            VStack(spacing: 4) {
                Spacer()
                Button {
                    walkieTalkieViewModel.leaveChannel()
                    dismiss()
                } label: {
                    VStack {
                        Text("Leave Channel")
                            .bold()
                            .foregroundStyle(.white)
                    }
                    .padding(12)
                    .background(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                }
                Text("(you will not receive incoming transmissions)")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 100)
            .padding(.horizontal)
        }
        .foregroundStyle(.white)
        .frame(width: Screen.width, height: Screen.height)
        .onAppear {
            walkieTalkieViewModel.joinChannel()
        }
    }
}

#Preview {
    WalkieTalkieView()
}
