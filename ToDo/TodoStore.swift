import SwiftUI

class TodoStore: ObservableObject {
    
    @Published var todos: [TodoItem] = []
    var categories: [TodoItem.Category] = []
    
    var todosByDeadline = [String?: [TodoItem]]()
    
    private let fileCache = FileCache()
    
    init() {
        fileCache.loadTasks()
        update(with: currentFilter, sort: currentSort)
        fileCache.loadCategories()
        categories = TodoItem.Category.dafaultCategories + fileCache.categories
    }
    
    func save(_ todo: TodoItem) {
        fileCache.deleteTask(id: todo.id)
        fileCache.add(task: todo)
        update(with: currentFilter, sort: currentSort)
        fileCache.saveTasks()
    }
    
    func save(_ category: TodoItem.Category) {
        fileCache.add(category: category)
        categories.append(category)
        fileCache.saveCategories()
    }
    
    func deleteTodo(with id: String) {
        fileCache.deleteTask(id: id)
        update(with: currentFilter, sort: currentSort)
        fileCache.saveTasks()
    }
    
    func update(with filter: Filter, sort: Sort) {
        currentSort = sort
        currentFilter = filter
        
        todos = fileCache.tasks.sorted {
            if currentSort == .importance {
                $0.importance.value > $1.importance.value && $0.modifiedDate ?? $0.creationDate > $1.modifiedDate ?? $1.creationDate
            } else {
                $0.modifiedDate ?? $0.creationDate > $1.modifiedDate ?? $1.creationDate
            }
        }
        updateDict()
        switch filter {
        case .disable:
            break
        case .isDone:
            todos = todos.filter { !$0.isDone }
        }
    }
    
    func formatted(date: Date?) -> String? {
        guard let date else { return nil }
        
        let locale = Locale(identifier: "ru_RU")
        
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "d MMMM"
        
        return formatter.string(for: date)
    }
    
    func updateDict() {
        var dict = [String?: [TodoItem]]()
        for todo in todos {
            let key = formatted(date: todo.deadline)
            
            if let todos = dict[key] {
                dict[key] = todos + [todo]
            } else {
                dict[key] = [todo]
            }
        }
        todosByDeadline = dict
    }
    
    var doneCount: Int {
        fileCache.tasks.filter { $0.isDone }.count
    }
    
    var currentFilter = Filter.disable
    var currentSort = Sort.date
    
    enum Filter {
        case disable
        case isDone
    }
    
    enum Sort {
        case date
        case importance
    }
}
