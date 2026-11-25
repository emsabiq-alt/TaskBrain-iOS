import SwiftUI

enum FilterTab: String, CaseIterable {
    case all = "Semua"
    case active = "Pending"
    case done = "Selesai"
}

struct ContentView: View {
    @StateObject private var api = APIService()

    @State private var selectedFilter: FilterTab = .all
    @State private var searchQuery: String = ""
    @State private var showBrainDumpSheet: Bool = false
    @State private var showSettingsSheet: Bool = false
    @State private var selectedTaskToEdit: TaskItem? = nil

    @State private var quickTitle: String = ""

    var filteredTasks: [TaskItem] {
        var list = api.tasks
        switch selectedFilter {
        case .all: break
        case .active: list = list.filter { !$0.isCompleted }
        case .done: list = list.filter { $0.isCompleted }
        }

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            list = list.filter {
                $0.title.lowercased().contains(query) ||
                ($0.notes?.lowercased().contains(query) ?? false) ||
                ($0.category?.lowercased().contains(query) ?? false)
            }
        }
        return list
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Progress & Metrics Card (Bento Style)
                    if let stats = api.stats {
                        VStack(spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("PROGRES HARI INI")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.gray)

                                    if stats.highPriority > 0 {
                                        Text("⚠️ \(stats.highPriority) tugas prioritas tinggi")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.red)
                                    } else {
                                        Text("\(stats.done) dari \(stats.total) tugas selesai")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }

                                Spacer()

                                Text("\(stats.percentage)%")
                                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                                    .foregroundColor(.indigo)
                            }

                            // Progress Bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(white: 0.15))
                                        .frame(height: 6)

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * CGFloat(Double(stats.percentage) / 100.0), height: 6)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(14)
                        .background(Color(white: 0.08))
                        .cornerRadius(14)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }

                    // Quick Task Input Bar
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.gray)
                        TextField("Tambah tugas cepat...", text: $quickTitle)
                            .font(.system(size: 14))
                            .onSubmit {
                                addQuick()
                            }

                        if !quickTitle.isEmpty {
                            Button(action: addQuick) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.indigo)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Color(white: 0.08))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Filter Selector & Search
                    HStack {
                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(FilterTab.allCases, id: \.self) { tab in
                                Text(tab.rawValue).tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Task List
                    if api.isLoading && api.tasks.isEmpty {
                        Spacer()
                        ProgressView("Memuat tugas...")
                            .tint(.white)
                        Spacer()
                    } else if filteredTasks.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 36))
                                .foregroundColor(.gray.opacity(0.6))
                            Text("Tidak ada tugas")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredTasks) { task in
                                TaskRowView(
                                    task: task,
                                    onToggle: {
                                        Task { await api.toggleDone(task: task) }
                                    },
                                    onEdit: {
                                        selectedTaskToEdit = task
                                    },
                                    onDelete: {
                                        Task { await api.deleteTask(id: task.id) }
                                    }
                                )
                                .listRowBackground(Color(white: 0.04))
                                .listRowSeparatorTint(Color(white: 0.12))
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .refreshable {
                            await api.fetchTasks()
                        }
                    }
                }

                // Floating Action Button (AI Brain Dump)
                Button(action: { showBrainDumpSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 16, weight: .bold))
                        Text("AI Brain Dump")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(30)
                    .shadow(color: Color.indigo.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .background(Color(white: 0.03).ignoresSafeArea())
            .navigationTitle("TaskBrain")
            .searchable(text: $searchQuery, prompt: "Cari tugas...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettingsSheet = true }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Task { await api.fetchTasks() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showBrainDumpSheet) {
                BrainDumpSheet()
                    .environmentObject(api)
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsView()
                    .environmentObject(api)
            }
            .sheet(item: $selectedTaskToEdit) { task in
                EditTaskSheet(task: task)
                    .environmentObject(api)
            }
            .task {
                await api.fetchTasks()
            }
        }
    }

    private func addQuick() {
        let t = quickTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        quickTitle = ""
        Task {
            _ = await api.addQuickTask(title: t, priority: "Sedang", category: "Kerjaan")
        }
    }
}
