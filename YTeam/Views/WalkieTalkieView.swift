//
//  WalkieTalkieView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 03/11/23.
//

import SwiftUI

struct WalkieTalkieView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.accent)
                .frame(width: Screen.width, height: Screen.height)
                .ignoresSafeArea()
            
            ZStack {
                Circle()
                    .stroke(.white, lineWidth: 2)
                    .frame(width: Screen.width / 1.2)
                
                Circle()
                    .fill(.white)
                    .frame(width: Screen.width / 1.3)
                
                Image(systemName: "flipphone")
                    .font(.system(size: 140))
                    .foregroundStyle(.accent)
            }
            .frame(width: Screen.width, height: Screen.height)
            
            VStack(spacing: 4) {
                Text("Press to Talk With Family Members")
                    .font(.title3)
                
                Spacer()
            }
            .padding(.top, 200)
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
        }
        .foregroundStyle(.white)
        .frame(width: Screen.width, height: Screen.height)
    }
}

#Preview {
    WalkieTalkieView()
}
