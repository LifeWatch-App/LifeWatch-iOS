//
//  CombinedView.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 30/10/23.
//

import SwiftUI

struct CombinedView: View {
//    @StateObject private var heartManager = HeartManager()
    @StateObject private var locationVM = LocationViewModel()
    @StateObject private var idleVM = IdleDetectionViewModel()
    @StateObject private var chargingVM = ChargingViewModel()
    @EnvironmentObject private var authVM: TestAuthViewModel
    
    @State var sosManager: SOSManager = SOSManager.shared
    var body: some View {
        
        switch locationVM.authorizationStatus {
        case .notDetermined:
            AnyView(RequestLocationView())
                .environmentObject(locationVM)
        case .restricted:
            ErrorView(errorText: "Location use is restricted.")
        case .denied:
            ErrorView(errorText: "The app does not have location permissions. Please enable them in settings.")
        case .authorizedAlways, .authorizedWhenInUse:
            VStack {
                VStack(spacing: 15) {
                    VStack {
//                        Text("\(heartManager.heartRate)")
//                            .font(.title2)
                        Text("BPM")
                        Spacer()
                        Button{
                            sosManager.showSOS.toggle()
                        } label: {
                            VStack(alignment: .leading) {
                                HStack(alignment: .center) {
                                    Text("SOS")
                                        .multilineTextAlignment(.leading)
                                        .font(.title)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Image(systemName: "light.beacon.max.fill")
                                        .font(.title2)
                                }
                            }
                            .padding()
                            .background(Color("emergency-pink"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.top, 8)
                        }
                        .fullScreenCover(isPresented: $sosManager.showSOS, content: {
                            SOSView()
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .onReceive(idleVM.timer) { _ in
                idleVM.checkPosition()
            }
        default:
            Text("Unexpected status")
        }
    }
}

#Preview {
    CombinedView()
}


