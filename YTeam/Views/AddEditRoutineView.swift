//
//  AddRoutineView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 05/11/23.
//

import SwiftUI

struct AddEditRoutineView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var addEditRoutineViewModel = AddEditRoutineViewModel()
    
    let currentDay: Date
    let routine: Routine?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Routine Type", selection: $addEditRoutineViewModel.type) {
                        Text("Medicine")
                            .tag("Medicine")
                        Text("Activity")
                            .tag("Activity")
                    }
                } header: {
                    Text("type")
                }
                
                if addEditRoutineViewModel.type == "Medicine" {
                    Section {
                        HStack {
                            Text("Medicine")
                            Spacer()
                            TextField("Type here", text: $addEditRoutineViewModel.medicine)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Amount")
                            Spacer()
                            TextField("0", text: $addEditRoutineViewModel.medicineAmount)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                            Picker("", selection: $addEditRoutineViewModel.medicineUnit) {
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
                            TextField("Type here", text: $addEditRoutineViewModel.activity)
                                .multilineTextAlignment(.trailing)
                        }
                    } header: {
                        Text("activity detail")
                    }
                    
                    Section {
                        TextEditor(text: $addEditRoutineViewModel.description)
                    } header: {
                        Text("Activity Description")
                    }
                }
                
                Section {
                    HStack {
                        Text("Times per day")
                        Spacer()
                        Stepper("", value: $addEditRoutineViewModel.timeAmount, in: 1...3)
                        Text("\(addEditRoutineViewModel.timeAmount)")
                    }
                    
                    ForEach(0..<addEditRoutineViewModel.timeAmount, id: \.self) { i in
                        DatePicker(selection: $addEditRoutineViewModel.times[i], displayedComponents: .hourAndMinute) {
                            Text("Time \(i+1)")
                        }
                    }
                } header: {
                    Text("time")
                }
                
                Section {
                    Button {
                        // add function here
                        if (routine == nil) {
                            self.addEditRoutineViewModel.convertRoutineDataIntoRoutine(editOrAdd: "add")
                        } else if (routine != nil) {
                            self.addEditRoutineViewModel.convertRoutineDataIntoRoutine(editOrAdd: "edit")
                        }
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text(routine == nil ? "Add Routine" : "Edit Routine")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color.accent)
                
                if routine != nil {
                    Section {
                        Button {
                            // add function here
                            self.addEditRoutineViewModel.convertRoutineDataIntoRoutine(editOrAdd: "delete")
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                
                                Text("Delete Routine")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color("emergency-pink"))
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(routine == nil ? "Add Routine" : "Edit Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.accent)
                }
            }
            .onAppear {
                for (index, _) in addEditRoutineViewModel.times.enumerated() {
                    addEditRoutineViewModel.times[index] = currentDay
                }
                
                if let routine = routine {
                    addEditRoutineViewModel.type = routine.type
                    addEditRoutineViewModel.timeAmount = routine.time.count
                    addEditRoutineViewModel.activity = routine.activity ?? ""
                    addEditRoutineViewModel.description = routine.description ?? ""
                    addEditRoutineViewModel.medicine = routine.medicine ?? ""
                    addEditRoutineViewModel.medicineAmount = routine.medicineAmount ?? ""
                    addEditRoutineViewModel.medicineUnit = routine.medicineUnit ?? .Tablet
                    addEditRoutineViewModel.routineId = routine.id 
                    
                    for (index, time) in routine.time.enumerated() {
                        addEditRoutineViewModel.times[index] = time
                    }
                }
            }
        }
    }
}

#Preview {
    AddEditRoutineView(currentDay: Date(), routine: nil)
}
