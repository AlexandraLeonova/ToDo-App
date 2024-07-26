import Foundation

class DefaultNetworkingService: NetworkingService {
    
    private let baseURL = "https://hive.mrdekk.ru/todo"
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var revision: Int?
    
    private enum RequestMethod: String {
        case get, post, patch, put, delete
    }
    
    private enum NetworkError: Error, LocalizedError {
        case badResponse
    }
    
    private struct ListRequestBody: Encodable {
        let status = "ok"
        let list: [NetworkTodoItem]
    }
    
    private struct ListResponseBody: Decodable {
        let status: String
        let list: [NetworkTodoItem]
        let revision: Int
    }
    
    private struct ItemRequestBody: Encodable {
        let status = "ok"
        let element: NetworkTodoItem
    }
    
    private struct ItemResponseBody: Decodable {
        let revision: Int
    }
    
    private func makeRequest(url: URL, method: RequestMethod) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue.uppercased()
        if let token = Bundle.main.object(forInfoDictionaryKey: "Bearer Token") as? String {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.setValue("\(revision ?? 0)", forHTTPHeaderField: "X-Last-Known-Revision")
        return urlRequest
    }
    
    
    func fetchTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        
        guard let url = URL(string: baseURL + "/list") else { return }
        let request = makeRequest(url: url, method: .get)
        
        urlSession.dataTask(with: request) { data, response, error in
            if let error {
                print(error.localizedDescription)
                return completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode != 200 {
                print(response.statusCode)
                return completion(.failure(NetworkError.badResponse))
            }
            
            if let data {
                do {
                    let responseBody = try self.decoder.decode(ListResponseBody.self, from: data)
                    self.revision = responseBody.revision
                    completion(.success(responseBody.list.map { $0.todoItem }))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func updateTodoItems(items: [TodoItem], completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let url = URL(string: baseURL + "/list") else { return }
        var request = makeRequest(url: url, method: .patch)

        let networkTodos = items.map { NetworkTodoItem(todo: $0) }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                request.httpBody = try self.encoder.encode(ListRequestBody(list: networkTodos))
            } catch {
                return completion(.failure(error))
            }
            
            self.urlSession.dataTask(with: request) { data, response, error in
                if let error {
                    return completion(.failure(error))
                }
                
                if let response = response as? HTTPURLResponse,
                    response.statusCode != 200 {
                    print(response.statusCode)
                    return completion(.failure(NetworkError.badResponse))
                }
                
                if let data {
                    do {
                        let responseBody = try self.decoder.decode(ListResponseBody.self, from: data)
                        self.revision = responseBody.revision
                        completion(.success(()))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    func getTodoItem(id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        
        guard let url = URL(string: baseURL + "/list/\(id)") else { return }
        let request = makeRequest(url: url, method: .get)
                
        urlSession.dataTask(with: request) { data, response, error in
            if let error {
                return completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    print(response.statusCode)
                    return completion(.failure(NetworkError.badResponse))
                }
            }
            
            if let data {
                do {
                    let todo = try self.decoder.decode(NetworkTodoItem.self, from: data)
                    completion(.success(todo.todoItem))

                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func addTodoItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let url = URL(string: baseURL + "/list") else { return }
        var request = makeRequest(url: url, method: .post)
        
        let networkTodo = NetworkTodoItem(todo: item)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try self.encoder.encode(ItemRequestBody(element: networkTodo))
                request.httpBody = data
            } catch {
                return completion(.failure(error))
            }
            
            self.urlSession.dataTask(with: request) { data, response, error in
                if let error {
                    return completion(.failure(error))
                }
                
                if let response = response as? HTTPURLResponse,
                   response.statusCode != 200 {
                    print(response.statusCode)
                    return completion(.failure(NetworkError.badResponse))
                }
                
                if let data {
                    do {
                        self.revision = try self.decoder.decode(ItemResponseBody.self, from: data).revision
                        completion(.success(()))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    func editTodoItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let url = URL(string: baseURL + "/list/\(item.id)") else { return }
        var request = makeRequest(url: url, method: .put)

        let networkTodo = NetworkTodoItem(todo: item)
         
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try self.encoder.encode(ItemRequestBody(element: networkTodo))
                request.httpBody = data
            } catch {
                return completion(.failure(error))
            }
            
            self.urlSession.dataTask(with: request) { data, response, error in
                if let error {
                    completion(.failure(error))
                }
                
                if let response = response as? HTTPURLResponse,
                   response.statusCode != 200 {
                    print(response.statusCode)
                    return completion(.failure(NetworkError.badResponse))
                }
                
                if let data {
                    do {
                        self.revision = try self.decoder.decode(ItemResponseBody.self, from: data).revision
                        completion(.success(()))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    func deleteTodoItem(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: baseURL + "/list/\(id)") else { return }
        let request = makeRequest(url: url, method: .delete)

        urlSession.dataTask(with: request) { data, response, error in
            if let error {
                return completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode != 200 {
                print(response.statusCode)
                return completion(.failure(NetworkError.badResponse))
            }
            
            if let data {
                do {
                    self.revision = try self.decoder.decode(ItemResponseBody.self, from: data).revision
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }            
        }.resume()
    }
}
