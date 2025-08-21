//
//  NeumorphismStyle.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

// MARK: - App Colors
extension Color {
    static let neoBackground = Color(hex: "#3e4464")
    static let neoYellow = Color(hex: "#fcc418")
    static let neoGreen = Color(hex: "#3cc45b")
    
    static let neoLightShadow = Color.white.opacity(0.1)
    static let neoDarkShadow = Color.black.opacity(0.3)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Neumorphism Button Style
struct NeumorphismButtonStyle: ButtonStyle {
    var color: Color = .neoBackground
    var isPressed: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .shadow(
                        color: configuration.isPressed ? .neoDarkShadow : .neoLightShadow,
                        radius: configuration.isPressed ? 2 : 4,
                        x: configuration.isPressed ? -1 : -2,
                        y: configuration.isPressed ? -1 : -2
                    )
                    .shadow(
                        color: configuration.isPressed ? .neoLightShadow : .neoDarkShadow,
                        radius: configuration.isPressed ? 2 : 4,
                        x: configuration.isPressed ? 1 : 2,
                        y: configuration.isPressed ? 1 : 2
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Neumorphism Card Style
struct NeumorphismCard<Content: View>: View {
    let content: Content
    var color: Color = .neoBackground
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16
    
    init(color: Color = .neoBackground, cornerRadius: CGFloat = 16, padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.color = color
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
                    .shadow(color: .neoLightShadow, radius: 4, x: -2, y: -2)
                    .shadow(color: .neoDarkShadow, radius: 4, x: 2, y: 2)
            )
    }
}

// MARK: - Neumorphism Text Field Style
struct NeumorphismTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.neoBackground)
                    .shadow(color: .neoDarkShadow, radius: 3, x: 2, y: 2)
                    .shadow(color: .neoLightShadow, radius: 3, x: -2, y: -2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Neumorphism Toggle Style
struct NeumorphismToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            Button(action: {
                configuration.isOn.toggle()
            }) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? Color.neoGreen : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 30)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .offset(x: configuration.isOn ? 10 : -10)
                            .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                    )
                    .shadow(color: .neoDarkShadow, radius: 2, x: 1, y: 1)
                    .shadow(color: .neoLightShadow, radius: 2, x: -1, y: -1)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Neumorphism Tab View Style
struct NeumorphismTabButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .neoYellow : .white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.neoBackground : Color.clear)
                    .shadow(
                        color: isSelected ? .neoDarkShadow : .clear,
                        radius: isSelected ? 2 : 0,
                        x: isSelected ? 1 : 0,
                        y: isSelected ? 1 : 0
                    )
                    .shadow(
                        color: isSelected ? .neoLightShadow : .clear,
                        radius: isSelected ? 2 : 0,
                        x: isSelected ? -1 : 0,
                        y: isSelected ? -1 : 0
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - View Extensions
extension View {
    func neumorphismStyle() -> some View {
        self.background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.neoBackground)
                .shadow(color: .neoLightShadow, radius: 4, x: -2, y: -2)
                .shadow(color: .neoDarkShadow, radius: 4, x: 2, y: 2)
        )
    }
    
    func neumorphismCard(cornerRadius: CGFloat = 16, padding: CGFloat = 16) -> some View {
        self.padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.neoBackground)
                    .shadow(color: .neoLightShadow, radius: 4, x: -2, y: -2)
                    .shadow(color: .neoDarkShadow, radius: 4, x: 2, y: 2)
            )
    }
}
