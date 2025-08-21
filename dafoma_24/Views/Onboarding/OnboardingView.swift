//
//  OnboardingView.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var currentPage = 0
    
    private let totalPages = 3
    
    var body: some View {
        ZStack {
            Color.neoBackground
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                IntroductionView(currentPage: $currentPage)
                    .tag(0)
                
                FeatureTourView(currentPage: $currentPage)
                    .tag(1)
                
                SetupView(currentPage: $currentPage)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            // Skip Button
            VStack {
                HStack {
                    Spacer()
                    
                    if currentPage < totalPages - 1 {
                        Button("Skip") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                mainViewModel.completeOnboarding()
                            }
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }
                }
                
                Spacer()
            }
            
            // Progress Indicator
            VStack {
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.neoYellow : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(MainViewModel())
}
