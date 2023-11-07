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
                Text("\(Int(progress * 10))")
                    .bold()
                    .font(.title2)
            }
            Button {
                fallManager.cancelFallStatus()
                coreMotionManager.cancelFallStatus()
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
            print("Fall", pressedCancel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.progress -= 0.1
                self.updateCountdown()
            }
        } else {
            self.presentationMode.wrappedValue.dismiss()
            if (!pressedCancel) {
                fallManager.sendFall()
            }
            self.pressedCancel = false
        }
    }
}



#Preview {
    FallNotificationView()
}
