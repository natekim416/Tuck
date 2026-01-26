import SwiftUI

struct SmartSortView: View {
    @State private var inputText = ""
    @State private var result: AIAnalysisResult?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Input Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter text or URL to analyze")
                            .font(.headline)
                        
                        TextEditor(text: $inputText)
                            .frame(height: 150)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                            .onChange(of: inputText) { _ in
                                errorMessage = nil
                                result = nil
                            }
                    }
                    .padding(.horizontal)
                    
                    // Analyze Button
                    Button(action: analyze) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Analyze")
                            }
                            .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(inputText.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isLoading || inputText.isEmpty)
                    
                    // Error Message
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Results
                    if let result = result {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Analysis Results")
                                .font(.title2)
                                .bold()
                            
                            if !result.folders.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Suggested Folders")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    ForEach(result.folders, id: \.self) { folder in
                                        HStack {
                                            Image(systemName: "folder.fill")
                                                .foregroundColor(.blue)
                                            Text(folder)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            
                            if let deadline = result.deadline {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.orange)
                                    VStack(alignment: .leading) {
                                        Text("Deadline")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(deadline)
                                            .font(.body)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            if let price = result.price {
                                HStack {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundColor(.green)
                                    VStack(alignment: .leading) {
                                        Text("Price")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("$\(price, specifier: "%.2f")")
                                            .font(.body)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Smart Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func analyze() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let analysisResult = try await TuckServerAPI.shared.smartSort(text: inputText)
                await MainActor.run {
                    result = analysisResult
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    SmartSortView()
}