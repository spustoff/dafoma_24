//
//  FileService.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation

@MainActor
class FileService: ObservableObject {
    @Published var projects: [CodeProject] = []
    @Published var currentProject: CodeProject?
    
    private let documentsURL: URL
    private let projectsFileName = "projects.json"
    
    init() {
        self.documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        loadProjects()
        
        // Create sample project if none exist
        if projects.isEmpty {
            createSampleProject()
        }
    }
    
    func loadProjects() {
        let projectsURL = documentsURL.appendingPathComponent(projectsFileName)
        
        guard let data = try? Data(contentsOf: projectsURL),
              let decodedProjects = try? JSONDecoder().decode([CodeProject].self, from: data) else {
            return
        }
        
        self.projects = decodedProjects
        if let first = projects.first {
            self.currentProject = first
        }
    }
    
    func saveProjects() {
        let projectsURL = documentsURL.appendingPathComponent(projectsFileName)
        
        guard let data = try? JSONEncoder().encode(projects) else { return }
        try? data.write(to: projectsURL)
    }
    
    func createProject(name: String) -> CodeProject {
        let project = CodeProject(name: name)
        projects.append(project)
        saveProjects()
        return project
    }
    
    func deleteProject(_ project: CodeProject) {
        projects.removeAll { $0.id == project.id }
        if currentProject?.id == project.id {
            currentProject = projects.first
        }
        saveProjects()
    }
    
    func createFile(in project: CodeProject, name: String, language: ProgrammingLanguage) -> CodeFile {
        let file = CodeFile(name: name, language: language)
        
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].files.append(file)
            projects[index].lastModified = Date()
            
            if currentProject?.id == project.id {
                currentProject = projects[index]
            }
            
            saveProjects()
        }
        
        return file
    }
    
    func updateFile(_ file: CodeFile, content: String) {
        guard let projectIndex = projects.firstIndex(where: { project in
            project.files.contains { $0.id == file.id }
        }),
        let fileIndex = projects[projectIndex].files.firstIndex(where: { $0.id == file.id }) else {
            return
        }
        
        projects[projectIndex].files[fileIndex].content = content
        projects[projectIndex].files[fileIndex].lastModified = Date()
        projects[projectIndex].lastModified = Date()
        
        if currentProject?.id == projects[projectIndex].id {
            currentProject = projects[projectIndex]
        }
        
        saveProjects()
    }
    
    func deleteFile(_ file: CodeFile, from project: CodeProject) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == project.id }) else { return }
        
        projects[projectIndex].files.removeAll { $0.id == file.id }
        projects[projectIndex].lastModified = Date()
        
        if currentProject?.id == project.id {
            currentProject = projects[projectIndex]
        }
        
        saveProjects()
    }
    
    func setCurrentProject(_ project: CodeProject) {
        currentProject = project
    }
    
    private func createSampleProject() {
        let sampleProject = CodeProject(name: "Welcome to NeoCoder")
        
        let welcomeFile = CodeFile(
            name: "Welcome.swift",
            content: """
            import SwiftUI

            struct WelcomeView: View {
                var body: some View {
                    VStack(spacing: 20) {
                        Text("Welcome to NeoCoder Road!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Your powerful code editor and debugger")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Button("Start Coding") {
                            // Your code here
                            print("Ready to code!")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            """,
            language: .swift
        )
        
        let jsFile = CodeFile(
            name: "example.js",
            content: """
            // JavaScript Example
            function fibonacci(n) {
                if (n <= 1) return n;
                return fibonacci(n - 1) + fibonacci(n - 2);
            }

            console.log("Fibonacci sequence:");
            for (let i = 0; i < 10; i++) {
                console.log(`F(${i}) = ${fibonacci(i)}`);
            }
            """,
            language: .javascript
        )
        
        projects.append(CodeProject(name: sampleProject.name, files: [welcomeFile, jsFile]))
        currentProject = projects.first
        saveProjects()
    }
}
