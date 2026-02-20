import SwiftUI
import PhotosUI

struct AddBookmarkView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: BookmarkViewModel
    
    @State private var url = ""
    @State private var title = ""
    @State private var notes = ""
    @State private var isAnalyzing = false
    @State private var isSaving = false
    @State private var analysisResult: AIAnalysisResult?
    @State private var errorMessage: String?
    
    // Photo support
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var bookmarkType: BookmarkType = .article
    
    // Save confirmation
    @State private var saveResult: ServerSavedBookmark?
    @State private var showingSaveConfirmation = false
    
    var onBookmarkSaved: (() -> Void)?
    
    /// Whether we have something to save (URL or photo)
    private var hasContent: Bool {
        !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil
    }
    
    /// Existing folder names to pass as context to AI
    private var existingFolderNames: String {
        viewModel.folders.map { $0.name }.joined(separator: ", ")
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Type picker
                Section(header: Text("Type")) {
                    Picker("Bookmark Type", selection: $bookmarkType) {
                        ForEach([BookmarkType.article, .video, .product, .photo, .screenshot, .tweet, .other], id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // URL input (for link-based bookmarks)
                if bookmarkType.prefersURL {
                    Section(header: Text("Link")) {
                        TextField("URL", text: $url)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                    }
                }
                
                // Photo picker (for photo/screenshot types or as optional for any type)
                Section(header: Text(bookmarkType.prefersAssets ? "Photo" : "Photo (optional)")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                        
                        Button(role: .destructive) {
                            selectedImage = nil
                            selectedPhotoItem = nil
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label(selectedImage == nil ? "Choose Photo" : "Change Photo", systemImage: "photo.on.rectangle")
                    }
                }
                
                // Title & notes
                Section(header: Text("Details")) {
                    TextField("Title (optional)", text: $title)
                    
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
                
                // Error
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                // AI Preview
                if let result = analysisResult {
                    Section(header: Text("AI Suggests")) {
                        if !result.folders.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Folder:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ForEach(result.folders, id: \.self) { folder in
                                    HStack {
                                        Image(systemName: folderIsNew(folder) ? "folder.badge.plus" : "folder.fill")
                                            .foregroundColor(folderIsNew(folder) ? .orange : .blue)
                                        Text(folder)
                                        if folderIsNew(folder) {
                                            Text("(new)")
                                                .font(.caption2)
                                                .foregroundColor(.orange)
                                        }
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
                
                // Actions
                Section {
                    // Preview button (only for URL bookmarks)
                    if !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
                    }
                    
                    // Save button
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
                    .disabled(!hasContent || isSaving || isAnalyzing)
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
            .onChange(of: selectedPhotoItem) { newItem in
                loadPhoto(from: newItem)
            }
            .alert("Bookmark Saved!", isPresented: $showingSaveConfirmation) {
                Button("OK") {
                    onBookmarkSaved?()
                    dismiss()
                }
            } message: {
                if let result = saveResult {
                    let folderName = result.folder?.name ?? "Uncategorized"
                    let isNew = !viewModel.folders.contains(where: { $0.name.lowercased() == folderName.lowercased() })
                    if isNew {
                        Text("Saved to new folder: \"\(folderName)\"")
                    } else {
                        Text("Saved to folder: \"\(folderName)\"")
                    }
                } else {
                    Text("Your bookmark has been saved.")
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func folderIsNew(_ name: String) -> Bool {
        !viewModel.folders.contains(where: { $0.name.lowercased() == name.lowercased() })
    }
    
    private func loadPhoto(from item: PhotosPickerItem?) {
        guard let item else { return }
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data, let image = UIImage(data: data) {
                        self.selectedImage = image
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to load photo: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - API Calls
    
    func analyzePreview() {
        isAnalyzing = true
        errorMessage = nil
        
        Task {
            do {
                // Pass existing folder names as context so AI uses real folders
                let folderContext = existingFolderNames.isEmpty ? nil : "Existing folders: \(existingFolderNames)"
                let result = try await TuckServerAPI.shared.analyzeBookmarkWithContext(
                    url: url,
                    title: title.isEmpty ? nil : title,
                    notes: notes.isEmpty ? nil : notes,
                    existingFolders: folderContext
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
        // For photo-only bookmarks with no URL, save locally
        if url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            savePhotoBookmarkLocally()
            return
        }
        
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
                    saveResult = saved
                    showingSaveConfirmation = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSaving = false
                }
            }
        }
    }
    
    /// Save a photo bookmark locally (no server upload)
    private func savePhotoBookmarkLocally() {
        guard let image = selectedImage else {
            errorMessage = "Please add a URL or select a photo."
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        // Save image to shared container
        let filename = "\(UUID().uuidString).jpg"
        if let data = image.jpegData(compressionQuality: 0.8) {
            let relativePath = "photos/\(filename)"
            let fileURL = SharedMediaStore.absoluteURL(for: relativePath)
            
            // Create directory if needed
            try? FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try? data.write(to: fileURL)
            
            let asset = BookmarkAsset(
                relativePath: relativePath,
                thumbnailRelativePath: nil,
                uti: "public.jpeg",
                originalFilename: filename
            )
            
            // Create local bookmark
            let bookmark = Bookmark(
                url: "",
                title: title.isEmpty ? "Photo" : title,
                notes: notes.isEmpty ? nil : notes
            )
            var mutableBookmark = bookmark
            mutableBookmark.type = bookmarkType == .article ? .photo : bookmarkType
            mutableBookmark.assets = [asset]
            
            // Add to first folder or a "Photos" folder
            let targetFolder = viewModel.folders.first(where: { $0.name == "Photos" }) ?? viewModel.folders.first
            
            if let folder = targetFolder {
                viewModel.addBookmark(mutableBookmark, to: folder)
            }
            
            isSaving = false
            onBookmarkSaved?()
            dismiss()
        } else {
            errorMessage = "Failed to save photo."
            isSaving = false
        }
    }
}

#Preview {
    AddBookmarkView()
        .environmentObject(BookmarkViewModel())
}
