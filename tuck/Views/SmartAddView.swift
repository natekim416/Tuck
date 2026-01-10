import SwiftUI

struct SmartAddItemView: View {
    @State private var inputText: String = ""
    @State private var analysis: AIAnalysisResult?
    @State private var isAnalyzing = false
    
    let aiService = SmartSortService(apiKey: )
    
    var body: some View {
        VStack(spacing: 20) {
            // 1. Input Area
            TextEditor(text: $inputText)
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                .padding()
            
            // 2. Magic Button
            Button(action: analyzeItem) {
                if isAnalyzing {
                    ProgressView()
                } else {
                    Label("Auto-Sort with AI", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputText.isEmpty)
            .padding(.horizontal)
            
            // 3. Review Card (Only appears after analysis)
            if let result = analysis {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Review Suggestions").font(.caption).bold().foregroundStyle(.secondary)
                    
                    // Folder Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(result.folders, id: \.self) { folder in
                                ChipView(label: folder) {
                                    // Remove folder on tap
                                    analysis?.folders.removeAll { $0 == folder }
                                }
                            }
                            
                            // Add Manual Folder Button
                            Button(action: { /* Add folder logic */ }) {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Metadata Row
                    HStack {
                        if let price = result.price {
                            Label(String(format: "$%.2f", price), systemImage: "tag.fill")
                                .foregroundStyle(.green)
                        }
                        if let date = result.deadline {
                            Label(date, systemImage: "calendar.badge.clock")
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
        }
    }
    
    func analyzeItem() {
        isAnalyzing = true
        Task {
            // TODO: Fetch previous 3 user items here to pass as 'userExamples'
            let mockHistory = ""
            
            do {
                let result = try await aiService.analyzeContent(text: inputText, userExamples: mockHistory)
                withAnimation {
                    self.analysis = result
                    self.isAnalyzing = false
                }
            } catch {
                print(error)
                isAnalyzing = false
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
