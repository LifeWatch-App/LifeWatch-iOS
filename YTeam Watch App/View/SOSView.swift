//
//  SOSView.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 07/11/23.
//

import SwiftUI

struct SOSView: View {
    @ObservedObject var sosManager: SOSManager = SOSManager()
    @ObservedObject var audioPlayerManager: AudioPlayerManager = AudioPlayerManager()
    @State var SOS: Bool = false
    var body: some View {
        Button {
            SOS.toggle()
        } label: {
            if (!SOS) {
                Text("Send SOS")
            } else {
                Text("Stop SOS")
            }
        }
        .onChange(of: SOS) {
            if (SOS) {
                audioPlayerManager.playAlert()
                sosManager.sendSOS()
            } else {
                audioPlayerManager.stopAlert()
            }
        }
    }
}

#Preview {
    SOSView()
}
