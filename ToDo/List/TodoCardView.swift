import SwiftUI

struct TodoCardView: View {
    
    @EnvironmentObject var store: TodoStore
    
    @Binding var todo: TodoItem
    
    @State private var color = TodoItem.Color.default
    
    var body: some View {
        HStack {
            circleView
            
            if todo.importance == .important && !todo.isDone {
                importanceView
            }
            
            VStack(alignment: .leading) {
                textView
                
                if let date = todo.deadline, !todo.isDone {
                    deadlineView(for: date)
                }
            }
            Spacer()
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: todo.color.hex).opacity(todo.color.opacity))
                .frame(width: 5)
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
        .listRowInsets(EdgeInsets())
        .padding(16)
        .lineLimit(3)

    }
    
    var circleView: some View {
        
        let onTap = {
            withAnimation {
                todo = todo.switchIsDone()
                store.save(todo)
            }
        }
        
        if todo.isDone {
            return Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.colorGreen)
                .onTapGesture(perform: onTap)
        } else if todo.importance == .important {
            return Image(systemName: "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.colorRed)
                .onTapGesture(perform: onTap)
        } else {
            return Image(systemName: "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.colorGray)
                .onTapGesture(perform: onTap)
        }
    }
    
    var importanceView: some View {
        Text(Image(systemName: "exclamationmark.2"))
            .fontWeight(.bold)
            .foregroundStyle(.colorRed)
    }
    
    var textView: some View {
        if todo.isDone {
            Text(todo.text).foregroundStyle(.colorGray).strikethrough()
        } else {
            Text(todo.text)
        }
    }

    
    func deadlineView(for date: Date) -> some View {
        HStack {
            Image(systemName: "calendar")
            Text(store.formatted(date: date) ?? "")
        }
        .foregroundStyle(.colorGray)
    }

}
