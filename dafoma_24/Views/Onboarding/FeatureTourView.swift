//
//  FeatureTourView.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct FeatureTourView: View {
    @Binding var currentPage: Int
    @State private var selectedFeature = 0
    
    private let features = [
        Feature(
            icon: "doc.text.fill",
            title: "Smart Code Editor",
            description: "Experience syntax highlighting, auto-completion, and intelligent code formatting across multiple programming languages.",
            color: .neoYellow,
            details: [
                "Syntax highlighting for 10+ languages",
                "Smart auto-indentation",
                "Code folding and minimap",
                "Find and replace with regex support"
            ]
        ),
        Feature(
            icon: "ladybug.fill",
            title: "Advanced Debugger",
            description: "Debug your code with powerful tools including breakpoints, variable inspection, and performance monitoring.",
            color: .neoGreen,
            details: [
                "Interactive breakpoints",
                "Variable and memory inspection",
                "Call stack visualization",
                "Performance metrics tracking"
            ]
        ),
        Feature(
            icon: "person.2.fill",
            title: "Real-time Collaboration",
            description: "Work together with your team in real-time. Share code, discuss changes, and build amazing projects together.",
            color: .blue,
            details: [
                "Live code sharing",
                "Real-time cursor tracking",
                "Integrated chat system",
                "Version control integration"
            ]
        ),
        Feature(
            icon: "square.stack.3d.up.fill",
            title: "Code Snippets Library",
            description: "Save and organize your frequently used code snippets. Access them instantly with smart categorization.",
            color: .purple,
            details: [
                "Custom snippet creation",
                "Smart categorization",
                "Quick insertion shortcuts",
                "Import/export functionality"
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Text("Powerful Features")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Discover what makes NeoCoder Road special")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)
            .padding(.bottom, 40)
            
            // Feature Cards
            TabView(selection: $selectedFeature) {
                ForEach(features.indices, id: \.self) { index in
                    FeatureCard(feature: features[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 400)
            .onAppear {
                setupPageControlAppearance()
            }
            
            Spacer()
            
            // Navigation Buttons
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentPage -= 1
                    }
                }) {
                    Text("Back")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 100, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.neoBackground)
                                .shadow(color: .neoLightShadow, radius: 3, x: -2, y: -2)
                                .shadow(color: .neoDarkShadow, radius: 3, x: 2, y: 2)
                        )
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentPage += 1
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 150, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.neoYellow)
                                .shadow(color: .neoYellow.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.neoBackground)
    }
    
    private func setupPageControlAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.neoYellow)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.white.opacity(0.3))
    }
}

struct FeatureCard: View {
    let feature: Feature
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: feature.icon)
                .font(.system(size: 60, weight: .light))
                .foregroundColor(feature.color)
                .shadow(color: feature.color.opacity(0.3), radius: 10, x: 0, y: 0)
            
            // Title and Description
            VStack(spacing: 12) {
                Text(feature.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // Feature Details
            VStack(spacing: 8) {
                ForEach(feature.details, id: \.self) { detail in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.neoGreen)
                        
                        Text(detail)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.neoBackground)
                .shadow(color: .neoLightShadow, radius: 6, x: -4, y: -4)
                .shadow(color: .neoDarkShadow, radius: 6, x: 4, y: 4)
        )
        .padding(.horizontal, 20)
    }
}

struct Feature {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let details: [String]
}

#Preview {
    FeatureTourView(currentPage: .constant(1))
}
