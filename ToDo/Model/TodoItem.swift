import Foundation
import SwiftData

@Model
class TodoItem: Identifiable {
    
    @Attribute(.unique) var id: String
    var text: String
    var importance: Importance
    var deadline: Date?
    var isDone: Bool
    var creationDate: Date
    var modifiedDate: Date?
    var color: Color
    var category: Category
    
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
    
    enum Importance: String, CaseIterable, Identifiable, Codable {
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
