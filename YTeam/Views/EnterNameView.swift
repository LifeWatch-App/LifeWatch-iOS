//
//  EnterNameView.swift
//  YTeam
//
//  Created by Yap Justin on 23/11/23.
//

import Foundation
import SwiftUI

struct EnterNameView: View {
    @StateObject var enterNameViewModel: EnterNameViewModel = EnterNameViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Image("Login")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 32)
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .leading) {
                        Text("Please enter your name. Your name will be used by your seniors/caregivers to identify you.")
                        TextField("Name", text: $enterNameViewModel.name)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray3), lineWidth: 1)
                            )
                            .keyboardType(.default)
                    }
                    .padding(.vertical, 12)
                    
                   
                    Button {
                        enterNameViewModel.setName()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Submit")
                                .fontWeight(.semibold)
                                .padding()
                            Spacer()
                        }
                        .background(.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.top, 8)
                }
                .padding()
                .navigationTitle("Enter Your Name")
            }
        }
    }
}

#Preview {
    LoginView()
        .preferredColorScheme(.dark)
}
