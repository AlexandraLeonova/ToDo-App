import CocoaLumberjackSwift
import Foundation
import SwiftData

private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
private let categoriesURL = documentDirectory.appending(path: "categories").appendingPathExtension("json")

class FileCache {
    
    let context = ModelContext(try! ModelContainer(for: TodoItem.self))
    
    init() {
        DDLog.add(DDOSLogger.sharedInstance)
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
    
    private(set) var tasks = [TodoItem]()
    private(set) var categories = [TodoItem.Category]()
    
    func insert(_ todoItem: TodoItem) {
        if tasks.contains(where: { $0.id == todoItem.id }) {
            print("this task already exists!")
            return
        }
        
        context.insert(todoItem)
        tasks.append(todoItem)
    }
    
    func fetch() {
        let descriptor = FetchDescriptor<TodoItem>(sortBy: [])
        do {
            tasks = try context.fetch(descriptor)
            DDLogInfo("fetched tasks")
        } catch {
            DDLogError(error.localizedDescription)
        }
    }
    
    func delete(_ todoItem: TodoItem) {
        tasks.removeAll { $0.id == todoItem.id }
        context.delete(todoItem)
    }
    
    func update(_ todoItem: TodoItem) {
        context.insert(todoItem)
        tasks.removeAll { $0.id == todoItem.id }
        tasks.append(todoItem)
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

