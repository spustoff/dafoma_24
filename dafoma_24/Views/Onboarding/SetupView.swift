//
//  SetupView.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct SetupView: View {
    @Binding var currentPage: Int
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @State private var selectedTheme: AppTheme = .dark
    @State private var fontSize: Double = 14.0
    @State private var showLineNumbers = true
    @State private var enableCollaboration = true
    @State private var userName = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Text("Customize Your Experience")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Configure NeoCoder Road to match your coding style")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                // Setup Options
                VStack(spacing: 24) {
                    // User Name
                    setupSection("Profile", systemImage: "person.circle.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("Enter your name", text: $userName)
                                .textFieldStyle(NeumorphismTextFieldStyle())
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Theme Selection
                    setupSection("Appearance", systemImage: "paintbrush.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Theme")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                ForEach(AppTheme.allCases, id: \.self) { theme in
                                    ThemeOption(
                                        theme: theme,
                                        isSelected: selectedTheme == theme,
                                        action: { selectedTheme = theme }
                                    )
                                }
                            }
                        }
                    }
                    
                    // Editor Settings
                    setupSection("Editor", systemImage: "doc.text.fill") {
                        VStack(alignment: .leading, spacing: 16) {
                            // Font Size
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Font Size")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(fontSize))px")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.neoYellow)
                                }
                                
                                Slider(value: $fontSize, in: 10...24, step: 1)
                                    .accentColor(.neoYellow)
                            }
                            
                            // Toggle Options
                            VStack(spacing: 12) {
                                Toggle("Show Line Numbers", isOn: $showLineNumbers)
                                    .toggleStyle(NeumorphismToggleStyle())
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    // Collaboration Settings
                    setupSection("Collaboration", systemImage: "person.2.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Enable Real-time Collaboration", isOn: $enableCollaboration)
                                .toggleStyle(NeumorphismToggleStyle())
                                .foregroundColor(.white)
                            
                            if enableCollaboration {
                                Text("You can share code and collaborate with others in real-time")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }
                
                Spacer(minLength: 40)
                
                // Complete Setup Button
                Button(action: {
                    completeSetup()
                }) {
                    HStack {
                        Text("Complete Setup")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.neoYellow)
                            .shadow(color: .neoYellow.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.neoBackground)
    }
    
    @ViewBuilder
    private func setupSection<Content: View>(
        _ title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.neoGreen)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.neoBackground)
                .shadow(color: .neoLightShadow, radius: 4, x: -2, y: -2)
                .shadow(color: .neoDarkShadow, radius: 4, x: 2, y: 2)
        )
        .padding(.horizontal, 20)
    }
    
    private func completeSetup() {
        // Save settings
        mainViewModel.userSettingsService.updateTheme(selectedTheme)
        mainViewModel.userSettingsService.updateFontSize(fontSize)
        mainViewModel.userSettingsService.settings.showLineNumbers = showLineNumbers
        mainViewModel.userSettingsService.settings.enableCollaboration = enableCollaboration
        mainViewModel.userSettingsService.saveSettings()
        
        // Complete onboarding
        withAnimation(.easeInOut(duration: 0.5)) {
            mainViewModel.completeOnboarding()
        }
    }
}

struct ThemeOption: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(themeColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.neoYellow : Color.clear, lineWidth: 3)
                    )
                
                Text(theme.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .neoYellow : .white.opacity(0.7))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var themeColor: Color {
        switch theme {
        case .light: return .white
        case .dark: return .black
        case .system: return .gray
        }
    }
}

#Preview {
    SetupView(currentPage: .constant(2))
        .environmentObject(MainViewModel())
}
