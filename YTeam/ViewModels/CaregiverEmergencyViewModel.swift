//
//  CaregiverEmergencyViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import Foundation
import Combine
import FirebaseAuth
import AVFoundation
import FirebaseStorage

class CaregiverEmergencyViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate  {
    @Published var invites: [Invite] = []
    @Published var user: User?
    @Published var userData: UserData?
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()

    var audioPlayer : AVAudioPlayer!
    @Published var recordingsList = [URL]()

    override init() {
        super.init()
        setupSubscribers()
    }

    private func setupSubscribers() {
        service.$user
            .combineLatest(service.$userData, service.$invites)
            .sink { [weak self] user, userData, invites in
                self?.user = user
                self?.userData = userData
                self?.invites = invites
            }
            .store(in: &cancellables)
    }
    
    func sendRequestToSenior(email: String) {
        AuthService.shared.sendRequestToSenior(email: email)
    }
    
    func signOut() {
        AuthService.shared.signOut()
    }
    
    func startRecording(){
        PTT.shared.requestBeginTransmitting()
    }
    
    func stopRecording() {
        PTT.shared.stopTransmitting()
    }
}
