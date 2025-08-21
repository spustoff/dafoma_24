//
//  MainViewModel.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @Published var currentTab: MainTab = .editor
    @AppStorage("showonboarding") var showOnboarding = false
    @Published var isLoading = false
    
    let fileService = FileService()
    let networkService = NetworkService()
    let userSettingsService = UserSettingsService()
    
    init() {
        checkOnboardingStatus()
    }
    
    private func checkOnboardingStatus() {
        showOnboarding = !userSettingsService.settings.hasCompletedOnboarding
    }
    
    func completeOnboarding() {
        userSettingsService.completeOnboarding()
        showOnboarding = false
    }
    
    func switchTab(to tab: MainTab) {
        currentTab = tab
    }
}

enum MainTab: String, CaseIterable {
    case editor = "Editor"
    case collaboration = "Collaborate"
    case snippets = "Snippets"
    case settings = "Settings"
    
    var systemImage: String {
        switch self {
        case .editor: return "doc.text"
        case .collaboration: return "person.2"
        case .snippets: return "square.stack.3d.up"
        case .settings: return "gear"
        }
    }
}
