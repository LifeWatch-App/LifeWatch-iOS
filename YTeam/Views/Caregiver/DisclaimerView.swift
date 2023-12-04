//
//  DisclaimerView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 04/12/23.
//

import SwiftUI

struct DisclaimerView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("This medical AI platform is designed solely for educational purposes and should not be considered a substitute for professional medical advice, diagnosis, or treatment. The information provided by this AI is based on general knowledge and should not be relied upon as a source of medical guidance.\n\nUsers are strongly advised to consult with qualified healthcare professionals for personalized medical advice, diagnosis, or treatment. The AI-generated content is not intended to replace the expertise and judgment of healthcare professionals, and it may not be accurate, complete, or up-to-date.\n\nThe creators of this AI platform do not endorse or promote self-diagnosis or self-treatment based on the information provided. Any reliance on the information from this AI is at the user's own risk. The platform is not intended for use in emergency situations, and users should seek immediate medical attention for any health concerns.\n\nThe creators of this AI disclaim any liability for any injury, loss, or damage incurred as a result of using or relying on the information provided by the platform. By using this AI, users acknowledge and agree to the limitations and risks associated with educational use and understand that it is not a substitute for professional medical advice.")
                }
                .padding([.horizontal, .bottom])
            }
            .navigationTitle("Medical AI Disclaimer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.accent)
                }
            }
        }
    }
}

#Preview {
    DisclaimerView()
}
