//
//  FallViewModel.swift
//  YTeam
//
//  Created by Kenny Jinhiro Wibowo on 17/10/23.
//

import Foundation

class FallViewModel: ObservableObject {
    @Published var falls: [Fall] = []
    
    init() {
        Task{try? await self.fetchAllFalls()}
    }
    
    /// `Calls fetchAllFalls from the FallService`.
    ///
    /// ```
    /// FallViewModel.fetchAllFalls().
    /// ```
    ///
    /// - Parameters:
    ///     - None
    /// - Returns: Array of `Falls` is spread on to the published property `falls` in FallViewModel.
    @MainActor
    func fetchAllFalls() async throws {
        self.falls = try await FallService.fetchAllFalls()
    }
    
}
