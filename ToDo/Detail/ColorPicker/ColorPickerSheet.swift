//
//  ColorPickerSheet.swift
//  ToDo
//
//  Created by Sandra Leoni on 28.06.2024.
//

import SwiftUI

struct ColorPickerSheet: View {
    
    @Binding var color: TodoItem.Color
    @State var initialColor: TodoItem.Color
    @Binding var isPresentingColorPicker: Bool
    
    var body: some View {
        NavigationStack {
            ColorPickerView(color: $color)
                .navigationTitle("Выбор цвета")
                .toolbarTitleDisplayMode(.inline)
                .interactiveDismissDisabled()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отменить") {
                            isPresentingColorPicker = false
                            withAnimation {
                                color = initialColor
                            }
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Сохранить") {
                            isPresentingColorPicker = false
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Text("Прозрачность")
                            Slider(value: $color.opacity, in: 0...1)
                        }
                    }
                }
        }
    }
}
