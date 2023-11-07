//
//  ChangeSeniorOverlay.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI

struct ChangeSeniorOverlay: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showInviteSheet: Bool
    @Binding var showChangeSenior: Bool
    
    @State var scrollViewContentSize: CGSize = .zero
    
    var body: some View {
        if showChangeSenior {
            HStack {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Senior:")
                            .font(.headline)
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 16) {
                                // Foreach seniornya
                                Button {
                                    
                                } label: {
                                    VStack {
                                        ZStack(alignment: .bottomTrailing) {
                                            ZStack {
                                                Circle()
                                                    .fill(.gray.opacity(0.5))
                                                    .frame(width: 64)
                                                Text("S")
                                                    .font(.title)
                                                    .bold()
                                                    .foregroundStyle(Color(.label))
                                                    .frame(width: 30, height: 30, alignment: .center)
                                                    .padding()
                                            }
                                            
                                            // if selected
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.white, Color("secondary-green"))
                                        }
                                        
                                        Text("Subroto")
                                            .font(.callout)
                                            .foregroundStyle(Color(.label))
                                    }
                                }
                                
                                Button {
                                    
                                } label: {
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(.accent)
                                                .frame(width: 64)
                                            Image(systemName: "plus")
                                                .foregroundStyle(.white)
                                                .font(.title3)
                                                .bold()
                                                .frame(width: 30, height: 30, alignment: .center)
                                                .padding()
                                        }
                                        
                                        Text("Add")
                                            .font(.callout)
                                    }
                                    .onTapGesture {
                                        showInviteSheet = true
                                    }
                                }
                            }
                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        scrollViewContentSize = geo.size
                                    }
                                    return Color.clear
                                }
                            )
                        }
                        .frame(maxWidth: scrollViewContentSize.width)
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.top, 32)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    ChangeSeniorOverlay(showInviteSheet: .constant(false), showChangeSenior: .constant(true))
}
