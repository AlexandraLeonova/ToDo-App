import CocoaLumberjackSwift
import Foundation

private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
private let tasksURL = documentDirectory.appending(path: "tasks").appendingPathExtension("json")
private let categoriesURL = documentDirectory.appending(path: "categories").appendingPathExtension("json")

class FileCache {
    
    init() {
        DDLog.add(DDOSLogger.sharedInstance)
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
    
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
        do {
            let data = try JSONSerialization.data(withJSONObject: tasks.map { $0.json })
            try data.write(to: fileURL, options: .noFileProtection)
            DDLogInfo("saved tasks at \(fileURL)")
        } catch {
            DDLogError(error.localizedDescription)
        }
    }
    
    func loadTasks(from fileURL: URL = tasksURL) {
        do {
            let data = try Data(contentsOf: fileURL)
            if let json = try JSONSerialization.jsonObject(with: data) as? [Any] {
                tasks = json.compactMap { TodoItem.parse(json: $0) }
                DDLogInfo("loaded tasks from \(fileURL)")
            }
        } catch {
            DDLogError(error.localizedDescription)
        }
    }
    
    func add(category: TodoItem.Category) {
        if categories.contains(where: { $0.name == category.name }) {
            DDLogWarn("this category already exists!")
            return
        }
        categories.append(category)
    }
    
    func saveCategories(to fileURL: URL = categoriesURL) {
        do {
            let data = try JSONEncoder().encode(categories)
            try data.write(to: fileURL, options: .noFileProtection)
            DDLogInfo("saved categories at \(fileURL)")
        } catch {
            DDLogError(error.localizedDescription)
        }
    }
    
    func loadCategories(from fileURL: URL = categoriesURL) {
        do {
            let data = try Data(contentsOf: fileURL)
            let categories = try JSONDecoder().decode([TodoItem.Category].self, from: data)
            self.categories = categories
            DDLogInfo("loaded categories from \(fileURL)")
        } catch {
            DDLogError(error.localizedDescription)
        }
    }
}

