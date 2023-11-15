//
//  ChangeSeniorOverlay.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI

struct ChangeSeniorOverlay: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: CaregiverDashboardViewModel
//    @Binding var invites: [Invite]
//    @Binding var selectedUserId: String?
    @Binding var showInviteSheet: Bool
    @Binding var showChangeSenior: Bool
    let service = AuthService.shared

    @State var scrollViewContentSize: CGSize = .zero

    var body: some View {
        if showChangeSenior {
            HStack {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Senior:")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // Foreach seniornya
                                ForEach(vm.invites) { invite in
                                    if invite.accepted ?? false {
                                        Button {
                                            if vm.selectedInviteId != invite.seniorId {
                                                //CHANGES AUTHSERVICESENIORID HERE
                                                vm.authService.selectedInviteId = invite.seniorId
                                                /*electedUserId = invite.seniorId*/
                                                UserDefaults.standard.set(invite.seniorId, forKey: "selectedSenior")
                                                print(UserDefaults.standard.object(forKey: "selectedSenior"))
                                            }
                                        } label: {
                                            VStack {
                                                ZStack(alignment: .bottomTrailing) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(.gray.opacity(0.5))
                                                            .frame(width: 64)
                                                        Text("\(invite.seniorData?.name?.first?.description ?? "S")")
                                                            .font(.title)
                                                            .bold()
                                                            .foregroundStyle(Color(.label))
                                                            .frame(width: 30, height: 30, alignment: .center)
                                                            .padding()
                                                    }

                                                    // if selected
                                                    if vm.selectedInviteId == invite.seniorId {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundStyle(.white, Color("secondary-green"))
                                                    }
                                                }

                                                Text("\(invite.seniorData?.name ?? "Subroto")")
                                                    .font(.callout)
                                                    .foregroundStyle(Color(.label))
                                            }
                                        }
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
                .contentShape(Rectangle())
                .onTapGesture {
                    showChangeSenior = false
                }

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showChangeSenior = false
            }
        }
    }
}

//#Preview {
//    ChangeSeniorOverlay(showInviteSheet: .constant(false), invites: <#Binding<[Invite]>#>, showChangeSenior: .constant(true))
//}
