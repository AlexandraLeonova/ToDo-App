import SwiftUI

@main
struct ToDoApp: App {
    
    @StateObject private var store = TodoStore()
    
    var body: some Scene {
        WindowGroup {
            TodoListView(todos: $store.todos)
                .environmentObject(store)
        }
    }
}
