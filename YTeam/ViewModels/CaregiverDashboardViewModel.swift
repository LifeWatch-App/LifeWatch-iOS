//
//  CaregiverEmergencyViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import Foundation
import Combine
import Firebase
import FirebaseAuth
import AVFoundation
import FirebaseStorage

class CaregiverDashboardViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate  {
    @Published var invites: [Invite] = []
    @Published var user: User?
    @Published var userData: UserData?
    private let authService = AuthService.shared 
    private let batteryService = BatteryChargingService.shared
    @Published var batteryInfo: BatteryLevel?
    @Published var latestLocationInfo: LiveLocation?
    @Published var selectedInviteId: String?
    @Published var idleInfo: [Idle] = []
    @Published var heartBeatInfo: Heartbeat?
    private var cancellables = Set<AnyCancellable>()
    @Published var showWalkieTalkie: Bool = false
    @Published var routines: [Routine] = []
//    @Published var heartRate = 90
    @Published var inviteEmail = ""
    
    private var routineData: [RoutineData] = []
    
    private let routineService: RoutineService = RoutineService.shared
    
    override init() {
        super.init()
        setupSubscribers()
        // add dummy data
//        routines = routinesDummyData
    }

    private func setupSubscribers() {
        authService.$user
            .combineLatest(authService.$userData, authService.$invites)
            .sink { [weak self] user, userData, invites in
                guard let self = self else { return }
                if self.user != user {
                    self.user = user
                }

                if self.userData != userData {
                    self.userData = userData
                }

                if self.invites != invites {
                    self.invites = invites
                }
            }
            .store(in: &cancellables)

        authService.$selectedInviteId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedInviteId in
                guard let self = self else { return }
                if self.selectedInviteId != selectedInviteId {
                    self.selectedInviteId = selectedInviteId
                }
            }
            .store(in: &cancellables)

        $selectedInviteId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedInviteId in
                guard let self = self else { return }
                self.batteryService.observeIdleSpecific()
                self.batteryService.observeLiveLocationSpecific()
                self.batteryService.observeBatteryStateLevelSpecific()
                self.batteryService.observeHeartRateSpecific()
            }
            .store(in: &cancellables)

        batteryService.$batteryDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.batteryInfo = self.loadInitialBatteryLevel(documents: documentChanges)
            }
            .store(in: &cancellables)

        batteryService.$idleDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                print(documentChanges.first?.document.data())
                self.idleInfo = self.loadInitialIdleLevel(documents: documentChanges)
            }
            .store(in: &cancellables)

        batteryService.$latestLocationDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                print(documentChanges.first?.document.data())
                self.latestLocationInfo = self.loadLatestLiveLocation(documents: documentChanges)
            }
            .store(in: &cancellables)
      
        routineService.$routines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routines in
                guard let self else { return }
                print("Routine Data", self.routineData)
                print("Updated Single Data", routines)
                for (_, routine) in routines.enumerated() {
                    if let concurrentIndex = self.routineData.firstIndex(where: {$0.id == routine.id}) {
                        self.routineData[concurrentIndex] = routine
                    } else {
                        self.routineData.append(routine)
                    }
                    self.convertRoutineDataToRoutine()
                }
            }
            .store(in: &cancellables)
    }
    
    func convertRoutineDataToRoutine() {
        self.routines = self.routineData.map { routine in
            var medicineUnit: MedicineUnit
            var routineTime: [Date] = []
            
            for time in routine.time {
                routineTime.append( Date(timeIntervalSince1970: time))
            }
            
            switch (routine.medicineUnit) {
            case "CC":
                medicineUnit = .CC
            case "Pill":
                medicineUnit = .Pill
            case "Gram":
                medicineUnit = .Gram
            case "Litre":
                medicineUnit = .Litre
            case "Mililitre":
                medicineUnit = .Mililitre
            default:
                medicineUnit = .Tablet
            }
            
            return Routine(id: routine.id, type: routine.type, seniorId: routine.seniorId, time: routineTime, activity: routine.activity, description: routine.description, medicine: routine.medicine, medicineAmount: routine.medicineAmount, medicineUnit: medicineUnit, isDone: routine.isDone)
        }
        
        if (self.routines.count > 1) {
            self.routines.sort { (routine1, routine2) -> Bool in
                let time1 = routine1.time[0]
                let time2 = routine2.time[0]
                
                return time1 < time2
            }
        }

         batteryService.$heartRateDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.heartBeatInfo = loadInitialHeartBeat(documents: documentChanges)
            }
            .store(in: &cancellables)
    }

    func sendRequestToSenior() {
        AuthService.shared.sendRequestToSenior(email: inviteEmail)
    }

    func signOut() {
        AuthService.shared.signOut()
    }

    private func loadLatestLiveLocation(documents: [DocumentChange]) -> LiveLocation? {
        return try? documents.first?.document.data(as: LiveLocation.self)
    }

    private func loadInitialBatteryLevel(documents: [DocumentChange]) -> BatteryLevel? {
        return try? documents.first?.document.data(as: BatteryLevel.self)
    }

    private func loadInitialIdleLevel(documents: [DocumentChange]) -> [Idle] {
        var idles: [Idle] = []
        for document in documents {
            guard let document = try? document.document.data(as: Idle.self) else {
                print("Not able to decode")
                return []
            }
            idles.append(document)
        }

        return idles
    }

    private func loadInitialHeartBeat(documents: [DocumentChange]) -> Heartbeat? {
        return try? documents.first?.document.data(as: Heartbeat.self)
    }
}
