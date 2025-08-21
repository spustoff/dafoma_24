//
//  NetworkService.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation
import Network

@MainActor
class NetworkService: ObservableObject {
    @Published var isConnected = false
    @Published var activeCollaborationSession: CollaborationSession?
    @Published var collaborationSessions: [CollaborationSession] = []
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        startNetworkMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    // MARK: - Collaboration Methods
    
    func createCollaborationSession() -> CollaborationSession {
        let sessionCode = generateSessionCode()
        var session = CollaborationSession(sessionCode: sessionCode, isHost: true)
        session.isActive = true
        
        collaborationSessions.append(session)
        activeCollaborationSession = session
        
        // Simulate session creation
        simulateNetworkDelay {
            // Session created successfully
        }
        
        return session
    }
    
    func joinCollaborationSession(sessionCode: String, participantName: String) async -> Bool {
        // Simulate network request
        await simulateNetworkRequest()
        
        // For demo purposes, create a mock session
        if sessionCode.count == 6 {
            var session = CollaborationSession(sessionCode: sessionCode, isHost: false)
            session.isActive = true
            
            let participant = Participant(name: participantName)
            session.participants.append(participant)
            
            collaborationSessions.append(session)
            activeCollaborationSession = session
            
            return true
        }
        
        return false
    }
    
    func leaveCollaborationSession() {
        activeCollaborationSession?.isActive = false
        activeCollaborationSession = nil
    }
    
    func shareCode(_ code: String, in session: CollaborationSession) {
        // Simulate code sharing
        simulateNetworkDelay {
            // Code shared successfully
        }
    }
    
    func sendCursorPosition(_ position: Int, in session: CollaborationSession) {
        // Simulate cursor position sharing
        // In a real app, this would send the position to other participants
    }
    
    // MARK: - Git Integration (Simulated)
    
    func initializeGitRepository(for project: CodeProject) async -> Bool {
        await simulateNetworkRequest()
        return true
    }
    
    func commitChanges(message: String, for project: CodeProject) async -> Bool {
        await simulateNetworkRequest()
        return true
    }
    
    func pushToRemote(for project: CodeProject) async -> Bool {
        await simulateNetworkRequest()
        return isConnected
    }
    
    func pullFromRemote(for project: CodeProject) async -> Bool {
        await simulateNetworkRequest()
        return isConnected
    }
    
    // MARK: - Helper Methods
    
    private func generateSessionCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
    
    private func simulateNetworkDelay(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }
    
    private func simulateNetworkRequest() async {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
}
