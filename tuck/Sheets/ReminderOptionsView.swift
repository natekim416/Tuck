import SwiftUI

struct ReminderOptionsView: View {
    let bookmark: Bookmark
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedContext: ReminderContext = .atHome
    @State private var selectedDate: Date = Date()
    @State private var useContext: Bool = true
    
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
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
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
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
