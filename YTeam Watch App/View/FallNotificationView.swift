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
    
    @State private var progress: CGFloat = 1
    @State private var second: Double = 15
    @State private var pressedCancel: Bool = false
    
    var body: some View {
        VStack {
            Text("Did you fall?")
                .padding(.bottom, 8)
            ZStack {
                Circle()
                    .trim(from: 1-self.progress, to: 1)
                    .stroke(.red, lineWidth: 12)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(progress * second))")
                    .bold()
                    .font(.title2)
            }
            Button {
                fallManager.cancelFallStatus()
                coreMotionManager.cancelFallStatus()
                coreMotionManager.startAccelerometer()
                self.presentationMode.wrappedValue.dismiss()
                self.pressedCancel = true
            } label: {
                Text("No, I did not")
            }.padding(.top, 8)
        }
        .onAppear {
            self.updateCountdown()
        }
    }
    
    func updateCountdown() {
        if (self.progress > 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.progress -= (1/self.second)
                self.updateCountdown()
            }
        } else {
            self.presentationMode.wrappedValue.dismiss()
            if (!pressedCancel) {
                fallManager.sendFall()
                coreMotionManager.startAccelerometer()
            }
            self.pressedCancel = false
        }
    }
}



#Preview {
    FallNotificationView()
}
