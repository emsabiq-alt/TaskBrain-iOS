import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(task.isCompleted ? Color.white : Color.gray.opacity(0.4), lineWidth: 1.5)
                        .background(task.isCompleted ? Color.white : Color.clear)
                        .frame(width: 20, height: 20)

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.black)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            // Content
            VStack(alignment: .leading, spacing: 5) {
                // Badges
                HStack(spacing: 6) {
                    // Priority Pill
                    Text(priorityLabel(task.priority))
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(priorityBg(task.priority))
                        .foregroundColor(priorityColor(task.priority))
                        .cornerRadius(4)

                    // Category
                    if let cat = task.category, !cat.isEmpty {
                        Text("#\(cat)")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(white: 0.15))
                            .foregroundColor(.gray)
                            .cornerRadius(4)
                    }

                    // Deadline
                    if let dl = task.deadline, !dl.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                                .font(.system(size: 9))
                            Text(dl)
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.yellow.opacity(0.12))
                        .foregroundColor(Color.yellow)
                        .cornerRadius(4)
                    }
                }

                // Title
                Text(task.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(task.isCompleted ? .gray : .white)
                    .strikethrough(task.isCompleted, color: .gray)
                    .lineLimit(2)

                // Notes
                if let notes = task.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Hapus", systemImage: "trash")
            }
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.indigo)
        }
    }

    private func priorityLabel(_ prio: String?) -> String {
        switch prio {
        case "Tinggi": return "🔴 Tinggi"
        case "Rendah": return "🟢 Rendah"
        default: return "🟡 Sedang"
        }
    }

    private func priorityBg(_ prio: String?) -> Color {
        switch prio {
        case "Tinggi": return Color.red.opacity(0.15)
        case "Rendah": return Color.green.opacity(0.15)
        default: return Color.orange.opacity(0.15)
        }
    }

    private func priorityColor(_ prio: String?) -> Color {
        switch prio {
        case "Tinggi": return Color.red
        case "Rendah": return Color.green
        default: return Color.orange
        }
    }
}
