import Foundation

struct TodoItem: Identifiable {
    
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let creationDate: Date
    let modifiedDate: Date?
    let color: Color
    let category: Category
    
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isDone: Bool = false,
        creationDate: Date = .now,
        modifiedDate: Date? = nil,
        color: Color = Color.default,
        category: Category = Category.default
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.creationDate = creationDate
        self.modifiedDate = modifiedDate
        self.color = color
        self.category = category
    }
    
    func switchIsDone() -> TodoItem {
        TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: !isDone,
            creationDate: creationDate,
            modifiedDate: .now,
            color: color,
            category: category
        )
    }
    
    enum Importance: String, CaseIterable, Identifiable {
        var value: Int {
            switch self {
            case .unimportant:
                return 0
            case .ordinary:
                return 1
            case .important:
                return 2
            }
        }
        
        var id: String {
            rawValue
        }
        
        case unimportant, ordinary, important
    }
    
    struct Color: Codable, Equatable, Hashable {
        let hex: String
        var opacity: Double
        
        static let `default` = Color(hex: "#FEFEFE", opacity: 1.0)
    }
    
    struct Category: Codable, Hashable {
        let name: String
        let color: Color
        
        static let `default` = Category(name: "Личное", color: .init(hex: "#aec6cf", opacity: 1.0))
        static let dafaultCategories = [
            Category(name: "Личное", color: Color(hex: "#aec6cf", opacity: 1.0)),
            Category(name: "Работа", color: Color(hex: "#f45353", opacity: 1.0)),
            Category(name: "Учеба", color: Color(hex: "#3d85c6", opacity: 1.0)),
            Category(name: "Хобби", color: Color(hex: "#8fce00", opacity: 1.0)),
            Category(name: "Другое", color: Color(hex: "#ffffff", opacity: 1.0))
        ]
    }
    
}
extension TodoItem {
    
    var json: Any {
        
        var object: [String: Any] = [
            "id": id,
            "text": text,
            "isDone": isDone,
            "creationDate": creationDate.ISO8601Format(),
            "colorHex": color.hex,
            "colorOpacity": color.opacity,
            "categoryName": category.name,
            "categoryColor": category.color.hex
        ]
        
        if importance != .ordinary {
            object["importance"] = importance.rawValue
        }
    
        if let deadline {
            object["deadline"] = deadline.ISO8601Format()
        }
        
        if let modifiedDate {
            object["modifiedDate"] = modifiedDate.ISO8601Format()
        }
        
        return object
    }
    
    static func parse(json: Any) -> TodoItem? {
        
        guard let jsonDict = json as? [String: Any] else { return nil }
        
        let formatter = ISO8601DateFormatter()
        
        guard let id = jsonDict["id"] as? String,
              let text = jsonDict["text"] as? String,
              let isDone = jsonDict["isDone"] as? Bool,
              let creationDateString = jsonDict["creationDate"] as? String,
              let creationDate = formatter.date(from: creationDateString),
              let colorHex = jsonDict["colorHex"] as? String,
              let colorOpacity = jsonDict["colorOpacity"] as? Double,
              let categoryName = jsonDict["categoryName"] as? String,
              let categoryColor = jsonDict["categoryColor"] as? String
        else { return nil }
    
        let importance = (jsonDict["importance"] as? String).flatMap { Importance(rawValue: $0) } ?? .ordinary
        let deadline = (jsonDict["deadline"] as? String).flatMap { formatter.date(from: $0) }
        let modifiedDate = (jsonDict["modifiedDate"] as? String).flatMap { formatter.date(from: $0) }
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            creationDate: creationDate,
            modifiedDate: modifiedDate,
            color: Color(hex: colorHex, opacity: colorOpacity),
            category: Category(name: categoryName, color: Color(hex: categoryColor, opacity: 1.0))
        )
    }
    
    static func parse(csv: String) -> [TodoItem] {
        
        var rows = csv.components(separatedBy: "\n")
                
        guard let keys = rows.first?.components(separatedBy: ","),
              let idIndex = keys.firstIndex(of: "id"),
              let textIndex = keys.firstIndex(of: "text"),
              let isDoneIndex = keys.firstIndex(of: "isDone"),
              let creationDateIndex = keys.firstIndex(of: "creationDate")
        else { return [] }
        
        let importanceIndex = keys.firstIndex(of: "importance")
        let deadlineIndex = keys.firstIndex(of: "deadline")
        let modifiedDateIndex = keys.firstIndex(of: "modifiedDate")
        
        rows.removeFirst()
        return rows.compactMap { row in
            let values = row.components(separatedBy: ",")
            
            let isDone: Bool
            if values[isDoneIndex] == "true" {
                isDone = true
            } else if values[isDoneIndex] == "false" {
                isDone = false
            } else {
                return nil
            }
            
            let formatter = ISO8601DateFormatter()
            guard let creationDate = formatter.date(from: values[creationDateIndex]) else {
                return nil
            }
            
            let importance = importanceIndex.flatMap { values[$0] }.flatMap { Importance(rawValue: $0) } ?? .ordinary
            
            let deadline = deadlineIndex.flatMap { values[$0] }.flatMap { formatter.date(from: $0) }
            
            let modifiedDate = modifiedDateIndex.flatMap { values[$0] }.flatMap { formatter.date(from: $0) }
            
            return TodoItem(
                id: values[idIndex],
                text: values[textIndex],
                importance: importance,
                deadline: deadline,
                isDone: isDone,
                creationDate: creationDate,
                modifiedDate: modifiedDate
            )
        }
    }
}
