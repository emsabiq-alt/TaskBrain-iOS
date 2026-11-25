import Foundation

struct TaskItem: Identifiable, Codable, Hashable {
    let id: Int
    var title: String
    var priority: String?
    var category: String?
    var deadline: String?
    var notes: String?
    var isDone: Int
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case priority
        case category
        case deadline
        case notes
        case isDone = "is_done"
        case createdAt = "created_at"
    }

    var isCompleted: Bool {
        get { isDone == 1 }
        set { isDone = newValue ? 1 : 0 }
    }
}

struct TaskStats: Codable {
    let total: Int
    let active: Int
    let done: Int
    let highPriority: Int
    let percentage: Int

    enum CodingKeys: String, CodingKey {
        case total
        case active
        case done
        case highPriority = "high_priority"
        case percentage
    }
}

struct TasksResponse: Codable {
    let tasks: [TaskItem]
    let stats: TaskStats?
    let categories: [String]?
}

struct OrganizeRequest: Codable {
    let rawText: String

    enum CodingKeys: String, CodingKey {
        case rawText = "raw_text"
    }
}

struct QuickTaskRequest: Codable {
    let title: String
    let priority: String
    let category: String
    let deadline: String?
    let notes: String?
}

struct UpdateTaskRequest: Codable {
    let isDone: Bool?
    let title: String?
    let priority: String?
    let category: String?
    let deadline: String?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case isDone = "is_done"
        case title
        case priority
        case category
        case deadline
        case notes
    }
}
