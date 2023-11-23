//
//  IdleDetectionView.swift
//  YTeam Watch App
//
//  Created by Maximus Aurelius Wiranata on 11/10/23.
//

import SwiftUI

struct IdleDetectionView: View {
    @StateObject var idleViewModel: IdleDetectionViewModel = IdleDetectionViewModel()
    @StateObject private var locationVM = LocationViewModel()

    var body: some View {
        VStack {
            Text("Position: \(idleViewModel.position)")

            Button("Create") {
                idleViewModel.createIdleDataFirebase(startTime: Date.now)
            }

            Button("Update") {
                idleViewModel.updateIdleDataFirebase(endTime: Date.now)
            }
        }
        .onReceive(idleViewModel.timer) { input in
            idleViewModel.checkPosition()
        }
    }
}

#Preview {
    IdleDetectionView()
}
