//
//  FallNotificationView.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 07/11/23.
//

import SwiftUI
import UserNotifications

struct FallNotificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var progress: CGFloat = 1
    
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
            HStack {
                
            }
        }
        .onAppear {
            self.updateCountdown()
        }
    }
    
    func updateCountdown() {
        if (self.progress > 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.progress -= 0.1
                self.updateCountdown()
            }
        } else {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}



#Preview {
    FallNotificationView()
}
