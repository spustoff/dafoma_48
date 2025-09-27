//
//  OnboardingView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var showingMainApp = false
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                HStack {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentPage ? Color.black : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.gray)
                        .font(.system(size: 16, weight: .medium))
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button("Next") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#2DCC72"))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                    } else {
                        Button("Get Started") {
                            completeOnboarding()
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showingMainApp) {
            MainTabView()
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        DataManager.shared.hasCompletedOnboarding = true
        showingMainApp = true
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: page.backgroundColor))
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: page.backgroundColor).opacity(0.3), radius: 20, x: 0, y: 10)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 20) {
                // Title
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(page.description)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let backgroundColor: String
    
    static let allPages = [
        OnboardingPage(
            title: "Welcome to Habitally Dom",
            description: "Transform your daily routine into a powerful lifestyle upgrade. Build habits that stick and achieve your goals with purpose.",
            icon: "star.fill",
            backgroundColor: "#2DCC72"
        ),
        OnboardingPage(
            title: "Track Your Habits",
            description: "Create meaningful habits and track your progress with beautiful visual indicators. Stay motivated with personalized insights.",
            icon: "checkmark.circle.fill",
            backgroundColor: "#4ECDC4"
        ),
        OnboardingPage(
            title: "Achieve Your Goals",
            description: "Set ambitious goals and break them down into achievable milestones. Watch your dreams become reality, one step at a time.",
            icon: "target",
            backgroundColor: "#45B7D1"
        ),
        OnboardingPage(
            title: "Build Powerful Routines",
            description: "Design personalized daily routines that align with your values. Get gentle reminders to stay on track throughout your day.",
            icon: "clock.fill",
            backgroundColor: "#FF6B6B"
        ),
        OnboardingPage(
            title: "Practice Mindfulness",
            description: "Cultivate inner peace with daily reflections and meditation. Connect with yourself and find clarity in the present moment.",
            icon: "leaf.fill",
            backgroundColor: "#DDA0DD"
        ),
        OnboardingPage(
            title: "Your Journey Starts Now",
            description: "Everything you need to create lasting positive change is at your fingertips. Let's build the life you've always envisioned.",
            icon: "arrow.up.circle.fill",
            backgroundColor: "#FFEAA7"
        )
    ]
}

// Color extension for hex colors
extension Color {
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

#Preview {
    OnboardingView()
}
