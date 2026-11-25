import Foundation

@MainActor
class APIService: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var stats: TaskStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var baseURL: String {
        UserDefaults.standard.string(forKey: "server_url") ?? "http://100.101.36.81:8765"
    }

    func fetchTasks() async {
        guard let url = URL(string: "\(baseURL)/api/tasks") else {
            errorMessage = "Invalid Base URL"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Server returned error code"
                isLoading = false
                return
            }

            let decoded = try JSONDecoder().decode(TasksResponse.self, from: data)
            self.tasks = decoded.tasks
            self.stats = decoded.stats
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    func organizeRawText(_ text: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/tasks/organize") else { return false }
        isLoading = true

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(OrganizeRequest(rawText: text))

            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                isLoading = false
                return false
            }

            await fetchTasks()
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func addQuickTask(title: String, priority: String, category: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/tasks/quick") else { return false }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(QuickTaskRequest(
                title: title,
                priority: priority,
                category: category,
                deadline: nil,
                notes: nil
            ))

            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return false }
            await fetchTasks()
            return true
        } catch {
            return false
        }
    }

    func toggleDone(task: TaskItem) async {
        guard let url = URL(string: "\(baseURL)/api/tasks/\(task.id)") else { return }
        let nextStatus = !task.isCompleted

        // Optimistic UI update
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx].isCompleted = nextStatus
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(UpdateTaskRequest(
                isDone: nextStatus,
                title: nil,
                priority: nil,
                category: nil,
                deadline: nil,
                notes: nil
            ))

            _ = try await URLSession.shared.data(for: request)
            await fetchTasks()
        } catch {
            // Rollback on error
            await fetchTasks()
        }
    }

    func updateTask(id: Int, title: String, priority: String, category: String, deadline: String?, notes: String?) async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/tasks/\(id)") else { return false }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(UpdateTaskRequest(
                isDone: nil,
                title: title,
                priority: priority,
                category: category,
                deadline: deadline,
                notes: notes
            ))

            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return false }
            await fetchTasks()
            return true
        } catch {
            return false
        }
    }

    func deleteTask(id: Int) async {
        guard let url = URL(string: "\(baseURL)/api/tasks/\(id)") else { return }
        tasks.removeAll(where: { $0.id == id })

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            _ = try await URLSession.shared.data(for: request)
            await fetchTasks()
        } catch {
            await fetchTasks()
        }
    }

    func clearCompleted() async {
        guard let url = URL(string: "\(baseURL)/api/tasks/completed/clear") else { return }
        tasks.removeAll(where: { $0.isCompleted })

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            _ = try await URLSession.shared.data(for: request)
            await fetchTasks()
        } catch {
            await fetchTasks()
        }
    }

    func triggerTelegramReminder() async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/remind/trigger") else { return false }
        do {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            let (_, res) = try await URLSession.shared.data(for: req)
            return (res as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}
