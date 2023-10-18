//
//  IdleDetectionView.swift
//  YTeam Watch App
//
//  Created by Maximus Aurelius Wiranata on 11/10/23.
//

import SwiftUI

struct IdleDetectionView: View {
    @StateObject var idleViewModel: IdleDetectionViewModel = IdleDetectionViewModel()

    var body: some View {
        VStack {
            Text("Position: \(idleViewModel.position)")
        }
        .onReceive(idleViewModel.timer) { input in
            idleViewModel.checkPosition()
        }
    }
}

#Preview {
    IdleDetectionView()
}
