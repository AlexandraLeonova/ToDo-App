import SwiftUI

struct CalendarViewControllerRepresentable: UIViewControllerRepresentable {
    
    let store: TodoStore
   
    func makeUIViewController(context: Context) -> UIViewController {
        CalendarViewController(store: store)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}


struct CategoryCreationViewControllerRepresentable: UIViewControllerRepresentable {
    
    let store: TodoStore
    
    func makeUIViewController(context: Context) -> UIViewController {
        CategoryCreationTableViewController(store: store)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

