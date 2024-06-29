//
//  ColorPickerView.swift
//  ToDo
//
//  Created by Sandra Leoni on 28.06.2024.
//

import SwiftUI

struct ColorPickerView: View {
    let radius: CGFloat = 150
    var diameter: CGFloat {
        radius * 2
    }
    
    @State private var startLocation: CGPoint?
    @State private var location: CGPoint?
    @Binding var color: TodoItem.Color
        
    var body: some View {
        ZStack {
            
            if let startLocation {
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(
                                colors: [
                                    Color(hue: 1.0, saturation: 1, brightness: 0.9),
                                    Color(hue: 0.9, saturation: 1, brightness: 0.9),
                                    Color(hue: 0.8, saturation: 1, brightness: 0.9),
                                    Color(hue: 0.7, saturation: 1, brightness: 0.9),
                                    Color(hue: 0.6, saturation: 1, brightness: 0.9),
                                    Color(hue: 0.4, saturation: 1, brightness: 0.9),
                                    Color(hue: 0.3, saturation: 1, brightness: 0.9),
                                    Color(hue: 0.2, saturation: 1, brightness: 0.9),
                                    Color(hue: 0.1, saturation: 1, brightness: 0.9),
                                    Color(hue: 0.0, saturation: 1, brightness: 0.9)
                                ]), center: .center)
                        )
                    .frame(width: diameter, height: diameter)
                    .overlay(
                        Circle()
                            .fill(
                            RadialGradient(gradient: Gradient(colors: [
                                Color.white, Color.white.opacity(0.000001)
                            ]), center: .center, startRadius: 0, endRadius: radius)
                            )
                        )
                    .position(startLocation)
                    .shadow(color: Color.black.opacity(0.1), radius: 6, y: 8)
                
                Circle()
                    .frame(width: 50, height: 50)
                    .position(location!)
                    .foregroundStyle(Color.black)
            } else {
                Text("Нажмите на экран, чтобы выбрать цвет")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: color.hex).opacity(color.opacity))
        .gesture(dragGesture)
        .ignoresSafeArea()
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if startLocation == nil {
                    startLocation = value.location
                }
                
                let xDistance = value.location.x - startLocation!.x
                let yDistance = value.location.y - startLocation!.y

                let dir = CGPoint(x: xDistance, y: yDistance)
                var distance = sqrt(xDistance * xDistance + yDistance * yDistance)
                
                if distance < radius {
                    location = value.location
                } else {
                    let clampedX = dir.x / distance * radius
                    let clampedY = dir.y / distance * radius
                    location = CGPoint(x: startLocation!.x + clampedX, y: startLocation!.y + clampedY)
                    distance = radius
                }
                if distance == 0 { return }
                
                var angle = Angle(radians: -Double(atan(dir.y / dir.x)))
                if dir.x < 0 {
                    angle.degrees += 180
                } else if dir.x > 0 && dir.y > 0 {
                    angle.degrees += 360
                }
                
                let hue = angle.degrees / 360
                let saturation = Double(distance / radius)
                color = .init(
                    hex: Color(hue: hue, saturation: saturation, brightness: 0.7).hex,
                    opacity: color.opacity
                )
            }
            .onEnded { value in
                startLocation = nil
                location = nil
            }
    }
    
}
