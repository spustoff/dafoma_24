//
//  ContentView.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        ZStack {
            Color.neoBackground
                .ignoresSafeArea()
            
            if mainViewModel.showOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(MainViewModel())
}
