//
//  CustomizationView.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct CustomizationView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var showResetAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                SettingsHeader()
                
                // Settings sections
                VStack(spacing: 20) {
                    // Appearance
                    SettingsSection(title: "Appearance", icon: "paintbrush.fill", color: .neoYellow) {
                        AppearanceSettings()
                            .environmentObject(mainViewModel)
                    }
                    
                    // Editor
                    SettingsSection(title: "Editor", icon: "doc.text.fill", color: .neoGreen) {
                        EditorSettings()
                            .environmentObject(mainViewModel)
                    }
                    
                    // Collaboration
                    SettingsSection(title: "Collaboration", icon: "person.2.fill", color: .blue) {
                        CollaborationSettings()
                            .environmentObject(mainViewModel)
                    }
                    
                    // About
                    SettingsSection(title: "About", icon: "info.circle.fill", color: .purple) {
                        AboutSection()
                    }
                    
                    // Reset settings
                    NeumorphismCard {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.red)
                                
                                Text("Reset Settings")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            Text("Reset all settings to their default values. This action cannot be undone.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button("Reset All Settings") {
                                showResetAlert = true
                            }
                            .buttonStyle(NeumorphismButtonStyle())
                            .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
        .background(Color.neoBackground)
        .alert("Reset Settings", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                mainViewModel.userSettingsService.resetSettings()
            }
        } message: {
            Text("Are you sure you want to reset all settings to their default values? This action cannot be undone.")
        }
    }
}

struct SettingsHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Customize your NeoCoder Road experience")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 60)
        .padding(.bottom, 30)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        NeumorphismCard {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                content
            }
        }
    }
}

struct AppearanceSettings: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Theme selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Theme")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        ThemeSelectionCard(
                            theme: theme,
                            isSelected: mainViewModel.userSettingsService.settings.theme == theme,
                            onSelect: {
                                mainViewModel.userSettingsService.updateTheme(theme)
                            }
                        )
                    }
                }
            }
        }
    }
}

struct ThemeSelectionCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Theme preview
                RoundedRectangle(cornerRadius: 8)
                    .fill(themePreviewGradient)
                    .frame(width: 60, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.neoYellow : Color.clear, lineWidth: 2)
                    )
                
                Text(theme.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .neoYellow : .white.opacity(0.8))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.neoBackground.opacity(0.5))
                    .shadow(
                        color: isSelected ? .neoYellow.opacity(0.3) : .neoDarkShadow,
                        radius: isSelected ? 4 : 2,
                        x: isSelected ? 0 : 1,
                        y: isSelected ? 2 : 1
                    )
                    .shadow(
                        color: isSelected ? .clear : .neoLightShadow,
                        radius: isSelected ? 0 : 2,
                        x: isSelected ? 0 : -1,
                        y: isSelected ? 0 : -1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var themePreviewGradient: LinearGradient {
        switch theme {
        case .light:
            return LinearGradient(colors: [.white, .gray.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .dark:
            return LinearGradient(colors: [.black, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .system:
            return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct EditorSettings: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Font size
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Font Size")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(Int(mainViewModel.userSettingsService.settings.fontSize))px")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.neoYellow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.neoYellow.opacity(0.2))
                        )
                }
                
                Slider(
                    value: Binding(
                        get: { mainViewModel.userSettingsService.settings.fontSize },
                        set: { mainViewModel.userSettingsService.updateFontSize($0) }
                    ),
                    in: 10...24,
                    step: 1
                )
                .accentColor(.neoYellow)
            }
            
            // Tab size
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Tab Size")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(mainViewModel.userSettingsService.settings.tabSize) spaces")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.neoGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.neoGreen.opacity(0.2))
                        )
                }
                
                Slider(
                    value: Binding(
                        get: { Double(mainViewModel.userSettingsService.settings.tabSize) },
                        set: { mainViewModel.userSettingsService.updateTabSize(Int($0)) }
                    ),
                    in: 2...8,
                    step: 1
                )
                .accentColor(.neoGreen)
            }
            
            // Toggle settings
            VStack(spacing: 16) {
                SettingsToggle(
                    title: "Show Line Numbers",
                    description: "Display line numbers in the code editor",
                    isOn: Binding(
                        get: { mainViewModel.userSettingsService.settings.showLineNumbers },
                        set: { _ in mainViewModel.userSettingsService.toggleLineNumbers() }
                    )
                )
                
                SettingsToggle(
                    title: "Auto Indent",
                    description: "Automatically indent code as you type",
                    isOn: Binding(
                        get: { mainViewModel.userSettingsService.settings.autoIndent },
                        set: { _ in mainViewModel.userSettingsService.toggleAutoIndent() }
                    )
                )
                
                SettingsToggle(
                    title: "Word Wrap",
                    description: "Wrap long lines in the editor",
                    isOn: Binding(
                        get: { mainViewModel.userSettingsService.settings.wordWrap },
                        set: { _ in mainViewModel.userSettingsService.toggleWordWrap() }
                    )
                )
            }
        }
    }
}

struct CollaborationSettings: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            SettingsToggle(
                title: "Enable Collaboration",
                description: "Allow real-time collaboration with other users",
                isOn: Binding(
                    get: { mainViewModel.userSettingsService.settings.enableCollaboration },
                    set: { _ in mainViewModel.userSettingsService.toggleCollaboration() }
                )
            )
            
            if mainViewModel.userSettingsService.settings.enableCollaboration {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Collaboration Features")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureItem(icon: "doc.text.fill", title: "Real-time code sharing")
                        FeatureItem(icon: "person.crop.circle.fill", title: "Live cursor tracking")
                        FeatureItem(icon: "message.fill", title: "Integrated chat system")
                        FeatureItem(icon: "arrow.triangle.branch", title: "Version control integration")
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

struct SettingsToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(title, isOn: $isOn)
                .toggleStyle(NeumorphismToggleStyle())
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .padding(.leading, 4)
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.neoGreen)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}

struct AboutSection: View {
    var body: some View {
        VStack(spacing: 20) {
            // App info
            VStack(spacing: 12) {
                Image(systemName: "laptopcomputer.and.arrow.down")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.neoYellow)
                
                Text("NeoCoder Road")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Version 1.0.0")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Description
            Text("A powerful and versatile code editor and debugger designed for developers who want to code efficiently on iOS.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            // Features
            VStack(alignment: .leading, spacing: 8) {
                Text("Features")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 6) {
                    FeatureItem(icon: "doc.text.fill", title: "Advanced code editor with syntax highlighting")
                    FeatureItem(icon: "ladybug.fill", title: "Powerful debugging tools")
                    FeatureItem(icon: "person.2.fill", title: "Real-time collaboration")
                    FeatureItem(icon: "square.stack.3d.up.fill", title: "Code snippets library")
                    FeatureItem(icon: "chart.line.uptrend.xyaxis", title: "Performance optimization")
                }
            }
            
            // Legal
            VStack(spacing: 8) {
                Text("© 2025 NeoCoder Road. All rights reserved.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                
                HStack(spacing: 16) {
                    Button("Privacy Policy") {
                        // Open privacy policy
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.neoYellow)
                    
                    Button("Terms of Service") {
                        // Open terms of service
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.neoYellow)
                }
            }
        }
    }
}

#Preview {
    CustomizationView()
        .environmentObject(MainViewModel())
}
