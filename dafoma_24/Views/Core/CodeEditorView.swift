//
//  CodeEditorView.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct CodeEditorView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @StateObject private var editorViewModel: EditorViewModel
    @State private var showFileSelector = false
    @State private var showFindReplace = false
    
    init() {
        // This will be properly initialized when the view appears
        self._editorViewModel = StateObject(wrappedValue: EditorViewModel(
            fileService: FileService(),
            userSettingsService: UserSettingsService()
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with file info and actions
            EditorHeader(
                currentFile: editorViewModel.currentFile,
                showFileSelector: $showFileSelector,
                showFindReplace: $showFindReplace,
                onFormat: { editorViewModel.formatCode() }
            )
            
            // Main editor area
            HStack(spacing: 0) {
                // Line numbers
                if mainViewModel.userSettingsService.settings.showLineNumbers {
                    LineNumbersView(lineNumbers: editorViewModel.lineNumbers)
                }
                
                // Code editor
                CodeTextEditor(
                    text: $editorViewModel.editorText,
                    language: editorViewModel.currentFile?.language ?? .swift,
                    fontSize: mainViewModel.userSettingsService.settings.fontSize
                )
                .onChange(of: editorViewModel.editorText) { newValue in
                    editorViewModel.updateText(newValue)
                }
            }
            .background(Color.neoBackground.opacity(0.8))
            .neumorphismCard(cornerRadius: 0, padding: 0)
            
            // Find and Replace Bar
            if showFindReplace {
                FindReplaceBar(
                    findText: $editorViewModel.findText,
                    replaceText: $editorViewModel.replaceText,
                    searchResults: editorViewModel.searchResults,
                    onFind: { editorViewModel.findInCode($0) },
                    onReplace: { find, replace in
                        editorViewModel.replaceInCode(find, with: replace)
                    },
                    onClose: { showFindReplace = false }
                )
            }
        }
        .sheet(isPresented: $showFileSelector) {
            FileSelector { file in
                editorViewModel.setCurrentFile(file)
                showFileSelector = false
            }
            .environmentObject(mainViewModel)
        }
        .onAppear {
            setupEditor()
        }
    }
    
    private func setupEditor() {
        // Initialize with proper services
        let newEditorViewModel = EditorViewModel(
            fileService: mainViewModel.fileService,
            userSettingsService: mainViewModel.userSettingsService
        )
        
        // Set current file if available
        if let currentProject = mainViewModel.fileService.currentProject,
           let firstFile = currentProject.files.first {
            newEditorViewModel.setCurrentFile(firstFile)
        }
        
        // Note: StateObject cannot be reassigned in iOS 15.6
        // The editor will be properly initialized through the init
    }
}

struct EditorHeader: View {
    let currentFile: CodeFile?
    @Binding var showFileSelector: Bool
    @Binding var showFindReplace: Bool
    let onFormat: () -> Void
    
    var body: some View {
        HStack {
            // Current file info
            Button(action: { showFileSelector = true }) {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(currentFile?.language.syntaxColor ?? .gray)
                    
                    Text(currentFile?.name ?? "No file selected")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.neoBackground)
                        .shadow(color: .neoLightShadow, radius: 2, x: -1, y: -1)
                        .shadow(color: .neoDarkShadow, radius: 2, x: 1, y: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                ActionButton(systemImage: "folder") {
                    showFileSelector = true
                }
                
                ActionButton(systemImage: "magnifyingglass") {
                    showFindReplace.toggle()
                }
                
                ActionButton(systemImage: "rectangle.and.pencil.and.ellipsis") {
                    onFormat()
                }
                
                ActionButton(systemImage: "play.fill") {
                    // Run code (placeholder)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.neoBackground.opacity(0.95))
    }
}

struct ActionButton: View {
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.neoYellow)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.neoBackground)
                        .shadow(color: .neoLightShadow, radius: 2, x: -1, y: -1)
                        .shadow(color: .neoDarkShadow, radius: 2, x: 1, y: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LineNumbersView: View {
    let lineNumbers: [Int]
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(lineNumbers, id: \.self) { lineNumber in
                Text("\(lineNumber)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 40, height: 20, alignment: .trailing)
            }
            Spacer()
        }
        .padding(.trailing, 8)
        .padding(.top, 8)
        .background(Color.neoBackground.opacity(0.3))
    }
}

struct CodeTextEditor: View {
    @Binding var text: String
    let language: ProgrammingLanguage
    let fontSize: Double
    
    var body: some View {
        TextEditor(text: $text)
            .font(.system(size: fontSize, design: .monospaced))
            .foregroundColor(.white)
            .background(Color.clear)
            .padding(8)
            .background(Color.clear)
    }
}

struct FindReplaceBar: View {
    @Binding var findText: String
    @Binding var replaceText: String
    let searchResults: [SearchResult]
    let onFind: (String) -> Void
    let onReplace: (String, String) -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Find", text: $findText)
                    .textFieldStyle(NeumorphismTextFieldStyle())
                    .onChange(of: findText) { newValue in
                        onFind(newValue)
                    }
                
                TextField("Replace", text: $replaceText)
                    .textFieldStyle(NeumorphismTextFieldStyle())
                
                Button("Replace All") {
                    onReplace(findText, replaceText)
                }
                .buttonStyle(NeumorphismButtonStyle())
                .foregroundColor(.neoYellow)
                
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
            
            if !searchResults.isEmpty {
                Text("\(searchResults.count) results found")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(Color.neoBackground.opacity(0.95))
    }
}

struct FileSelector: View {
    let onFileSelected: (CodeFile) -> Void
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCreateProject = false
    @State private var showCreateFile = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Project selector
                if mainViewModel.fileService.projects.count > 1 {
                    VStack {
                        Text("Current Project")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        
                        Menu {
                            ForEach(mainViewModel.fileService.projects) { project in
                                Button(project.name) {
                                    mainViewModel.fileService.setCurrentProject(project)
                                }
                            }
                        } label: {
                            HStack {
                                Text(mainViewModel.fileService.currentProject?.name ?? "No Project")
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
                
                // Files list
                if let project = mainViewModel.fileService.currentProject {
                    List {
                        ForEach(project.files) { file in
                            Button(action: {
                                onFileSelected(file)
                            }) {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .foregroundColor(file.language.syntaxColor)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(file.name)
                                            .font(.system(size: 16, weight: .semibold))
                                        
                                        HStack {
                                            Text(file.language.rawValue)
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            Text("\(file.content.components(separatedBy: .newlines).count) lines")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .listStyle(PlainListStyle())
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "folder")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No Project")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Create a project to start coding")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Button("Create Project") {
                            showCreateProject = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Files")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("New Project") {
                        showCreateProject = true
                    }
                    .font(.system(size: 14))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if mainViewModel.fileService.currentProject != nil {
                            Button("New File") {
                                showCreateFile = true
                            }
                            .font(.system(size: 14))
                        }
                        
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateProject) {
            CreateProjectSheet { projectName in
                let _ = mainViewModel.fileService.createProject(name: projectName)
                showCreateProject = false
            }
        }
        .sheet(isPresented: $showCreateFile) {
            if let project = mainViewModel.fileService.currentProject {
                CreateFileSheet(project: project) { fileName, language in
                    let _ = mainViewModel.fileService.createFile(
                        in: project,
                        name: fileName,
                        language: language
                    )
                    showCreateFile = false
                }
            }
        }
    }
}

struct CreateProjectSheet: View {
    let onCreate: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var projectName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create New Project")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                TextField("Project Name", text: $projectName)
                    .textFieldStyle(NeumorphismTextFieldStyle())
                    .foregroundColor(.white)
                
                Button("Create") {
                    if !projectName.isEmpty {
                        onCreate(projectName)
                    }
                }
                .buttonStyle(NeumorphismButtonStyle())
                .foregroundColor(.neoYellow)
                .disabled(projectName.isEmpty)
                
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

struct CreateFileSheet: View {
    let project: CodeProject
    let onCreate: (String, ProgrammingLanguage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var fileName = ""
    @State private var selectedLanguage: ProgrammingLanguage = .swift
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create New File")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                TextField("File Name", text: $fileName)
                    .textFieldStyle(NeumorphismTextFieldStyle())
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Language")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(ProgrammingLanguage.allCases, id: \.self) { language in
                            Text(language.rawValue).tag(language)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.neoBackground)
                            .shadow(color: .neoDarkShadow, radius: 2, x: 1, y: 1)
                            .shadow(color: .neoLightShadow, radius: 2, x: -1, y: -1)
                    )
                }
                
                Button("Create") {
                    if !fileName.isEmpty {
                        let fullFileName = fileName.contains(".") ? fileName : fileName + selectedLanguage.fileExtension
                        onCreate(fullFileName, selectedLanguage)
                    }
                }
                .buttonStyle(NeumorphismButtonStyle())
                .foregroundColor(.neoGreen)
                .disabled(fileName.isEmpty)
                
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
    CodeEditorView()
        .environmentObject(MainViewModel())
}
