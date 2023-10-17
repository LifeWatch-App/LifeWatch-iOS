//
//  TestAuthViewModel.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 16/10/23.
//

import Foundation
import Combine

final class TestAuthViewModel: ObservableObject {
    @Published private(set) var userAuth: UserRecord?
    private let service = TestAuthConnector()
    private let decoder = JSONDecoder()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        initializerObserver()
    }
    
    func initializerObserver() {
        service.$userRecord
            .receive(on: DispatchQueue.main)
            .sink { [weak self] record in
                if let record {
                    self?.userAuth = record
                } else {
                    guard let data = UserDefaults.standard.data(forKey: "user-auth") else { return }
                    self?.userAuth = try? self?.decoder.decode(UserRecord.self, from: data)
                }
            }
            .store(in: &cancellables)
    }
}
