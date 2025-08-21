//
//  SnippetManagerView.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct SnippetManagerView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @StateObject private var snippetManager = SnippetManager()
    @State private var showCreateSnippet = false
    @State private var selectedCategory = "All"
    @State private var searchText = ""
    @State private var selectedSnippet: CodeSnippet?
    
    var filteredSnippets: [CodeSnippet] {
        let categoryFiltered = selectedCategory == "All" 
            ? snippetManager.snippets 
            : snippetManager.snippets.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { snippet in
                snippet.title.localizedCaseInsensitiveContains(searchText) ||
                snippet.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var categories: [String] {
        ["All"] + Array(Set(snippetManager.snippets.map { $0.category })).sorted()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            SnippetHeader(
                searchText: $searchText,
                showCreateSnippet: $showCreateSnippet
            )
            
            // Categories filter
            CategoryFilterView(
                categories: categories,
                selectedCategory: $selectedCategory
            )
            
            // Main content - optimized for iPhone
            if let snippet = selectedSnippet {
                // Show snippet detail
                SnippetDetailView(
                    snippet: snippet,
                    onInsert: { snippet in
                        insertSnippetToEditor(snippet)
                    },
                    onEdit: { snippet in
                        // Edit functionality would go here
                    },
                    onBack: {
                        selectedSnippet = nil
                    }
                )
            } else {
                // Show snippets grid
                SnippetsGridView(
                    snippets: filteredSnippets,
                    onSelectSnippet: { snippet in
                        selectedSnippet = snippet
                    },
                    onDeleteSnippet: { snippet in
                        snippetManager.deleteSnippet(snippet)
                    }
                )
            }
        }
        .background(Color.neoBackground)
        .sheet(isPresented: $showCreateSnippet) {
            CreateSnippetSheet { title, code, language, category in
                snippetManager.createSnippet(
                    title: title,
                    code: code,
                    language: language,
                    category: category
                )
                showCreateSnippet = false
            }
        }
    }
    
    private func insertSnippetToEditor(_ snippet: CodeSnippet) {
        // This would integrate with the editor to insert the snippet
        // For now, it's a placeholder
        print("Inserting snippet: \(snippet.title)")
    }
}

@MainActor
class SnippetManager: ObservableObject {
    @Published var snippets: [CodeSnippet] = []
    
    private let userDefaults = UserDefaults.standard
    private let snippetsKey = "CodeSnippets"
    
    init() {
        loadSnippets()
        
        if snippets.isEmpty {
            createDefaultSnippets()
        }
    }
    
    func loadSnippets() {
        if let data = userDefaults.data(forKey: snippetsKey),
           let decodedSnippets = try? JSONDecoder().decode([CodeSnippet].self, from: data) {
            snippets = decodedSnippets
        }
    }
    
    func saveSnippets() {
        if let data = try? JSONEncoder().encode(snippets) {
            userDefaults.set(data, forKey: snippetsKey)
        }
    }
    
    func createSnippet(title: String, code: String, language: ProgrammingLanguage, category: String) {
        let snippet = CodeSnippet(title: title, code: code, language: language, category: category)
        snippets.append(snippet)
        saveSnippets()
    }
    
    func deleteSnippet(_ snippet: CodeSnippet) {
        snippets.removeAll { $0.id == snippet.id }
        saveSnippets()
    }
    
    private func createDefaultSnippets() {
        let defaultSnippets = [
            CodeSnippet(
                title: "SwiftUI View Template",
                code: """
                import SwiftUI
                
                struct ContentView: View {
                    var body: some View {
                        VStack {
                            Text("Hello, World!")
                                .padding()
                        }
                    }
                }
                
                #Preview {
                    ContentView()
                }
                """,
                language: .swift,
                category: "Templates"
            ),
            CodeSnippet(
                title: "For Loop",
                code: """
                for i in 0..<10 {
                    print(i)
                }
                """,
                language: .swift,
                category: "Loops"
            ),
            CodeSnippet(
                title: "Function Template",
                code: """
                func functionName(parameter: Type) -> ReturnType {
                    // Implementation
                    return value
                }
                """,
                language: .swift,
                category: "Functions"
            ),
            CodeSnippet(
                title: "JavaScript Function",
                code: """
                function functionName(param) {
                    // Implementation
                    return result;
                }
                """,
                language: .javascript,
                category: "Functions"
            ),
            CodeSnippet(
                title: "Python Class",
                code: """
                class ClassName:
                    def __init__(self, param):
                        self.param = param
                    
                    def method(self):
                        pass
                """,
                language: .python,
                category: "Classes"
            ),
            CodeSnippet(
                title: "HTML Template",
                code: """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Document</title>
                </head>
                <body>
                    
                </body>
                </html>
                """,
                language: .html,
                category: "Templates"
            )
        ]
        
        snippets = defaultSnippets
        saveSnippets()
    }
}

struct SnippetHeader: View {
    @Binding var searchText: String
    @Binding var showCreateSnippet: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Title and create button
            HStack {
                Text("Code Snippets")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Create snippet button
                Button(action: { showCreateSnippet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.neoGreen)
                                .shadow(color: .neoGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Search bar - full width for iPhone
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                
                TextField("Search snippets...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.neoBackground)
                    .shadow(color: .neoDarkShadow, radius: 3, x: 2, y: 2)
                    .shadow(color: .neoLightShadow, radius: 3, x: -2, y: -2)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.neoBackground.opacity(0.95))
    }
}

struct CategoryFilterView: View {
    let categories: [String]
    @Binding var selectedCategory: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedCategory == category ? .black : .white.opacity(0.8))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Color.neoYellow : Color.neoBackground)
                                    .shadow(
                                        color: selectedCategory == category ? .neoYellow.opacity(0.3) : .neoDarkShadow,
                                        radius: selectedCategory == category ? 4 : 2,
                                        x: selectedCategory == category ? 0 : 1,
                                        y: selectedCategory == category ? 2 : 1
                                    )
                                    .shadow(
                                        color: selectedCategory == category ? .clear : .neoLightShadow,
                                        radius: selectedCategory == category ? 0 : 2,
                                        x: selectedCategory == category ? 0 : -1,
                                        y: selectedCategory == category ? 0 : -1
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(Color.neoBackground.opacity(0.8))
    }
}

struct SnippetsGridView: View {
    let snippets: [CodeSnippet]
    let onSelectSnippet: (CodeSnippet) -> Void
    let onDeleteSnippet: (CodeSnippet) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Snippets (\(snippets.count))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            if snippets.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("No snippets found")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Create your first code snippet to get started")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(40)
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 16) {
                        ForEach(snippets) { snippet in
                            SnippetCard(
                                snippet: snippet,
                                onSelect: { onSelectSnippet(snippet) },
                                onDelete: { onDeleteSnippet(snippet) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Extra padding for tab bar
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.neoBackground)
    }
}

struct SnippetRow: View {
    let snippet: CodeSnippet
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(snippet.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .neoYellow : .white)
                    .lineLimit(2)
                
                HStack {
                    Text(snippet.language.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(snippet.language.syntaxColor.opacity(0.3))
                        )
                    
                    Text(snippet.category)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                        )
                    
                    Spacer()
                }
                
                Text(snippet.createdDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Menu {
                Button("Delete", role: .destructive) {
                    showDeleteAlert = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.neoBackground.opacity(0.8) : Color.clear)
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
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .alert("Delete Snippet", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete '\(snippet.title)'? This action cannot be undone.")
        }
    }
}

struct SnippetCard: View {
    let snippet: CodeSnippet
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with language indicator
                HStack {
                    Text(snippet.language.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(snippet.language.syntaxColor.opacity(0.8))
                        )
                    
                    Spacer()
                    
                    Menu {
                        Button("Delete", role: .destructive) {
                            showDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 20, height: 20)
                    }
                }
                
                // Title
                Text(snippet.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Code preview
                Text(snippet.code.prefix(80) + (snippet.code.count > 80 ? "..." : ""))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Footer with category and date
                HStack {
                    Text(snippet.category)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                        )
                    
                    Spacer()
                    
                    Text(snippet.createdDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(16)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.neoBackground)
                    .shadow(color: .neoLightShadow, radius: 4, x: -2, y: -2)
                    .shadow(color: .neoDarkShadow, radius: 4, x: 2, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Delete Snippet", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete '\(snippet.title)'? This action cannot be undone.")
        }
    }
}

struct SnippetDetailView: View {
    let snippet: CodeSnippet
    let onInsert: (CodeSnippet) -> Void
    let onEdit: (CodeSnippet) -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.neoYellow)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Actions
                HStack(spacing: 12) {
                    Button("Insert") {
                        onInsert(snippet)
                        onBack()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.neoGreen)
                            .shadow(color: .neoGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                    
                    Button("Edit") {
                        onEdit(snippet)
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.neoYellow)
                            .shadow(color: .neoYellow.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.neoBackground.opacity(0.95))
            
            // Snippet info
            VStack(alignment: .leading, spacing: 12) {
                Text(snippet.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                HStack {
                    Text(snippet.language.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(snippet.language.syntaxColor.opacity(0.8))
                        )
                    
                    Text(snippet.category)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                        )
                    
                    Spacer()
                }
                
                Text("Created: \(snippet.createdDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            // Code preview
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Code:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    
                    Text(snippet.code)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.4))
                                .shadow(color: .neoDarkShadow, radius: 2, x: 1, y: 1)
                        )
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 100) // Extra padding for tab bar
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CreateSnippetSheet: View {
    let onCreate: (String, String, ProgrammingLanguage, String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var code = ""
    @State private var selectedLanguage: ProgrammingLanguage = .swift
    @State private var category = ""
    @State private var customCategory = ""
    @State private var useCustomCategory = false
    
    private let predefinedCategories = ["Templates", "Functions", "Classes", "Loops", "Utilities", "UI Components"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Create Code Snippet")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("Enter snippet title", text: $title)
                                .textFieldStyle(NeumorphismTextFieldStyle())
                                .foregroundColor(.white)
                        }
                        
                        // Language
                        VStack(alignment: .leading, spacing: 8) {
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
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Toggle("Use custom category", isOn: $useCustomCategory)
                                .toggleStyle(NeumorphismToggleStyle())
                                .foregroundColor(.white)
                            
                            if useCustomCategory {
                                TextField("Enter custom category", text: $customCategory)
                                    .textFieldStyle(NeumorphismTextFieldStyle())
                                    .foregroundColor(.white)
                            } else {
                                Picker("Category", selection: $category) {
                                    ForEach(predefinedCategories, id: \.self) { cat in
                                        Text(cat).tag(cat)
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
                        }
                        
                        // Code
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Code")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextEditor(text: $code)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(minHeight: 200)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.neoBackground)
                                        .shadow(color: .neoDarkShadow, radius: 3, x: 2, y: 2)
                                        .shadow(color: .neoLightShadow, radius: 3, x: -2, y: -2)
                                )
                                .background(Color.clear)
                        }
                    }
                    
                    Button("Create Snippet") {
                        let finalCategory = useCustomCategory ? customCategory : category
                        if !title.isEmpty && !code.isEmpty && !finalCategory.isEmpty {
                            onCreate(title, code, selectedLanguage, finalCategory)
                        }
                    }
                    .buttonStyle(NeumorphismButtonStyle())
                    .foregroundColor(.neoGreen)
                    .disabled(title.isEmpty || code.isEmpty || (useCustomCategory ? customCategory.isEmpty : category.isEmpty))
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
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
            .onAppear {
                if category.isEmpty {
                    category = predefinedCategories.first ?? ""
                }
            }
        }
    }
}

#Preview {
    SnippetManagerView()
        .environmentObject(MainViewModel())
}
