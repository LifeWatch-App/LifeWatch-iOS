//
//  EnterNameViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 23/11/23.
//

import Foundation

class EnterNameViewModel: ObservableObject {
    @Published var name = ""
    
    func setName() {
        AuthService.shared.setName(name: name)
    }
}
