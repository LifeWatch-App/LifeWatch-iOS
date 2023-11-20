//
//  SOSView.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 07/11/23.
//

import SwiftUI

struct SOSView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var sosManager: SOSManager = SOSManager()
    private var audioPlayerManager: AudioPlayerManager = AudioPlayerManager.shared
    @State var SOS: Bool = false
    @State var watchWidth: CGFloat = 80
    @State var watchHeight: CGFloat = 80
    @State var timeRemaining = 10
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if timeRemaining > 0 {
            VStack {
                Text("Alerting Family")
                    .bold()
                    .foregroundStyle(.white)
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color("secondary-pink").opacity(0.5))
                        .frame(width: timeRemaining % 2 == 0 ? watchWidth / 1.5 : watchWidth * 1.2)
                        .animation(.easeInOut(duration: 1), value: UUID())
                    Circle()
                        .fill(.white)
                        .frame(width: watchWidth / 1.5)
                    Text("\(timeRemaining)")
                        .font(.system(size: 32))
                        .bold()
                        .foregroundStyle(Color("emergency-pink"))
                }
                .frame(width: watchWidth * 1.2, height: watchHeight)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Spacer()
                        
                        Text("Cancel")
                            .font(.headline)
                            .foregroundStyle(Color("emergency-pink"))
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 8)
                Spacer()
            }
            .toolbar(.hidden, for: .navigationBar)
            .background(Color("emergency-pink"))
            .onReceive(timer) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else if timeRemaining == 0 {
                    sosManager.sendSOS()
                    audioPlayerManager.playAlert()
                    timer.upstream.connect().cancel()
                }
            }
        } else {
            VStack {
                Spacer()
                Text("Emergency Pressed")
                    .font(.system(size: 16))
                    .bold()
                    .multilineTextAlignment(.center)
                Spacer()
                Image(systemName: "light.beacon.max.fill")
                    .font(.system(size: 48))
                Spacer()
                Text("Alert Message Sent")
                    .font(.body)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button {
                    audioPlayerManager.stopAlert()
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
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .toolbar(.hidden, for: .navigationBar)
            .background(Color("emergency-pink"))
        }
    }
}

#Preview {
    SOSView()
}
