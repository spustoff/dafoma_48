//
//  SettingsView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingDeleteAlert = false
    @State private var showingAbout = false
    @State private var showingPrivacy = false
    @State private var showingSupport = false
    @State private var showingExportData = false
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile section
                        profileSection
                        
                        
                        // Data management
                        dataSection
                        
                        // Support & Info
                        supportSection
                        
                        // Danger zone
                        dangerZoneSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Delete All Data", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Everything", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will permanently delete all your habits, goals, routines, and reflections. This action cannot be undone.")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacyView()
        }
        .sheet(isPresented: $showingSupport) {
            SupportView()
        }
        .sheet(isPresented: $showingExportData) {
            ExportDataView()
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 16) {
            // Profile header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#2DCC72"))
                        .frame(width: 80, height: 80)
                    
                    Text("HD")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text("Habitally Dom User")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text("Building better habits since \(formatDate(Date()))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Stats overview
            HStack(spacing: 20) {
                ProfileStatCard(
                    title: "Habits",
                    value: "\(dataManager.habits.count)",
                    color: "#2DCC72"
                )
                
                ProfileStatCard(
                    title: "Goals",
                    value: "\(dataManager.goals.count)",
                    color: "#45B7D1"
                )
                
                ProfileStatCard(
                    title: "Routines",
                    value: "\(dataManager.routines.count)",
                    color: "#4ECDC4"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var preferencesSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Preferences")
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Get reminders for habits and routines",
                    color: "#FF6B6B"
                ) {
                    Toggle("", isOn: $notificationsEnabled)
                        .tint(Color(hex: "#2DCC72"))
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    subtitle: "Switch to dark appearance",
                    color: "#4D4DFF"
                ) {
                    Toggle("", isOn: $darkModeEnabled)
                        .tint(Color(hex: "#2DCC72"))
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "textformat.size",
                    title: "Text Size",
                    subtitle: "Adjust text size for better readability",
                    color: "#96CEB4"
                ) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var dataSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Data Management")
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "square.and.arrow.up",
                    title: "Export Data",
                    subtitle: "Download your data as JSON",
                    color: "#45B7D1"
                ) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    showingExportData = true
                }
            }
        }
    }
    
    private var supportSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Support & Information")
            
            VStack(spacing: 0) {
                
                
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "About",
                    subtitle: "App version and information",
                    color: "#45B7D1"
                ) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    showingAbout = true
                }
                
            }
        }
    }
    
    private var dangerZoneSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Danger Zone")
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "trash.fill",
                    title: "Delete All Data",
                    subtitle: "Permanently remove all your data",
                    color: "#E74C3C"
                ) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .onTapGesture {
                    showingDeleteAlert = true
                }
            }
        }
    }
    
    private func resetAllData() {
        dataManager.resetAllData()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: String
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: color))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            content()
        }
        .padding()
        .background(Color.white)
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let color: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: color))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(hex: color).opacity(0.1))
        .cornerRadius(12)
    }
}

// Placeholder views for sheets
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#2DCC72"))
                
                VStack(spacing: 12) {
                    Text("Habitally Dom")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text("Transform your daily routine into a powerful lifestyle upgrade. Build habits that stick and achieve your goals with purpose.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Privacy Matters")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Habitally Dom is designed with privacy in mind. All your data is stored locally on your device and never shared with third parties.")
                        .font(.body)
                    
                    Text("Data Collection")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("• We do not collect any personal information\n• All habits, goals, and reflections stay on your device\n• No analytics or tracking is performed\n• No internet connection required for core functionality")
                        .font(.body)
                    
                    Text("Data Security")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Your data is protected by iOS security features and remains under your complete control.")
                        .font(.body)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct SupportView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#4ECDC4"))
                
                VStack(spacing: 12) {
                    Text("Need Help?")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("We're here to help you succeed with your habits and goals.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    SupportOption(
                        icon: "envelope.fill",
                        title: "Email Support",
                        description: "Get personalized help via email"
                    )
                    
                    SupportOption(
                        icon: "book.fill",
                        title: "User Guide",
                        description: "Learn how to make the most of the app"
                    )
                    
                    SupportOption(
                        icon: "bubble.left.and.bubble.right.fill",
                        title: "Community",
                        description: "Connect with other users"
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct SupportOption: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: "#4ECDC4"))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ExportDataView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#45B7D1"))
                
                VStack(spacing: 12) {
                    Text("Export Your Data")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Download all your habits, goals, routines, and reflections as a JSON file.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    DataSummaryRow(title: "Habits", count: dataManager.habits.count)
                    DataSummaryRow(title: "Goals", count: dataManager.goals.count)
                    DataSummaryRow(title: "Routines", count: dataManager.routines.count)
                    DataSummaryRow(title: "Reflections", count: dataManager.reflections.count)
                    DataSummaryRow(title: "Meditation Sessions", count: dataManager.meditationSessions.count)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                Button("Export Data") {
                    // Export functionality would go here
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "#45B7D1"))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct DataSummaryRow: View {
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.black)
            
            Spacer()
            
            Text("\(count)")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager.shared)
}
