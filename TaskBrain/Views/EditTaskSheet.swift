import SwiftUI

struct EditTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var api: APIService

    let task: TaskItem

    @State private var title: String = ""
    @State private var priority: String = "Sedang"
    @State private var category: String = "Kerjaan"
    @State private var deadline: String = ""
    @State private var notes: String = ""
    @State private var isSaving: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informasi Tugas")) {
                    TextField("Judul Tugas", text: $title)
                    TextField("Kategori", text: $category)
                }

                Section(header: Text("Prioritas & Waktu")) {
                    Picker("Prioritas", selection: $priority) {
                        Text("🔴 Tinggi").tag("Tinggi")
                        Text("🟡 Sedang").tag("Sedang")
                        Text("🟢 Rendah").tag("Rendah")
                    }
                    .pickerStyle(.segmented)

                    TextField("Deadline (contoh: Besok 15:00)", text: $deadline)
                }

                Section(header: Text("Catatan / Konteks")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Edit Tugas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        saveChanges()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
            }
            .onAppear {
                title = task.title
                priority = task.priority ?? "Sedang"
                category = task.category ?? "Kerjaan"
                deadline = task.deadline ?? ""
                notes = task.notes ?? ""
            }
        }
    }

    private func saveChanges() {
        isSaving = true
        Task {
            _ = await api.updateTask(
                id: task.id,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                priority: priority,
                category: category.trimmingCharacters(in: .whitespacesAndNewlines),
                deadline: deadline.isEmpty ? nil : deadline,
                notes: notes.isEmpty ? nil : notes
            )
            isSaving = false
            dismiss()
        }
    }
}
