//
//  ToDoTests.swift
//  ToDoTests
//
//  Created by Александра Леонова on 19.06.2024.
//

import XCTest
@testable import ToDo

final class TodoItemTests: XCTestCase {
    
    func testFullJSON() throws {
        let now = Date.now
        let todo = TodoItem(
            id: "id",
            text: "text",
            importance: .important,
            deadline: now,
            isDone: true,
            creationDate: now,
            modifiedDate: now
        )
        
        let json = try XCTUnwrap(todo.json as? [String: Any])
        let id = try XCTUnwrap(json["id"] as? String)
        let text = try XCTUnwrap(json["text"] as? String)
        let importance = try XCTUnwrap(json["importance"] as? String)
        let deadline = try XCTUnwrap(json["deadline"] as? String)
        let isDone = try XCTUnwrap(json["isDone"] as? Bool)
        let creationDate = try XCTUnwrap(json["creationDate"] as? String)
        let modifiedDate = try XCTUnwrap(json["modifiedDate"] as? String)
        
        XCTAssertEqual(id, todo.id)
        XCTAssertEqual(text, todo.text)
        XCTAssertEqual(importance, todo.importance.rawValue)
        XCTAssertEqual(deadline, todo.deadline?.ISO8601Format())
        XCTAssertEqual(isDone, todo.isDone)
        XCTAssertEqual(creationDate, todo.creationDate.ISO8601Format())
        XCTAssertEqual(modifiedDate, todo.modifiedDate?.ISO8601Format())
    }
    
    func testFullParse() throws {
        let now = Date.now
        let json = [
            "id": "id",
            "text": "text",
            "importance": "important",
            "deadline": now.ISO8601Format(),
            "isDone": true,
            "creationDate": now.ISO8601Format(),
            "modifiedDate": now.ISO8601Format(),
            "colorHex": "#FEFEFE",
            "colorOpacity": 1.0
        ] as [String : Any]
        
        let todo = try XCTUnwrap(TodoItem.parse(json: json))
        
        XCTAssertEqual(todo.id, "id")
        XCTAssertEqual(todo.text, "text")
        XCTAssertEqual(todo.importance, .important)
        XCTAssertEqual(todo.deadline?.ISO8601Format(), now.ISO8601Format())
        XCTAssertEqual(todo.creationDate.ISO8601Format(), now.ISO8601Format())
        XCTAssertEqual(todo.modifiedDate?.ISO8601Format(), now.ISO8601Format())
        XCTAssertEqual(todo.color, .init(hex: "#FEFEFE", opacity: 1.0))
    }

    func testParseWrongCreationDate() {
        let dict: [String: Any] = [
            "id": "id",
            "text": "text",
            "isDone": true,
            "creationDate": "1"
        ]
        XCTAssertNil(TodoItem.parse(json: dict))
    }
    
    func testParseWrongJSON() {
        let dict = "1"
        XCTAssertNil(TodoItem.parse(json: dict))
    }
    
    func testParseFullCSV() {
        let now = Date.now
        
        let todo = TodoItem.parse(csv: """
        modifiedDate,id,deadline,isDone,creationDate,text,importance
        \(now.ISO8601Format()),id,\(now.ISO8601Format()),false,\(now.ISO8601Format()),text,important
        """)[0]
        
        XCTAssertEqual(todo.id, "id")
        XCTAssertEqual(todo.text, "text")
        XCTAssertEqual(todo.importance, .important)
        XCTAssertEqual(todo.deadline?.ISO8601Format(), now.ISO8601Format())
        XCTAssertEqual(todo.creationDate.ISO8601Format(), now.ISO8601Format())
        XCTAssertEqual(todo.modifiedDate?.ISO8601Format(), now.ISO8601Format())
    }
}
