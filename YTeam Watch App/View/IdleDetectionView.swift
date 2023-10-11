//
//  IdleDetectionView.swift
//  YTeam Watch App
//
//  Created by Maximus Aurelius Wiranata on 11/10/23.
//

import SwiftUI

let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

struct IdleDetectionView: View {
    @StateObject var vm: IdleDetectionViewModel = IdleDetectionViewModel()
    
    var body: some View {
        VStack {
            Text("Position: \(vm.position)")
        }
        .onReceive(timer) { input in
            vm.checkPosition()
        }
    }
}

#Preview {
    IdleDetectionView()
}
