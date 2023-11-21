//
//  CombinedView.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 30/10/23.
//

import SwiftUI

struct CombinedView: View {
    @StateObject private var heartManager = HeartManager()
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
                VStack {
                    VStack {
                        Spacer()
                        Button{
                            sosManager.showSOS.toggle()
                        } label: {
                            VStack(alignment: .leading) {
                                Spacer()
                                HStack(alignment: .center) {
                                    Text("SOS")
                                        .multilineTextAlignment(.leading)
                                        .font(.title)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Image(systemName: "light.beacon.max.fill")
                                        .font(.title2)
                                }
                                Spacer()
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
//                        PairView(
//                            leftText: "Latitude:",
//                            rightText: String(locationVM.lastSeenLocation?.coordinate.latitude ?? 0)
//                        )
//                        PairView(
//                            leftText: "Longitude:",
//                            rightText: String(locationVM.lastSeenLocation?.coordinate.latitude ?? 0)
//                        )
                    }
                    
//                    VStack {
//                        Button("Set Current Location as Home") {
//                            locationVM.shouldSet = true
//                        }
//                    }
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


