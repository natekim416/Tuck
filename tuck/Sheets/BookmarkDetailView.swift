import SwiftUI

struct BookmarkDetailView: View {
    let bookmark: Bookmark
    @ObservedObject var viewModel: BookmarkViewModel
    var folder: Folder?
    @Environment(\.presentationMode) var presentationMode
    @State private var notes: String
    @State private var showingReminder = false
    
    init(bookmark: Bookmark, viewModel: BookmarkViewModel, folder: Folder? = nil) {
        self.bookmark = bookmark
        self.viewModel = viewModel
        self.folder = folder
        _notes = State(initialValue: bookmark.notes)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let imageURL = bookmark.imageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: bookmark.type.icon)
                            Text(bookmark.type.rawValue)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Text(bookmark.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    if !bookmark.aiSummary.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("AI Summary")
                                    .font(.headline)
                            }
                            .foregroundColor(.purple)
                            
                            Text(bookmark.aiSummary)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: { showingReminder = true }) {
                            Label("Remind", systemImage: "bell")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        if folder != nil {
                            Button(action: { toggleComplete() }) {
                                Label(bookmark.isCompleted ? "Done" : "Mark Done", 
                                      systemImage: "checkmark.circle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    
                    Link(destination: URL(string: bookmark.url)!) {
                        HStack {
                            Spacer()
                            Text("Open Link")
                            Image(systemName: "arrow.up.right")
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingReminder) {
                ReminderOptionsView(bookmark: bookmark)
            }
        }
    }
    
    private func toggleComplete() {
        guard let folder = folder else { return }
        viewModel.toggleBookmarkComplete(bookmark, in: folder)
        presentationMode.wrappedValue.dismiss()
    }
}
