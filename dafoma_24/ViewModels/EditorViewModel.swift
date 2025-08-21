//
//  EditorViewModel.swift
//  NeoCoder Road
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation
import SwiftUI

@MainActor
class EditorViewModel: ObservableObject {
    @Published var currentFile: CodeFile?
    @Published var editorText: String = ""
    @Published var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @Published var lineNumbers: [Int] = []
    @Published var showFindReplace = false
    @Published var findText = ""
    @Published var replaceText = ""
    @Published var searchResults: [SearchResult] = []
    
    private let fileService: FileService
    private let userSettingsService: UserSettingsService
    
    init(fileService: FileService, userSettingsService: UserSettingsService) {
        self.fileService = fileService
        self.userSettingsService = userSettingsService
        updateLineNumbers()
    }
    
    func setCurrentFile(_ file: CodeFile) {
        currentFile = file
        editorText = file.content
        updateLineNumbers()
    }
    
    func updateText(_ text: String) {
        editorText = text
        updateLineNumbers()
        
        if let file = currentFile {
            fileService.updateFile(file, content: text)
        }
    }
    
    func insertText(_ text: String, at position: Int) {
        let index = editorText.index(editorText.startIndex, offsetBy: min(position, editorText.count))
        editorText.insert(contentsOf: text, at: index)
        updateText(editorText)
    }
    
    func insertSnippet(_ snippet: CodeSnippet) {
        let insertPosition = selectedRange.location
        insertText(snippet.code, at: insertPosition)
    }
    
    func formatCode() {
        // Simple code formatting
        let lines = editorText.components(separatedBy: .newlines)
        var formattedLines: [String] = []
        var indentLevel = 0
        let tabString = String(repeating: " ", count: userSettingsService.settings.tabSize)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.contains("}") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            let indentedLine = String(repeating: tabString, count: indentLevel) + trimmedLine
            formattedLines.append(indentedLine)
            
            if trimmedLine.contains("{") {
                indentLevel += 1
            }
        }
        
        updateText(formattedLines.joined(separator: "\n"))
    }
    
    func findInCode(_ searchText: String) {
        findText = searchText
        searchResults.removeAll()
        
        if searchText.isEmpty { return }
        
        let text = editorText as NSString
        let range = NSRange(location: 0, length: text.length)
        
        text.enumerateSubstrings(in: range, options: [.byLines, .substringNotRequired]) { [weak self] _, lineRange, _, _ in
            let lineText = text.substring(with: lineRange)
            if lineText.localizedCaseInsensitiveContains(searchText) {
                let lineNumber = text.substring(with: NSRange(location: 0, length: lineRange.location)).components(separatedBy: .newlines).count
                self?.searchResults.append(SearchResult(lineNumber: lineNumber, text: lineText, range: lineRange))
            }
        }
    }
    
    func replaceInCode(_ searchText: String, with replaceText: String) {
        let newText = editorText.replacingOccurrences(of: searchText, with: replaceText)
        updateText(newText)
        findInCode(searchText) // Update search results
    }
    
    func goToLine(_ lineNumber: Int) {
        let lines = editorText.components(separatedBy: .newlines)
        if lineNumber > 0 && lineNumber <= lines.count {
            let charactersBeforeLine = lines.prefix(lineNumber - 1).map { $0.count + 1 }.reduce(0, +)
            selectedRange = NSRange(location: charactersBeforeLine, length: 0)
        }
    }
    
    private func updateLineNumbers() {
        let lineCount = max(1, editorText.components(separatedBy: .newlines).count)
        lineNumbers = Array(1...lineCount)
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let lineNumber: Int
    let text: String
    let range: NSRange
}
