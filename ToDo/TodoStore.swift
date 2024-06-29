//
//  TodoStore.swift
//  ToDo
//
//  Created by Sandra Leoni on 29.06.2024.
//

import SwiftUI

class TodoStore: ObservableObject {
    
    @Published var todos: [TodoItem] = []
    
    private let fileCache = FileCache()
    
    init() {
        fileCache.loadTasks()
        update(with: currentFilter, sort: currentSort)
    }
    
    func save(_ todo: TodoItem) {
        fileCache.deleteTask(id: todo.id)
        fileCache.add(task: todo)
        update(with: currentFilter, sort: currentSort)
        fileCache.saveTasks()
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
        switch filter {
        case .disable:
            break
        case .isDone:
            todos = todos.filter { !$0.isDone }
        }
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
