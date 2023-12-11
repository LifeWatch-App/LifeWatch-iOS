//
//  FallNotificationView.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 07/11/23.
//

import SwiftUI
import UserNotifications

struct FallNotificationView: View {
    @EnvironmentObject var fallManager: FallDetectionManager
    @EnvironmentObject var coreMotionManager: CoreMotionManager
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    @State private var progress: CGFloat = 1
    @State private var second = 15
    @State private var pressedCancel: Bool = false
    @State var watchWidth: CGFloat = 80
    @State var watchHeight: CGFloat = 80
    var body: some View {
        VStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Text("Did you fall?")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color("secondary-pink").opacity(0.5))
                        .frame(width: second % 2 == 0 ? watchWidth / 1.5 : watchWidth * 1.2)
                        .animation(.easeInOut(duration: 1), value: UUID())
                    Circle()
                        .fill(.white)
                        .frame(width: watchWidth / 1.5)
                    Text("\(second)")
                        .font(.system(size: 32))
                        .bold()
                        .foregroundStyle(Color("emergency-pink"))
                }
                .frame(width: watchWidth * 1.2, height: watchHeight)
                Spacer()
                Button {
                    fallManager.cancelFallStatus()
                    coreMotionManager.cancelFallStatus()
                    coreMotionManager.startAccelerometer()
                    self.presentationMode.wrappedValue.dismiss()
                    self.pressedCancel = true
                } label: {
                    HStack {
                        Spacer()
                        
                        Text("No I did not.")
                            .font(.headline)
                            .foregroundStyle(Color("emergency-pink"))
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()
                }.padding(.top, 8)
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .background(Color("emergency-pink"))
            
            
        }
        .onAppear {
            self.updateCountdown()
        }
    }
    
    func updateCountdown() {
        if (self.second > -1) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.progress -= CGFloat((1/self.second))
                self.second -= 1
                self.updateCountdown()
            }
        } else {
            if (!pressedCancel) {
                fallManager.sendFall()
                fallManager.notificationSent.toggle()
            }
            dismiss()
            self.pressedCancel = false
        }
    }
}

struct FallNotificationSentView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var fallDetector: FallDetectionManager
    @EnvironmentObject var motionDetector: CoreMotionManager
    
    var body: some View {
        VStack {
            Spacer()
            Text("Fall Notification")
                .multilineTextAlignment(.center)
                .font(.headline)
                .bold()
                .foregroundStyle(.white)
            Text("Sent")
                .multilineTextAlignment(.center)
                .font(.headline)
                .bold()
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "figure.fall")
                .font(.system(size: 40))
            Spacer()
            Button {
                fallDetector.notificationSent.toggle()
                motionDetector.startAccelerometer()
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Spacer()
                    
                    Text("I understand")
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
        .background(Color("emergency-pink"))
//        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    FallNotificationView()
}
