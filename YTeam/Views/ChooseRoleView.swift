//
//  ChooseRoleView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 16/10/23.
//

import SwiftUI

struct ChooseRoleView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var mainViewModel: MainViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack(alignment: .top) {
                    VStack {
                        VStack {
                            EmptyView()
                        }
                        .frame(height: 140)
                        
                        HStack {
                            Text("As a senior, ...")
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        
                        HStack {
                            Spacer()
                            Button {
                                mainViewModel.setRole(role: "senior")
                            } label: {
                                Text("Choose")
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(.accent)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    HStack(spacing: 16) {
                        VStack {
                            Spacer()
                            Image("Senior")
                                .resizable()
                                .scaledToFit()
                                .padding(.bottom, -1)
                        }
                        .frame(height: 150)
                        
                        HStack {
                            Spacer()
                            Text("Senior")
                                .font(.title)
                                .bold()
                                .foregroundStyle(.white)
                                .padding(.trailing)
                            Spacer()
                        }
                    }
                    .padding(.trailing)
                    .background(.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                ZStack(alignment: .top) {
                    VStack {
                        VStack {
                            EmptyView()
                        }
                        .frame(height: 140)
                        
                        HStack {
                            Text("As a caregiver, ...")
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        
                        HStack {
                            Spacer()
                            Button {
                                mainViewModel.setRole(role: "caregiver")
                            } label: {
                                Text("Choose")
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(.accent)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    HStack(spacing: 16) {
                        VStack {
                            Spacer()
                            Image("Caregiver")
                                .resizable()
                                .scaledToFit()
                                .padding(.bottom, -1)
                        }
                        .frame(height: 150)
                        
                        HStack {
                            Spacer()
                            Text("Caregiver")
                                .font(.title)
                                .bold()
                                .foregroundStyle(.white)
                            Spacer()
                        }
                    }
                    .padding(.trailing)
                    .background(.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Spacer()
            }
            .toolbar {
                Button(
                    action: {
                        mainViewModel.signOut()
                    },
                    label: {
                        Text("Sign Out")
                            .bold()
                    }
                )
            }
            .padding()
            .background(colorScheme == .light ? Color(.systemGroupedBackground) : .black)
            .navigationTitle("Choose Role")
        }
    }
}

#Preview {
    ChooseRoleView(mainViewModel: MainViewModel())
//        .preferredColorScheme(.dark)
}
