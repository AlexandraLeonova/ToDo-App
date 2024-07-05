import SwiftUI

struct TodoView: View {
    
    let onSave: (() -> Void)?
    let onDelete: (() -> Void)?
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass


    @EnvironmentObject var store: TodoStore
    
    @State private var text: String
    @State private var deadline: Date
    @State private var importance: TodoItem.Importance
    @State private var color: TodoItem.Color
    @State private var category: TodoItem.Category

    @FocusState private var isTextFieldFocused: Bool
    @State private var hasDeadline: Bool
    @State private var calendarOpened = true
    @State private var isPresentingColorPicker = false
    
    private let todo: TodoItem?
    
    private let locale = Locale(identifier: "ru_RU")
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }
    
    init(
        todo: TodoItem?,
        onSave: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        
        _text = State(initialValue: todo?.text ?? "")
        _deadline = State(initialValue: (todo?.deadline ?? Calendar.current.date(byAdding: .day, value: 1, to: .now)) ?? .now)
        _importance = State(initialValue: todo?.importance ?? .ordinary)
        _hasDeadline = State(initialValue: todo?.deadline != nil)
        _color = State(initialValue: todo?.color ?? .default)
        _category = State(initialValue: todo?.category ?? .default)
        self.todo = todo
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    var body: some View {
        
        // iPad
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            HStack {
                textFieldSection
                if !isTextFieldFocused {
                    List {
                        choicesSection
                        deleteSection
                    }
                }
            }
            .navigationTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButtonView
                }
                ToolbarItem(placement: .confirmationAction) {
                    doneButtonView
                }
            }
        } else {
            NavigationStack {
                
                // Portait iPhone
                if verticalSizeClass == .regular {
                    List {
                        textFieldSection
                        choicesSection
                        deleteSection
                    }
                    
                    .navigationTitle("Дело")
                    .navigationBarTitleDisplayMode(.inline)
                    .scrollDismissesKeyboard(.interactively)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            cancelButtonView
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            doneButtonView
                        }
                    }
                } else {
                    HStack {
                        textFieldSection
                        if !isTextFieldFocused {
                            List {
                                choicesSection
                                deleteSection
                            }
                        }
                    }
                    .navigationTitle("Дело")
                    .navigationBarTitleDisplayMode(.inline)
                    .scrollDismissesKeyboard(.interactively)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            cancelButtonView
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            doneButtonView
                        }
                    }
                    
                }
            }
        }
            
    }
    
    var textFieldSection: some View {
        Section {
            HStack {
                textFieldView
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(hex: color.hex).opacity(color.opacity))
                    .frame(width: 5)
            }
        }
    }
    
    var choicesSection: some View {
        Section {
            importanceChoiceView
            colorChoiceView
            CategoryPicker(selection: $category)
            deadlineChoiceView
        
            if hasDeadline && calendarOpened {
                datePickerView
            }
        }
        .listRowInsets(EdgeInsets())
        .padding(16)
    }
    
    var deleteSection: some View {
        Section {
            HStack {
                Spacer()
                Button("Удалить") {
                    if let id = todo?.id {
                        store.deleteTodo(with: id)
                    }
                    onDelete?()
                    dismiss()
                }
                .tint(Color("Color Red"))
                Spacer()
            }
        }
        .listRowInsets(EdgeInsets())
        .frame(height: 56)
    }
    
    var textFieldView: some View {
        TextField("Что надо сделать?", text: $text, axis: .vertical)
            .focused($isTextFieldFocused)
            .frame(minHeight: 120, alignment: .topLeading)
            .contentShape(.rect)
            .onTapGesture {
                withAnimation {
                    isTextFieldFocused = true
                }
            }
    }
    
    var importanceChoiceView: some View {
        HStack {
            Text("Важность")
            Spacer()
            Picker(selection: $importance) {
                ForEach(TodoItem.Importance.allCases) { importance in
                    switch importance {
                    case .unimportant:
                        Image("ArrowDown").tag(importance)
                    case .ordinary:
                        Text("нет").tag(importance)
                    case .important:
                        Image("ExclamationMark").tag(importance)
                    }
                }
            } label: {}
            .fixedSize()
            .pickerStyle(.segmented)
        }
    }
    
    var colorChoiceView: some View {
        HStack {
            Text("Цвет")
            
            Spacer()
            
            if color != .default  {
                Button {} label: {
                    Text("Сбросить")
                }
                .onTapGesture {
                    color = .default
                }
            }
            
            Button {
                isPresentingColorPicker = true
            } label: {
                Text(color.hex)
                    .padding(4)
                    .background(Color(hex: color.hex).opacity(color.opacity))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .sheet(isPresented: $isPresentingColorPicker) {
            ColorPickerSheet(
                color: $color,
                initialColor: color,
                isPresentingColorPicker: $isPresentingColorPicker
            )
        }
    }
    
    var deadlineChoiceView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Сделать до")
                if hasDeadline {
                    Button(dateFormatter.string(from: deadline)) {
                        withAnimation {
                            calendarOpened.toggle()
                        }
                    }
                }
            }
            Toggle(isOn: $hasDeadline.animation()) {}
        }
    }
    
    var datePickerView: some View {
        DatePicker(selection: $deadline.animation(), displayedComponents: .date) {}
            .datePickerStyle(.graphical)
            .environment(\.locale, locale)
    }
    
    var cancelButtonView: some View {
        Button("Отменить") {
            dismiss()
        }
    }
    
    var doneButtonView: some View {
        Button("Cохранить") {
            if let todo {
                store.save(
                    TodoItem(
                        id: todo.id,
                        text: text,
                        importance: importance,
                        deadline: hasDeadline ? deadline : nil,
                        isDone: todo.isDone,
                        creationDate: todo.creationDate,
                        modifiedDate: .now,
                        color: color,
                        category: category
                    )
                )
            } else {
                store.save(
                    TodoItem(
                        text: text,
                        importance: importance,
                        deadline: hasDeadline ? deadline : nil,
                        color: color,
                        category: category
                    )
                )
            }
            onSave?()
            dismiss()
        }
        .disabled(text.isEmpty)
    }
}
