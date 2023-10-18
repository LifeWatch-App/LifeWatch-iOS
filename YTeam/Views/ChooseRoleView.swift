//
//  ChooseRoleView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 16/10/23.
//

import SwiftUI

struct ChooseRoleView: View {
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                VStack {
                    VStack {
                        EmptyView()
                    }
                    .frame(height: 140)
                    
                    HStack {
                        Text("Lorem ipsum dolor sit amet")
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    HStack {
                        Spacer()
                        Button {
                            
                        } label: {
                            Text("Choose")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(.accent)
                                .cornerRadius(4)
                        }
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(16)
                
                HStack(spacing: 16) {
                    VStack {
                        Spacer()
                        Image("asset")
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
                .cornerRadius(16)
            }
            
            ZStack(alignment: .top) {
                VStack {
                    VStack {
                        EmptyView()
                    }
                    .frame(height: 140)
                    
                    HStack {
                        Text("Lorem ipsum dolor sit amet")
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    HStack {
                        Spacer()
                        Button {
                            
                        } label: {
                            Text("Choose")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(.accent)
                                .cornerRadius(4)
                        }
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(16)
                
                HStack(spacing: 16) {
                    VStack {
                        Spacer()
                        Image("asset")
                            .resizable()
                            .scaledToFit()
                            .padding(.bottom, -1)
                    }
                    .frame(height: 150)
                    
                    HStack {
                        Spacer()
                        Text("Caretaker")
                            .font(.title)
                            .bold()
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
                .padding(.trailing)
                .background(.accent)
                .cornerRadius(16)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Choose Role")
    }
}

#Preview {
    ChooseRoleView()
}
