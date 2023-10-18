//
//  FallViewModel.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 17/10/23.
//

import Foundation
import FirebaseAuth

class FallViewModel: ObservableObject {
    @Published var falls: [Fall] = []
    @Published var loading: Bool = true
    @Published var loggedIn: Bool = false
    
    init() {
        Task{try? await self.fetchAllFalls()}
    }
    
    /// `Calls fetchAllFalls from the FallService`.
    ///
    /// ```
    /// FallViewModel.fetchAllFalls(userId: UserId).
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Array of `Falls` is spread on to the published property `falls` in FallViewModel.
    @MainActor
    func fetchAllFalls() async throws {
        
        // Check if there are current users.
        if ((Auth.auth().currentUser) != nil) {
            self.loggedIn = true
        } else {
            self.loggedIn = false
        }
        
        // Fetching all falls.
        if (self.loggedIn) {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            self.loading = true
            self.falls = try await FallService.fetchAllFalls(userId: userId)
            self.loading = false
        } else {
            return
        }
        
    }
    
}
