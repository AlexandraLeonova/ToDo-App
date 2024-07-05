import Foundation

private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
private let tasksURL = documentDirectory.appending(path: "tasks").appendingPathExtension("json")
private let categoriesURL = documentDirectory.appending(path: "categories").appendingPathExtension("json")

class FileCache {
    
    private(set) var tasks = [TodoItem]()
    private(set) var categories = [TodoItem.Category]()
    
    func add(task: TodoItem) {
        if tasks.contains(where: { $0.id == task.id }) {
            print("this task already exists!")
            return
        }
        tasks.append(task)
    }
    
    func deleteTask(id: String) {
        tasks.removeAll { $0.id == id }
    }
    
    func saveTasks(to fileURL: URL = tasksURL) {
        if let data = try? JSONSerialization.data(withJSONObject: tasks.map { $0.json }) {
            try? data.write(to: fileURL, options: .noFileProtection)
        }
    }
    
    func loadTasks(from fileURL: URL = tasksURL) {
        if let data = try? Data(contentsOf: fileURL),
           let json = try? JSONSerialization.jsonObject(with: data) as? [Any] {
            tasks = json.compactMap { TodoItem.parse(json: $0) }
        }
    }
    
    func add(category: TodoItem.Category) {
        if categories.contains(where: { $0.name == category.name }) {
            print("this category already exists!")
            return
        }
        categories.append(category)
    }
    
    func saveCategories(to fileURL: URL = categoriesURL) {
        if let data = try? JSONEncoder().encode(categories) {
            try? data.write(to: fileURL, options: .noFileProtection)
        }
    }
    
    func loadCategories(from fileURL: URL = categoriesURL) {
        if let data = try? Data(contentsOf: fileURL),
           let categories = try? JSONDecoder().decode([TodoItem.Category].self, from: data) {
            self.categories = categories
        }
    }
}

