//
//  AddRoutineView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI

struct AddRoutineView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                
            }
            .navigationTitle("Add Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.accent)
                }
            }
        }
    }
}

#Preview {
    AddRoutineView()
}
