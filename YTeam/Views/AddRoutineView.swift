//
//  AddRoutineView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI

struct AddRoutineView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var addRoutineViewModel = AddRoutineViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Routine Type", selection: $addRoutineViewModel.type) {
                        Text("Medicine")
                            .tag("Medicine")
                        Text("Activity")
                            .tag("Activity")
                    }
                } header: {
                    Text("type")
                }
                
                if addRoutineViewModel.type == "Medicine" {
                    Section {
                        HStack {
                            Text("Medicine")
                            Spacer()
                            TextField("Type here", text: $addRoutineViewModel.medicine)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Amount")
                            Spacer()
                            TextField("0", text: $addRoutineViewModel.medicineAmount)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                            Picker("", selection: $addRoutineViewModel.medicineUnit) {
                                ForEach(MedicineUnit.allCases) { unit in
                                    Text(unit.rawValue)
                                }
                            }
                        }
                    } header: {
                        Text("medicine detail")
                    }
                } else {
                    Section {
                        HStack {
                            Text("Activity Name")
                            Spacer()
                            TextField("Type here", text: $addRoutineViewModel.activity)
                                .multilineTextAlignment(.trailing)
                        }
                    } header: {
                        Text("activity detail")
                    }
                    
                    Section {
                        TextEditor(text: $addRoutineViewModel.description)
                    } header: {
                        Text("Activity Description")
                    }
                }
                
                Section {
                    HStack {
                        Text("Times per day")
                        Spacer()
                        Stepper("", value: $addRoutineViewModel.timeAmount, in: 1...3)
                        Text("\(addRoutineViewModel.timeAmount)")
                    }
                    
                    ForEach(0..<addRoutineViewModel.timeAmount, id: \.self) { i in
                        DatePicker(selection: $addRoutineViewModel.times[i], in: ...Date.now, displayedComponents: .hourAndMinute) {
                            Text("Time \(i+1)")
                        }
                    }
                } header: {
                    Text("time")
                }
                
                Section {
                    Button {
                        // add function here
                        
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text("Add Routine")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color.accent)
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
