//
//  AddSymptomView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI

struct AddSymptomView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var addSymptomViewModel = AddSymptomViewModel()
    
    let columns = [
        GridItem(.adaptive(minimum: 70), alignment: .top),
        GridItem(.adaptive(minimum: 70), alignment: .top),
        GridItem(.adaptive(minimum: 70), alignment: .top),
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Time")) {
                    DatePicker(selection: $addSymptomViewModel.time, in: ...Date.now) {
                        Text("Time")
                    }
                }

                Section(header: Text("Symptom")) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(symptomList, id: \.self) { symptom in
                            VStack {
                                ZStack(alignment: .bottomTrailing) {
                                    Image(symptom)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 48)
                                        .clipShape(Circle())
                                    
                                    if addSymptomViewModel.selectedSymptom == symptom {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.white, .accent)
                                    }
                                }
                                
                                Text(symptom)
                                    .font(.callout)
                                    .foregroundStyle(Color(.label))
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.5)
                            }
                            .onTapGesture {
                                addSymptomViewModel.selectedSymptom = symptom
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                
                Section(header: Text("Notes (optional)")) {
                    TextField("Details about your symptom", text: $addSymptomViewModel.notes)
                }
                
                Section {
                    Button {
                        // add function here
                        Task { try? await addSymptomViewModel.createSymptomDataRecord() }
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text("Add Symptom")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color.accent)
            }
            .navigationTitle("Add Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.accent)
                }
            }
        }
    }
}

#Preview {
    AddSymptomView()
//        .preferredColorScheme(.dark)
}
