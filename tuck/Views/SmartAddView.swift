import SwiftUI

struct SmartAddItemView: View {
    @Environment(\.dismiss) var dismiss
    @State private var inputText: String = ""
    @State private var analysis: AIAnalysisResult?
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    
    // Use the shared singleton - no initialization needed
    private let aiService = SmartSortService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 1. Input Area
                VStack(alignment: .leading, spacing: 8) {
                    Text("Paste URL or enter text")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextEditor(text: $inputText)
                        .frame(height: 120)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                        .padding(.horizontal)
                }
                
                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // 2. Magic Button
                Button(action: analyzeItem) {
                    if isAnalyzing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Label("Auto-Sort with AI", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(inputText.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(inputText.isEmpty || isAnalyzing)
                .padding(.horizontal)
                
                // 3. Review Card (Only appears after analysis)
                if let result = analysis {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Review Suggestions")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.secondary)
                        
                        // Folder Chips
                        if !result.folders.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(result.folders, id: \.self) { folder in
                                        ChipView(label: folder) {
                                            // Remove folder on tap
                                            withAnimation {
                                                analysis?.folders.removeAll { $0 == folder }
                                            }
                                        }
                                    }
                                    
                                    // Add Manual Folder Button
                                    Button(action: { /* Add folder logic */ }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Metadata Row
                        HStack(spacing: 16) {
                            if let price = result.price {
                                Label(String(format: "$%.2f", price), systemImage: "tag.fill")
                                    .foregroundStyle(.green)
                            }
                            if let date = result.deadline {
                                Label(date, systemImage: "calendar.badge.clock")
                                    .foregroundStyle(.orange)
                            }
                        }
                        .font(.subheadline)
                        
                        // Save Button
                        Button(action: saveBookmark) {
                            Label("Save Bookmark", systemImage: "arrow.down.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
            }
            .navigationTitle("Smart Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func analyzeItem() {
        isAnalyzing = true
        errorMessage = nil
        
        Task {
            do {
                // Analyze without saving
                let result = try await aiService.analyze(text: inputText, userExamples: nil)
                await MainActor.run {
                    withAnimation {
                        self.analysis = result
                        self.isAnalyzing = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isAnalyzing = false
                }
            }
        }
    }
    
    func saveBookmark() {
        Task {
            do {
                // Save with auto-sort
                _ = try await aiService.analyzeAndSave(
                    url: inputText,
                    title: nil,
                    notes: nil
                )
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// Helper View for the Chips
struct ChipView: View {
    let label: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.15))
        .foregroundColor(.blue)
        .cornerRadius(20)
    }
}

#Preview {
    SmartAddItemView()
}
