//
//  OnBoardingView.swift
//  YTeam
//
//  Created by Maximus Aurelius Wiranata on 13/11/23.
//

import SwiftUI

struct OnBoardingView: View {
    @Binding var currentOnBoarding: Int
    
    var body: some View {
        ZStack {
            if currentOnBoarding == 1 {
                OnBoardingTemplate(currentOnBoarding: $currentOnBoarding, image: "OnBoarding-1", title: "Welcome", description: "We're honored to support you let's make caring seamless!")
            } else if currentOnBoarding == 2 {
                OnBoardingTemplate(currentOnBoarding: $currentOnBoarding, image: "OnBoarding-2", title: "Emergency", description: "Peace of mind at your fingertips! Our emergency features is designed to keep seniors safe and sound.")
            } else if currentOnBoarding == 3 {
                OnBoardingTemplate(currentOnBoarding: $currentOnBoarding, image: "OnBoarding-3", title: "Routine", description: "Every routine, effortlessly managed. Elevate their day with our senior-friendly reminder feature.")
            } else if currentOnBoarding == 4 {
                OnBoardingTemplate(currentOnBoarding: $currentOnBoarding, image: "OnBoarding-4", title: "AI Consultation", description: "Virtual healthcare, personalized for you. Explore the convenience of AI consultations in our app.")
            } else {
                OnBoardingTemplate(currentOnBoarding: $currentOnBoarding, image: "OnBoarding-5", title: "Walkie-Talkie", description: "Seamless, instant communication with background-enabled push-to-talk functionality for efficiency.")
            }
        }
        .transition(.opacity)
    }
}

#Preview {
    OnBoardingView(currentOnBoarding: .constant(1))
}

struct OnBoardingTemplate: View {
    @AppStorage("onBoardingDone") var onBoardingDone = false
    
    @Binding var currentOnBoarding: Int
    
    let image: String
    let title: String
    let description: String
    
    var body: some View {
        VStack {
            HStack {
                if currentOnBoarding > 1 {
                    Button("Back") {
                        withAnimation {
                            currentOnBoarding -= 1
                        }
                    }
                    .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button("Skip") {
                    withAnimation {
                        onBoardingDone = true
                        currentOnBoarding = 6
                    }
                }
                .fontWeight(.semibold)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack {
                VStack {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                }
                .frame(height: Screen.height / 2.25)
                
                Text(title)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    .padding(.bottom, 4)
                
                Text(description)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            HStack (spacing: 8) {
                Circle()
                    .frame(width: 8)
                    .foregroundStyle(currentOnBoarding == 1 ? .white : .gray)
                Circle()
                    .frame(width: 8)
                    .foregroundStyle(currentOnBoarding == 2 ? .white : .gray)
                Circle()
                    .frame(width: 8)
                    .foregroundStyle(currentOnBoarding == 3 ? .white : .gray)
                Circle()
                    .frame(width: 8)
                    .foregroundStyle(currentOnBoarding == 4 ? .white : .gray)
                Circle()
                    .frame(width: 8)
                    .foregroundStyle(currentOnBoarding == 5 ? .white : .gray)
            }
            .padding(.top, 8)
            .padding(.bottom, 32)
            
            Button {
                withAnimation {
                    currentOnBoarding += 1
                }
                if currentOnBoarding == 6 {
                    onBoardingDone = true
                }
            } label: {
                HStack {
                    Spacer()
                    
                    Text(currentOnBoarding < 5 ? "Next" : "Lets Get Started!")
                        .font(.headline)
                        .foregroundStyle(.accent)
                    
                    Spacer()
                }
                .padding(12)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            }
        }
        .foregroundStyle(.white)
        .background(.accent)
    }
}
