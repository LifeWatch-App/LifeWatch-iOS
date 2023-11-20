//
//  WalkieTalkieViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 07/11/23.
//

import Foundation
import Combine

class WalkieTalkieViewModel: ObservableObject {
    private let utility = PTT.shared
    @Published var status: String?
    @Published var isPlaying: Bool?
    @Published var speakerName = ""
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscribers()
    }

    private func setupSubscribers() {
        utility.$status
            .combineLatest(utility.$isPlaying, utility.$speakerName)
            .sink { [weak self] status, isPlaying, speakerName in
                self?.status = status
                self?.isPlaying = isPlaying
                self?.speakerName = speakerName
            }
            .store(in: &cancellables)
    }
    
    func startRecording(){
        PTT.shared.requestBeginTransmitting()
    }
    
    func stopRecording() {
        PTT.shared.stopTransmitting()
    }
    
    func joinChannel() {
        PTT.shared.requestJoinChannel()
    }
    
    func leaveChannel() {
        PTT.shared.leaveChannel()
    }
}
