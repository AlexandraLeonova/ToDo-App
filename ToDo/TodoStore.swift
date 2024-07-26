import SwiftUI

class TodoStore: ObservableObject {
    
    @Published var todos: [TodoItem] = []
    @Published var isLoading = false
    var categories: [TodoItem.Category] = []
    private var isDirty = true
    
    var todosByDeadline = [String?: [TodoItem]]()
    
    private let fileCache = FileCache()
    
    private let networkingService: NetworkingService = DefaultNetworkingService()
    
    init() {
        if isDirty {
            fileCache.fetch()
            update(with: currentFilter, sort: currentSort)
            updateTodoItems()
        } else {
            fetchTodoItems()
        }
        
        fileCache.loadCategories()
        categories = TodoItem.Category.dafaultCategories + fileCache.categories
    }
    
    func updateTodoItems() {
        isLoading = true
        networkingService.updateTodoItems(items: fileCache.tasks) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    print("update ok")
                    self.isDirty = false
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func fetchTodoItems() {
        isLoading = true
        networkingService.fetchTodoItems { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let todos):
                    self.fileCache.tasks.forEach { self.fileCache.delete($0) }
                    todos.forEach { self.fileCache.insert($0) }
                    self.update(with: self.currentFilter, sort: self.currentSort)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func save(_ todo: TodoItem) {
        if fileCache.tasks.contains(where: { $0.id == todo.id }) {
            networkingService.editTodoItem(item: todo) { result in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success:
                        print("edit ok")
                    case .failure(let error):
                        print(error)
                        self.isDirty = true
                    }
                }
            }
            update(with: currentFilter, sort: currentSort)
            return
        }
        
        fileCache.insert(todo)
        update(with: currentFilter, sort: currentSort)
        
        guard !isDirty else {
            updateTodoItems()
            return
        }
        
        isLoading = true
        networkingService.addTodoItem(item: todo) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    print("add ok")
                case .failure(let error):
                    print(error)
                    self.isDirty = true
                }
            }
        }
    }
    
    func save(_ category: TodoItem.Category) {
        fileCache.add(category: category)
        categories.append(category)
        fileCache.saveCategories()
    }
    
    func delete(_ todo: TodoItem) {
        fileCache.delete(todo)
        update(with: currentFilter, sort: currentSort)
        
        guard !isDirty else {
            updateTodoItems()
            return
        }
        
        isLoading = true
        networkingService.deleteTodoItem(id: todo.id) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    print("delete ok")
                case .failure(let error):
                    print(error.localizedDescription)
                    self.isDirty = true
                }
            }
        }
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
