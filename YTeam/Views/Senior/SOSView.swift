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
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("emergency-pink"))
                .frame(width: Screen.width, height: Screen.height)
                .ignoresSafeArea()
            
            if timeRemaining > 0 {
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
                    Text("Alerting Care Team")
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
            } else {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("Emergency\nPressed")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Image(systemName: "light.beacon.max.fill")
                            .font(.system(size: 200))
                        
                        Text("Alert message to the member family has been successfully sent")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                    
                    Button {
                        audioManager.stopAlert()
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text("Done")
                                .font(.headline)
                                .foregroundStyle(Color("emergency-pink"))
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding()
                    }
                }
                .padding(.bottom, 36)
            }
        }
        .foregroundStyle(.white)
        .frame(width: Screen.width, height: Screen.height)
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                Task{ try? seniorDashboardViewModel.sendSOS()}
                audioManager.playAlert()
                timer.upstream.connect().cancel()
            }
        }
    }
}

#Preview {
    SOSView(seniorDashboardViewModel: SeniorDashboardViewModel())
}
