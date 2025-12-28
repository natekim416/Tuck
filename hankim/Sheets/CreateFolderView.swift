import SwiftUI

struct CreateFolderView: View {
    @ObservedObject var viewModel: BookmarkViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedColor: String = "blue"
    @State private var selectedIcon: String = "folder"
    @State private var selectedOutcome: FolderOutcome = .learn
    @State private var isPublic: Bool = false
    
    let colors = ["blue", "green", "purple", "orange", "pink", "red", "yellow", "gray"]
    let icons = ["folder", "book", "cart", "lightbulb", "star", "heart", "bookmark", 
                 "flag", "briefcase", "graduationcap", "music.note", "film", "camera"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Folder Info") {
                    TextField("Name", text: $name)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Purpose") {
                    Picker("What's this for?", selection: $selectedOutcome) {
                        ForEach(FolderOutcome.allCases, id: \.self) { outcome in
                            HStack {
                                Image(systemName: outcome.icon)
                                Text(outcome.rawValue)
                            }
                            .tag(outcome)
                        }
                    }
                }
                
                Section("Appearance") {
                    Picker("Icon", selection: $selectedIcon) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .tag(icon)
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(Color(color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("Privacy") {
                    Toggle("Make Public", isOn: $isPublic)
                }
                
                Section {
                    FolderCard(folder: Folder(
                        name: name.isEmpty ? "New Folder" : name,
                        description: description,
                        isPublic: isPublic,
                        color: selectedColor,
                        icon: selectedIcon,
                        outcome: selectedOutcome
                    ))
                    .frame(maxWidth: .infinity, alignment: .center)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Create Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createFolder()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func createFolder() {
        let folder = Folder(
            name: name,
            description: description,
            isPublic: isPublic,
            color: selectedColor,
            icon: selectedIcon,
            outcome: selectedOutcome
        )
        
        viewModel.createFolder(folder)
        presentationMode.wrappedValue.dismiss()
    }
}
