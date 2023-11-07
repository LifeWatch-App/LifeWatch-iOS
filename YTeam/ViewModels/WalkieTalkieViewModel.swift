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
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscribers()
    }

    private func setupSubscribers() {
        utility.$status
            .combineLatest(utility.$isPlaying)
            .sink { [weak self] status, isPlaying in
                self?.status = status
                self?.isPlaying = isPlaying
            }
            .store(in: &cancellables)
    }
    
    func startRecording(){
        PTT.shared.requestBeginTransmitting()
    }
    
    func stopRecording() {
        PTT.shared.stopTransmitting()
    }
}
