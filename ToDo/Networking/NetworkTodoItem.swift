import Foundation

struct NetworkTodoItem: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int?
    let done: Bool
    let color: String
    let createdAt: Int
    let changedAt: Int
    let lastUpdatedBy = "none"
    
    enum CodingKeys: String, CodingKey {
        case id, text, importance, deadline, done, color
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy  = "last_updated_by"
    }
    
    init(todo: TodoItem) {
        id = todo.id
        text = todo.text
        switch todo.importance {
        case .unimportant:
            importance = "low"
        case .ordinary:
            importance = "basic"
        case .important:
            importance = "important"
        }
        deadline = todo.deadline.flatMap { Int($0.timeIntervalSince1970) }
        done = todo.isDone
        if todo.category == .default {
            color = "\(todo.color.hex) \(todo.color.opacity)"
        } else {
            color = "\(todo.color.hex) \(todo.color.opacity) \(todo.category.name) \(todo.category.color.hex) \(todo.category.color.opacity)"
        }
        createdAt = Int(todo.creationDate.timeIntervalSince1970)
        changedAt = todo.modifiedDate.flatMap { Int($0.timeIntervalSince1970) } ?? Int(Date().timeIntervalSince1970)
    }
    
    var todoItem: TodoItem {
        let importance: TodoItem.Importance
        switch self.importance {
        case "low":
            importance = .unimportant
        case "basic":
            importance = .ordinary
        case "important":
            importance = .important
        default:
            importance = .ordinary
        }
        
        let color: TodoItem.Color
        let category: TodoItem.Category
        
        let colorComponents = self.color.split(separator: " ")
        if colorComponents.count == 5 {
            let hex = String(colorComponents[0])
            let opacity = Double(colorComponents[1])!
            let categoryName = String(colorComponents[2])
            let categoryHex = String(colorComponents[3])
            let categoryOpacity = Double(colorComponents[4])!
            
            color = .init(hex: hex, opacity: opacity)
            category = .init(name: categoryName, color: .init(hex: categoryHex, opacity: categoryOpacity))
        } else {
            let hex = String(colorComponents[0])
            let opacity = Double(colorComponents[1])!
            
            color = .init(hex: hex, opacity: opacity)
            category = .default
        }
        
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline:  deadline.flatMap { Date(timeIntervalSince1970: Double($0)) },
            isDone: done,
            creationDate: Date(timeIntervalSince1970: Double(createdAt)),
            modifiedDate: Date(timeIntervalSince1970: Double(changedAt)),
            color: color,
            category: category
        )
    }
}
