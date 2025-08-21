//
//  AppModels.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation
import SwiftUI

// MARK: - Core Models

struct CodeProject: Identifiable, Codable {
    let id = UUID()
    var name: String
    var files: [CodeFile]
    var createdDate: Date
    var lastModified: Date
    
    init(name: String, files: [CodeFile] = []) {
        self.name = name
        self.files = files
        self.createdDate = Date()
        self.lastModified = Date()
    }
}

struct CodeFile: Identifiable, Codable {
    let id = UUID()
    var name: String
    var content: String
    var language: ProgrammingLanguage
    var lastModified: Date
    var breakpoints: [Int]
    
    init(name: String, content: String = "", language: ProgrammingLanguage = .swift) {
        self.name = name
        self.content = content
        self.language = language
        self.lastModified = Date()
        self.breakpoints = []
    }
}

enum ProgrammingLanguage: String, CaseIterable, Codable {
    case swift = "Swift"
    case javascript = "JavaScript"
    case python = "Python"
    case java = "Java"
    case cpp = "C++"
    case html = "HTML"
    case css = "CSS"
    case json = "JSON"
    case xml = "XML"
    case markdown = "Markdown"
    
    var fileExtension: String {
        switch self {
        case .swift: return ".swift"
        case .javascript: return ".js"
        case .python: return ".py"
        case .java: return ".java"
        case .cpp: return ".cpp"
        case .html: return ".html"
        case .css: return ".css"
        case .json: return ".json"
        case .xml: return ".xml"
        case .markdown: return ".md"
        }
    }
    
    var syntaxColor: Color {
        switch self {
        case .swift: return .orange
        case .javascript: return .yellow
        case .python: return .blue
        case .java: return .red
        case .cpp: return .purple
        case .html: return .pink
        case .css: return .cyan
        case .json: return .green
        case .xml: return .indigo
        case .markdown: return .gray
        }
    }
}

struct CodeSnippet: Identifiable, Codable {
    let id = UUID()
    var title: String
    var code: String
    var language: ProgrammingLanguage
    var category: String
    var createdDate: Date
    
    init(title: String, code: String, language: ProgrammingLanguage, category: String = "General") {
        self.title = title
        self.code = code
        self.language = language
        self.category = category
        self.createdDate = Date()
    }
}

struct DebugSession: Identifiable {
    let id = UUID()
    var isActive: Bool = false
    var currentFile: CodeFile?
    var breakpoints: [Int] = []
    var variables: [DebugVariable] = []
    var callStack: [String] = []
    var output: String = ""
}

struct DebugVariable: Identifiable {
    let id = UUID()
    var name: String
    var value: String
    var type: String
}

struct UserSettings: Codable {
    var theme: AppTheme = .dark
    var fontSize: Double = 14.0
    var showLineNumbers: Bool = true
    var autoIndent: Bool = true
    var wordWrap: Bool = false
    var tabSize: Int = 4
    var enableCollaboration: Bool = true
    var hasCompletedOnboarding: Bool = false
    
    static let `default` = UserSettings()
}

enum AppTheme: String, CaseIterable, Codable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

// MARK: - Collaboration Models

class CollaborationSession: Identifiable, ObservableObject {
    let id = UUID()
    var sessionCode: String
    @Published var participants: [Participant]
    @Published var sharedProject: CodeProject?
    var isHost: Bool
    @Published var isActive: Bool = false
    
    init(sessionCode: String, isHost: Bool = false) {
        self.sessionCode = sessionCode
        self.participants = []
        self.isHost = isHost
    }
}

struct Participant: Identifiable, Codable {
    let id = UUID()
    var name: String
    var isOnline: Bool = true
    var cursorPosition: Int = 0
    var selectedFile: String?
}

// MARK: - Performance Models

struct PerformanceMetric: Identifiable {
    let id = UUID()
    var name: String
    var value: Double
    var unit: String
    var status: MetricStatus
    var suggestion: String?
}

enum MetricStatus {
    case good
    case warning
    case critical
    
    var color: Color {
        switch self {
        case .good: return .green
        case .warning: return .yellow
        case .critical: return .red
        }
    }
}
