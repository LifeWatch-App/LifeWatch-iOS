//
//  SOSView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 03/11/23.
//

import SwiftUI

struct SOSView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var seniorDashboardViewModel: SeniorDashboardViewModel
    @ObservedObject var audioManager: AudioPlayerManager = AudioPlayerManager()
    
    @State var timeRemaining = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("emergency-pink"))
                .frame(width: Screen.width, height: Screen.height)
                .ignoresSafeArea()
            
            ZStack {
                Circle()
                    .fill(Color("secondary-pink").opacity(0.5))
                    .frame(width: timeRemaining%2 == 0 ? Screen.width / 1.3 : Screen.width * 1.5)
                    .animation(.easeInOut(duration: 1), value: UUID())
                
                Circle()
                    .fill(.white)
                    .frame(width: Screen.width / 1.3)
                
                Text("\(timeRemaining)")
                    .font(.system(size: 120))
                    .bold()
                    .foregroundStyle(Color("emergency-pink"))
            }
            .frame(width: Screen.width, height: Screen.height)
            
            VStack(spacing: 4) {
                Text("Emergency Call")
                    .font(.title)
                    .bold()
                Text("Alerting to Family Members")
                    .font(.title3)
                
                Spacer()
            }
            .padding(.top, 150)
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
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
//                Task{ try? seniorDashboardViewModel.sendSOS()}
//                audioManager.playAlert()
            }
        }
    }
}

#Preview {
    SOSView(seniorDashboardViewModel: SeniorDashboardViewModel())
}
