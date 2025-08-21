//
//  IntroductionView.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct IntroductionView: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Icon and Title
            VStack(spacing: 20) {
                Image(systemName: "laptopcomputer.and.arrow.down")
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.neoYellow)
                    .shadow(color: .neoYellow.opacity(0.3), radius: 10, x: 0, y: 0)
                
                VStack(spacing: 12) {
                    Text("NeoCoder Road")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Your Ultimate Code Editor & Debugger")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            
            // Features Preview
            VStack(spacing: 16) {
                FeatureRow(
                    icon: "doc.text.fill",
                    title: "Advanced Code Editor",
                    description: "Syntax highlighting for 10+ languages"
                )
                
                FeatureRow(
                    icon: "ladybug.fill",
                    title: "Powerful Debugger",
                    description: "Runtime debugging with breakpoints"
                )
                
                FeatureRow(
                    icon: "person.2.fill",
                    title: "Real-time Collaboration",
                    description: "Code together with your team"
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Get Started Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentPage += 1
                }
            }) {
                Text("Get Started")
                    .font(.system(size: 18, weight: .semibold))
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.neoBackground)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.neoGreen)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.neoGreen.opacity(0.1))
                        .overlay(
                            Circle()
                                .stroke(Color.neoGreen.opacity(0.3), lineWidth: 1)
                        )
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.neoBackground)
                .shadow(color: .neoLightShadow, radius: 3, x: -2, y: -2)
                .shadow(color: .neoDarkShadow, radius: 3, x: 2, y: 2)
        )
    }
}

#Preview {
    IntroductionView(currentPage: .constant(0))
}
