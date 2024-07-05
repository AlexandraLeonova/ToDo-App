import SwiftUI

struct CategoryPicker: View {
    
    @EnvironmentObject var store: TodoStore
    @Binding var selection: TodoItem.Category
    
    var body: some View {
        
        Picker("Категория", selection: $selection) {
            ForEach(store.categories, id: \.name) { category in
                CategoryView(category: category).tag(category)
            }
        }
        .pickerStyle(.navigationLink)
    }
}
