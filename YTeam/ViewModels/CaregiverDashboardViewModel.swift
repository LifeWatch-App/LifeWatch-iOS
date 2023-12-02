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
import CoreData


class CaregiverDashboardViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var invites: [Invite] = []
    @Published var user: User?
    @Published var userData: UserData?
    @Published var falls: [Fall] = []
    @Published var sos: [SOS] = []
    let authService = AuthService.shared
    let analysisService = AnalysisService.shared
    private let batteryService = BatteryChargingService.shared
    private let heartRateService = HeartRateService.shared
    private let locationService = DashboardLocationService.shared
    private let idleService = IdleService.shared
    private let symptomService = SymptomService.shared
    private let fallService = FallService.shared
    private let sosService = SOSService.shared
    @Published var batteryInfo: BatteryLevel?
    @Published var latestLocationInfo: LiveLocation?
    @Published var selectedInviteId: String?
    @Published var idleInfo: [Idle] = []
    @Published var heartBeatInfo: Heartbeat?
    @Published var latestSymptomInfo: Symptom?
    @Published var showWalkieTalkie: Bool = false
    @Published var isJoined: Bool = false
    @Published var isPlaying: Bool = false
    @Published var speakerName: String = ""
    @Published var routines: [Routine] = []
    @Published var inviteEmail = ""
    
    var analysisData: [Analysis] = []
    var analysisResult: [Message] = []
    @Published var analysis: String = ""
    @Published var analysisDate: Date = Date()
    @Published var isLoadingAnalysis: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var routineData: [RoutineData] = []
    private let routineService: RoutineService = RoutineService.shared

    override init() {
        super.init()
        print("Test init")
        setupSubscribers()
        
        //fetchAnalysisData()
        // add dummy data
        //        routines = routinesDummyData
    }
    
    private func setupSubscribers() {
        print("Test called")
        authService.$user
            .combineLatest(authService.$userData, authService.$invites)
            .sink { [weak self] user, userData, invites in
                guard let self = self else { return }
                if self.user != user {
                    self.user = user
                }
                
                if self.userData != userData {
                    self.userData = userData
                    print("UserData", userData)
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
                self.selectedInviteId = selectedInviteId
            }
            .store(in: &cancellables)
        
        $selectedInviteId
            .combineLatest($userData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedInviteId, userData in
                guard let self = self else { return }
                if selectedInviteId != nil && userData?.role != nil {
                    self.idleInfo = []
                    self.batteryInfo = nil
                    self.latestLocationInfo = nil
                    self.heartBeatInfo = nil
                    self.latestSymptomInfo = nil
                    self.routineData = []
                    self.routines = []
                    self.falls = []
                    self.sos = []
                    self.idleService.observeIdleSpecific()
                    self.locationService.observeLiveLocationSpecific()
                    self.batteryService.observeBatteryStateLevelSpecific()
                    self.heartRateService.observeHeartRateSpecific(userData: userData)
                    self.symptomService.observeLatestSyptoms(userData: userData)
                    self.fallService.observeTodayFalls(userData: userData)
                    self.sosService.observeTodaySOS(userData: userData)
                    self.routineService.observeAllRoutines(userData: userData)
                    self.routineService.observeAllDeletedRoutines(userData: userData)
                }
            }
            .store(in: &cancellables)
        
        symptomService.$symptomsLatestDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.latestSymptomInfo = self.loadLatestSymptom(documents: documentChanges)
            }
            .store(in: &cancellables)
        
        batteryService.$batteryDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.batteryInfo = self.loadInitialBatteryLevel(documents: documentChanges)
            }
            .store(in: &cancellables)
        
        idleService.$idleDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.idleInfo = self.loadInitialIdleLevel(documents: documentChanges)
            }
            .store(in: &cancellables)
        
        locationService.$latestLocationDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                self.latestLocationInfo = self.loadLatestLiveLocation(documents: documentChanges)
            }
            .store(in: &cancellables)
        
        heartRateService.$heartRateDocumentChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documentChanges in
                guard let self = self else { return }
                print("DocumentChanges", documentChanges)
                self.heartBeatInfo = loadInitialHeartBeat(documents: documentChanges)
            }
            .store(in: &cancellables)
        
        routineService.$routines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routines in
                guard let self else { return }
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

        routineService.$deletedRoutine
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routines in
                guard let self else { return }
                guard routines.count > 0 else {return}
                print(routines)
                if let index = self.routineData.firstIndex(where: { $0.id == routines[0].id }) {
                    self.routineData.remove(at: index)
                }
                routineService.removeDeletedRoutines()
                self.convertRoutineDataToRoutine()
            }
            .store(in: &cancellables)
        
        PTT.shared.$isJoined
            .receive(on: DispatchQueue.main)
            .combineLatest(PTT.shared.$speakerName, PTT.shared.$isPlaying)
            .sink { [weak self] isJoined, speakerName, isPlaying in
                self?.isJoined = isJoined
                self?.speakerName = speakerName
                self?.isPlaying = isPlaying
            }
            .store(in: &cancellables)
        
        fallService.$fallsToday
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fall in
                guard let self else { return }
                
                self.falls.append(contentsOf: fall)
            }
            .store(in: &cancellables)
        
        sosService.$sosToday
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sos in
                guard let self else {return}
                
                self.sos.append(contentsOf: sos)
            }
            .store(in: &cancellables)
        
        analysisService.$analysisData
            .receive(on: DispatchQueue.main)
            .combineLatest(analysisService.$analysisResult, analysisService.$analysis, analysisService.$analysisDate)
            .sink { [weak self] analysisData, analysisResult, analysis, analysisDate in
                self?.analysisData = analysisData
                self?.analysisResult = analysisResult
                self?.analysis = analysis
                self?.analysisDate = analysisDate
            }
            .store(in: &cancellables)
        
        analysisService.$isLoadingAnalysis
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoadingAnalysis in
                self?.isLoadingAnalysis = isLoadingAnalysis
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
        
        let today = Calendar.current.startOfDay(for: Date())
        
        self.routines = self.routines.filter({ routine in
            guard let routineDate = routine.time.first else {
                return false
            }
            return routineDate > today
        })
    }
    
    func checkAnalysis() {
        if let analysis = analysisData.filter({$0.seniorId == selectedInviteId}).first {
            self.analysis = analysis.result ?? ""
            self.analysisDate = analysis.date ?? Date()
        }

        if (analysisData.filter({$0.seniorId == selectedInviteId}).first?.date ?? Calendar.current.date(byAdding: .day, value: -2, to: Date())) ?? Date() < Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date() {
            isLoadingAnalysis = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                self.createAnalysis()
            }
        }
    }
    
    func createAnalysis() {
        analysisResult = []
        
        var heartBeatString = ""
        var symptomString = ""
        
        let fallString = "My senior had \(falls.count) fall today and \(sos.count) sos button pressed today. "
        if let bpm = heartBeatInfo?.bpm {
            heartBeatString = "Their heartbeat is \(bpm) bpm. "
        }
        if latestSymptomInfo != nil {
            symptomString = "They have had a \(String(describing: latestSymptomInfo?.name)) symptom lately. "
        } else {
            symptomString = "They had no symptom lately. "
        }
        
        let prompt = fallString + heartBeatString + symptomString + "Create a health analysis in 50 words."

        let newMessage = Message(id: UUID(), role: .user, content: prompt, createdAt: Date())
        analysisResult.append(newMessage)

        Task {
            defer {
                isLoadingAnalysis = false
            }

            let response = await OpenAIService.shared.sendMessage(messages: self.analysisResult)
            guard let receivedOpenAIMessage = response?.choices.first?.message else {
                print("Had no received message")
                return
            }

            let receivedMessage = Message(id: UUID(), role: receivedOpenAIMessage.role, content: receivedOpenAIMessage.content, createdAt: Date())
            await MainActor.run {
                analysis = receivedMessage.content
                analysisDate = receivedMessage.createdAt

                addAnalysis(seniorId: selectedInviteId ?? "", result: receivedMessage.content, date: Date())
            }
        }
    }
    
    func fetchAnalysisData() {
        let request = NSFetchRequest<Analysis>(entityName: "Analysis")
        
        do {
            analysisData = try PersistenceController.shared.container.viewContext.fetch(request)
            print("Fetch Success")
        } catch let error {
            print("Fetch Error: \(error)")
        }
    }
    
    func addAnalysis(seniorId: String, result: String, date: Date) {
        if let analysis = analysisData.filter({$0.seniorId == seniorId}).first {
            analysis.result = result
            analysis.date = date
        } else {
            let analysis = Analysis(context: PersistenceController.shared.container.viewContext)
            analysis.seniorId = seniorId
            analysis.result = result
            analysis.date = date
        }
        
        do {
            try PersistenceController.shared.container.viewContext.save()
            fetchAnalysisData()
        } catch {
            print("Could not save analysis data")
        }
    }
    
    func resetAnalysis() {
        print("Reset called")
        analysisData = []
        analysisResult = []
        analysis = ""
        analysisDate = Date()
        isLoadingAnalysis = false
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
    
    private func loadLatestSymptom(documents: [DocumentChange]) -> Symptom? {
        return try? documents.first?.document.data(as: Symptom.self)
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
    
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format

        return formatter.string(from: date)
    }
}
