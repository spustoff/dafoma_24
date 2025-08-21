//
//  MainTabView.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Content Area
            Group {
                switch mainViewModel.currentTab {
                case .editor:
                    CodeEditorView()
                case .collaboration:
                    CollaborationView()
                case .snippets:
                    SnippetManagerView()
                case .settings:
                    CustomizationView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar()
        }
        .background(Color.neoBackground)
    }
}

struct CustomTabBar: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                NeumorphismTabButton(
                    title: tab.rawValue,
                    systemImage: tab.systemImage,
                    isSelected: mainViewModel.currentTab == tab,
                    action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            mainViewModel.switchTab(to: tab)
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(Color.neoBackground.opacity(0.95))
                .shadow(color: .neoDarkShadow, radius: 4, x: 0, y: -2)
        )
    }
}

#Preview {
    MainTabView()
        .environmentObject(MainViewModel())
}
