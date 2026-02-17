import SwiftUI

struct ReminderOptionsView: View {
    let bookmark: Bookmark
    @Environment(\.dismiss) private var dismiss
    @State private var selectedContext: ReminderContext = .atHome
    @State private var selectedDate: Date = Date()
    @State private var useContext: Bool = true
    @State private var showingConfirmation = false

    var body: some View {
        NavigationView {
            Form {
                Section("Reminder Type") {
                    Picker("When?", selection: $useContext) {
                        Text("Smart Context").tag(true)
                        Text("Specific Date").tag(false)
                    }
                    .pickerStyle(.segmented)
                }

                if useContext {
                    Section("Context-Aware") {
                        ForEach(ReminderContext.allCases, id: \.self) { context in
                            Button(action: {
                                selectedContext = context
                            }) {
                                HStack {
                                    Image(systemName: context.icon)
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    Text(context.rawValue)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedContext == context {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Section {
                        DatePicker("Remind me on", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    }
                }

                Section {
                    Button(action: { setReminder() }) {
                        HStack {
                            Spacer()
                            Text("Set Reminder")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Reminder Set", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                if useContext {
                    Text("You'll be reminded about \"\(bookmark.displayTitle)\" when: \(selectedContext.rawValue)")
                } else {
                    Text("You'll be reminded about \"\(bookmark.displayTitle)\" on \(selectedDate.formatted(date: .abbreviated, time: .shortened))")
                }
            }
        }
    }

    private func setReminder() {
        // TODO: Persist reminder to server/local storage when endpoint is available
        // For now show confirmation
        showingConfirmation = true
    }
}
