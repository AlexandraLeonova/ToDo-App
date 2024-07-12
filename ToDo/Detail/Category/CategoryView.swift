import Extensions
import SwiftUI

struct CategoryView: View {
    
    let category: TodoItem.Category

    var body: some View {
      
        Text(category.name)
            .padding(4)
            .background(Color(hex: category.color.hex))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        
    }
}




#Preview {
    CategoryView(category: .default)
}
