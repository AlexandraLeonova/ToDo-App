import SwiftUI

struct TodoListView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @EnvironmentObject var store: TodoStore
    @Binding var todos: [TodoItem]
    @State private var tappedTodo: TodoItem?
    @State var isCreationPresented: Bool = false
    
    var body: some View {
        
        // iPad
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            NavigationSplitView {
                List {
                    Section {
                        ForEach($todos) { $todo in
                            NavigationLink {
                                TodoView(todo: todo)
                            } label: {
                                cardView(for: $todo)
                            }
                        }
                        newButtonView
                    } header: {
                        headerView
                    }
                }
            } detail: {
                TodoView(todo: nil)
            }

        } else {
            NavigationStack {
                List {
                    Section {
                        ForEach($todos) { $todo in
                            tapCardView(for: $todo)
                        }
                        newButtonView
                    } header: {
                        headerView
                    }
                }
                .navigationTitle("Мои дела")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        calendarNavigationLink
                    }
                }
                .overlay {
                    plusButtonView
                }
                .sheet(item: $tappedTodo) { todo in
                    TodoView(todo: tappedTodo)
                }
            }
        }
        
    }
    
    func cardView(for todo: Binding<TodoItem>) -> some View {
        TodoCardView(todo: todo)
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                doneSwipeButtonView(for: todo.wrappedValue)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                deleteSwipeButtonView(for: todo.wrappedValue)
            }
            .swipeActions(edge: .trailing) {
                infoSwipeButtonView(for: todo.wrappedValue)
            }
    }
    
    func tapCardView(for todo: Binding<TodoItem>) -> some View {
        cardView(for: todo)
            .contentShape(.rect)
            .onTapGesture {
                tappedTodo = todo.wrappedValue
            }
    }
    
    var headerView: some View {
        HStack {
            Text("Выполнено - \(store.doneCount)")
                .font(.body)
            Spacer()
            Menu {
                filterButtonView
                sortButtonView
            } label: {
                Text("Фильтр")
            }
        }
        .padding(.bottom, 12)
        .textCase(nil)
    }
    
    
    var plusButtonView: some View {
        Button {
            isCreationPresented = true
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .foregroundStyle(.colorBlue)
                .frame(width: 44, height: 44)
                .background(.colorWhite)
                .clipShape(.circle)
                .shadow(color: .shadowPlus, radius: 2, y: 5)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .sheet(isPresented: $isCreationPresented) {
            TodoView(todo: nil)
        }
    }

    var sortButtonView: some View {
        if store.currentSort == .importance {
            Button {
                withAnimation {
                    store.update(with: store.currentFilter, sort: .date)
                }
            } label: {
                Label {
                    Text("Cортировать по дате")
                } icon: {
                    Image(systemName: "calendar")
                }
            }
        } else {
            Button() {
                withAnimation {
                    store.update(with: store.currentFilter, sort: .importance)
                }
            } label: {
                Label {
                    Text("Сортировать по важности")
                } icon: {
                    Image(systemName: "exclamationmark.2")
                }
            }
        }
    }
    
    var filterButtonView: some View {
        if store.currentFilter == .disable {
            Button {
                withAnimation {
                    store.update(with: .isDone, sort: store.currentSort)
                }
            } label: {
                Label {
                    Text("Скрыть выполненные")
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
        } else {
            Button() {
                withAnimation {
                    store.update(with: .disable, sort: store.currentSort)
                }
            } label: {
                Label {
                    Text("Показать выполненные")
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
        }
    }
    
    var newButtonView: some View {
        Button("Новое") {
            isCreationPresented = true
        }
        .foregroundStyle(.colorGray)
        .frame(height: 56)
        .listRowInsets(EdgeInsets())
        .padding(.leading, 35)
    }
    
    func deleteSwipeButtonView(for todo: TodoItem) -> some View {
        Button {
            withAnimation {
                store.deleteTodo(with: todo.id)
            }
        } label: {
            Label("Удалить", systemImage: "trash.fill")
                .tint(.colorRed)
        }
    }
    
    func infoSwipeButtonView(for todo: TodoItem) -> some View {
        Button {
            print(todo)
        } label: {
            Label("Инфо", systemImage: "info.circle")
        }
    }
    
    func doneSwipeButtonView(for todo: TodoItem) -> some View {
        Button {
            withAnimation {
                store.save(todo.switchIsDone())
            }
        } label: {
            Label("Выполнено", systemImage: "checkmark.circle.fill")
                .tint(.colorGreen)
        }
    }
    
    var calendarNavigationLink: some View {
        NavigationLink {
            CalendarViewControllerRepresentable(store: store)
                .ignoresSafeArea()
                .toolbarTitleDisplayMode(.inline)
                .navigationTitle("Календарь дел")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        NavigationLink {
                            CategoryCreationViewControllerRepresentable(store: store)
                                .ignoresSafeArea()
                                .toolbarTitleDisplayMode(.inline)
                                .navigationTitle("Создание категории")
                        } label: {
                            Image(systemName: "wand.and.stars")
                        }
                    }
                }
        } label: {
            Image(systemName: "calendar")
                .tint(.colorRed)
        }
    }
}
