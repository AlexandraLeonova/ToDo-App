import Foundation

private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
private let tasksURL = documentDirectory.appending(path: "tasks").appendingPathExtension("json")

class FileCache {
    
    private(set) var tasks = [TodoItem]()
    
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
}

