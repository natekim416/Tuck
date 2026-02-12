import SwiftUI

struct AddBookmarkView: View {
    @Environment(\.dismiss) var dismiss
    @State private var url = ""
    @State private var title = ""
    @State private var notes = ""
    @State private var isAnalyzing = false
    @State private var isSaving = false
    @State private var showingPreview = false
    @State private var analysisResult: AIAnalysisResult?
    @State private var errorMessage: String?
    
    var onBookmarkSaved: (() -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bookmark Details")) {
                    TextField("URL", text: $url)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    
                    TextField("Title (optional)", text: $title)
                    
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                if let result = analysisResult {
                    Section(header: Text("AI Analysis Preview")) {
                        if !result.folders.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Will be saved to:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ForEach(result.folders, id: \.self) { folder in
                                    HStack {
                                        Image(systemName: "folder.fill")
                                            .foregroundColor(.blue)
                                        Text(folder)
                                    }
                                }
                            }
                        }
                        
                        if let deadline = result.deadline {
                            Label(deadline, systemImage: "calendar")
                        }
                        
                        if let price = result.price {
                            Label("$\(price, specifier: "%.2f")", systemImage: "dollarsign.circle")
                        }
                    }
                }
                
                Section {
                    Button(action: analyzePreview) {
                        HStack {
                            if isAnalyzing {
                                ProgressView()
                            } else {
                                Image(systemName: "sparkles")
                                Text("Preview Smart Sort")
                            }
                        }
                    }
                    .disabled(url.isEmpty || isAnalyzing || isSaving)
                    
                    Button(action: saveBookmark) {
                        HStack {
                            if isSaving {
                                ProgressView()
                            } else {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Save & Auto-Sort")
                            }
                        }
                    }
                    .disabled(url.isEmpty || isSaving || isAnalyzing)
                }
            }
            .navigationTitle("Add Bookmark")
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
    
    func analyzePreview() {
        isAnalyzing = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await TuckServerAPI.shared.analyzeBookmark(
                    url: url,
                    title: title.isEmpty ? nil : title,
                    notes: notes.isEmpty ? nil : notes
                )
                
                await MainActor.run {
                    analysisResult = result
                    isAnalyzing = false
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
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                let saved = try await TuckServerAPI.shared.analyzeAndSaveBookmark(
                    url: url,
                    title: title.isEmpty ? nil : title,
                    notes: notes.isEmpty ? nil : notes
                )
                
                await MainActor.run {
                    isSaving = false
                    onBookmarkSaved?()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSaving = false
                }
            }
        }
    }
}

#Preview {
    AddBookmarkView()
}
