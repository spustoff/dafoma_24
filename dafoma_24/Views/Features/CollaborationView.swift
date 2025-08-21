//
//  CollaborationView.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct CollaborationView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var showCreateSession = false
    @State private var showJoinSession = false
    @State private var sessionCode = ""
    @State private var participantName = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            CollaborationHeader()
            
            if let activeSession = mainViewModel.networkService.activeCollaborationSession {
                // Active session view
                ActiveSessionView(session: activeSession)
            } else {
                // No active session - show options
                CollaborationOptionsView(
                    showCreateSession: $showCreateSession,
                    showJoinSession: $showJoinSession
                )
            }
        }
        .background(Color.neoBackground)
        .sheet(isPresented: $showCreateSession) {
            CreateSessionSheet {
                showCreateSession = false
            }
            .environmentObject(mainViewModel)
        }
        .sheet(isPresented: $showJoinSession) {
            JoinSessionSheet(
                sessionCode: $sessionCode,
                participantName: $participantName
            ) { code, name in
                Task {
                    let success = await mainViewModel.networkService.joinCollaborationSession(
                        sessionCode: code,
                        participantName: name
                    )
                    if success {
                        showJoinSession = false
                    }
                }
            }
        }
    }
}

struct CollaborationHeader: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Collaboration")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                HStack {
                    Circle()
                        .fill(mainViewModel.networkService.isConnected ? Color.neoGreen : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(mainViewModel.networkService.isConnected ? "Online" : "Offline")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(mainViewModel.networkService.isConnected ? .neoGreen : .red)
                }
            }
            
            Spacer()
            
            if mainViewModel.networkService.activeCollaborationSession != nil {
                Button("Leave Session") {
                    mainViewModel.networkService.leaveCollaborationSession()
                }
                .buttonStyle(NeumorphismButtonStyle())
                .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.neoBackground.opacity(0.95))
    }
}

struct CollaborationOptionsView: View {
    @Binding var showCreateSession: Bool
    @Binding var showJoinSession: Bool
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Collaboration illustration
            VStack(spacing: 20) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.neoGreen)
                    .shadow(color: .neoGreen.opacity(0.3), radius: 10, x: 0, y: 0)
                
                VStack(spacing: 12) {
                    Text("Real-time Collaboration")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Code together with your team in real-time")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
            
            // Options
            VStack(spacing: 20) {
                // Create session
                Button(action: {
                    if mainViewModel.networkService.isConnected {
                        showCreateSession = true
                    }
                }) {
                    CollaborationOptionCard(
                        icon: "plus.circle.fill",
                        title: "Create Session",
                        description: "Start a new collaboration session and invite others",
                        color: .neoYellow,
                        isEnabled: mainViewModel.networkService.isConnected
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!mainViewModel.networkService.isConnected)
                
                // Join session
                Button(action: {
                    if mainViewModel.networkService.isConnected {
                        showJoinSession = true
                    }
                }) {
                    CollaborationOptionCard(
                        icon: "person.badge.plus.fill",
                        title: "Join Session",
                        description: "Join an existing collaboration session with a code",
                        color: .neoGreen,
                        isEnabled: mainViewModel.networkService.isConnected
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!mainViewModel.networkService.isConnected)
            }
            
            if !mainViewModel.networkService.isConnected {
                Text("Connect to the internet to use collaboration features")
                    .font(.system(size: 14))
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct CollaborationOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(isEnabled ? color : .gray)
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isEnabled ? .white : .gray)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(isEnabled ? .white.opacity(0.8) : .gray.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isEnabled ? .white.opacity(0.5) : .gray.opacity(0.5))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.neoBackground)
                .shadow(color: isEnabled ? .neoLightShadow : .clear, radius: 4, x: -2, y: -2)
                .shadow(color: isEnabled ? .neoDarkShadow : .clear, radius: 4, x: 2, y: 2)
                .opacity(isEnabled ? 1.0 : 0.5)
        )
    }
}

struct ActiveSessionView: View {
    let session: CollaborationSession
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Session info
            NeumorphismCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Active Session")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack {
                            Circle()
                                .fill(Color.neoGreen)
                                .frame(width: 8, height: 8)
                            
                            Text("Live")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.neoGreen)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Session Code")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack {
                            Text(session.sessionCode)
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundColor(.neoYellow)
                            
                            Spacer()
                            
                            Button("Copy") {
                                UIPasteboard.general.string = session.sessionCode
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.neoYellow)
                        }
                        
                        Text("Share this code with others to invite them")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            // Participants
            NeumorphismCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Participants (\(session.participants.count + 1))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        // Host (you)
                        ParticipantRow(
                            name: "You (Host)",
                            isOnline: true,
                            isHost: true
                        )
                        
                        // Other participants
                        ForEach(session.participants) { participant in
                            ParticipantRow(
                                name: participant.name,
                                isOnline: participant.isOnline,
                                isHost: false
                            )
                        }
                        
                        if session.participants.isEmpty {
                            Text("No other participants yet")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            
            // Collaboration tools
            NeumorphismCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Collaboration Tools")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        CollaborationToolButton(
                            icon: "doc.text.fill",
                            title: "Share Current File",
                            action: {
                                if let project = mainViewModel.fileService.currentProject,
                                   let file = project.files.first {
                                    mainViewModel.networkService.shareCode(file.content, in: session)
                                }
                            }
                        )
                        
                        CollaborationToolButton(
                            icon: "message.fill",
                            title: "Open Chat",
                            action: {
                                // Open chat (placeholder)
                            }
                        )
                        
                        CollaborationToolButton(
                            icon: "video.fill",
                            title: "Start Video Call",
                            action: {
                                // Start video call (placeholder)
                            }
                        )
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
    }
}

struct ParticipantRow: View {
    let name: String
    let isOnline: Bool
    let isHost: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(isOnline ? Color.neoGreen : Color.gray)
                .frame(width: 10, height: 10)
            
            Text(name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            if isHost {
                Text("HOST")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.neoYellow)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.neoYellow.opacity(0.2))
                    )
            }
            
            Spacer()
        }
    }
}

struct CollaborationToolButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.neoGreen)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CreateSessionSheet: View {
    let onComplete: () -> Void
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Create Collaboration Session")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                VStack(spacing: 20) {
                    Image(systemName: "person.2.badge.plus.fill")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.neoYellow)
                    
                    Text("You're about to create a new collaboration session. Others will be able to join using the session code.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Button("Create Session") {
                    let session = mainViewModel.networkService.createCollaborationSession()
                    onComplete()
                }
                .buttonStyle(NeumorphismButtonStyle())
                .foregroundColor(.neoYellow)
                
                Spacer()
            }
            .padding(20)
            .background(Color.neoBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct JoinSessionSheet: View {
    @Binding var sessionCode: String
    @Binding var participantName: String
    let onJoin: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isJoining = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Join Collaboration Session")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                VStack(spacing: 20) {
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.neoGreen)
                    
                    Text("Enter the session code and your name to join the collaboration session.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                VStack(spacing: 16) {
                    TextField("Session Code", text: $sessionCode)
                        .textFieldStyle(NeumorphismTextFieldStyle())
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                    
                    TextField("Your Name", text: $participantName)
                        .textFieldStyle(NeumorphismTextFieldStyle())
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    if !sessionCode.isEmpty && !participantName.isEmpty {
                        isJoining = true
                        onJoin(sessionCode, participantName)
                    }
                }) {
                    HStack {
                        if isJoining {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.black)
                        }
                        Text(isJoining ? "Joining..." : "Join Session")
                    }
                }
                .buttonStyle(NeumorphismButtonStyle())
                .foregroundColor(.neoGreen)
                .disabled(sessionCode.isEmpty || participantName.isEmpty || isJoining)
                
                Spacer()
            }
            .padding(20)
            .background(Color.neoBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    CollaborationView()
        .environmentObject(MainViewModel())
}
