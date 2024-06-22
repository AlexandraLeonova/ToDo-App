import Foundation

struct TodoItem {
    
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let creationDate: Date
    let modifiedDate: Date?
    
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isDone: Bool = false,
        creationDate: Date = .now,
        modifiedDate: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.creationDate = creationDate
        self.modifiedDate = modifiedDate
    }
    
    enum Importance: String {
        case unimportant, ordinary, important
    }
    
}
extension TodoItem {
    
    var json: Any {
        
        var object: [String: Any] = [
            "id": id,
            "text": text,
            "importance": importance,
            "isDone": isDone,
            "creationDate": creationDate.ISO8601Format(),
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
              let creationDate = formatter.date(from: creationDateString)
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
            modifiedDate: modifiedDate
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
