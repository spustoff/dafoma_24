//
//  UserSettingsService.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation

@MainActor
class UserSettingsService: ObservableObject {
    @Published var settings: UserSettings
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "UserSettings"
    
    init() {
        if let data = userDefaults.data(forKey: settingsKey),
           let decodedSettings = try? JSONDecoder().decode(UserSettings.self, from: data) {
            self.settings = decodedSettings
        } else {
            self.settings = UserSettings.default
            saveSettings()
        }
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: settingsKey)
        }
    }
    
    func updateTheme(_ theme: AppTheme) {
        settings.theme = theme
        saveSettings()
    }
    
    func updateFontSize(_ size: Double) {
        settings.fontSize = max(10, min(24, size))
        saveSettings()
    }
    
    func toggleLineNumbers() {
        settings.showLineNumbers.toggle()
        saveSettings()
    }
    
    func toggleAutoIndent() {
        settings.autoIndent.toggle()
        saveSettings()
    }
    
    func toggleWordWrap() {
        settings.wordWrap.toggle()
        saveSettings()
    }
    
    func updateTabSize(_ size: Int) {
        settings.tabSize = max(2, min(8, size))
        saveSettings()
    }
    
    func toggleCollaboration() {
        settings.enableCollaboration.toggle()
        saveSettings()
    }
    
    func completeOnboarding() {
        settings.hasCompletedOnboarding = true
        saveSettings()
    }
    
    func resetSettings() {
        settings = UserSettings.default
        saveSettings()
    }
}
