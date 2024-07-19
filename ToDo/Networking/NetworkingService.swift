protocol NetworkingService {
    func fetchTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func updateTodoItems(items: [TodoItem], completion: @escaping (Result<Void, Error>) -> Void)
    func addTodoItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void)
    func editTodoItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteTodoItem(id: String, completion: @escaping (Result<Void, Error>) -> Void)
    func getTodoItem(id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
}
