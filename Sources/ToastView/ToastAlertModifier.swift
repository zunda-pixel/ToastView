//
//  ToastAlertModifier.swift
//

import SwiftUI

struct ToastAlertModifier<ContentView: View>: ViewModifier {
  @Binding var isPresented: Bool
  let viewContent: ContentView
  let position: Position
  let animation: Animation
  
  init(
    isPresented: Binding<Bool>,
    position: Position,
    animation: Animation = .spring(),
    @ViewBuilder viewContent: () -> ContentView
  ) {
    self._isPresented = isPresented
    self.position = position
    self.animation = animation
    self.viewContent = viewContent()
  }
  
  func body(content: Content) -> some View {
    content
      .overlay(alignment: position.alignment) {
        if isPresented {
          viewContent
            .transition(
              .move(edge: position.edge)
              .combined(with: .opacity)
            )
            .onTapGesture {
              isPresented = false
            }
            .task {
              try? await Task.sleep(for: .seconds(2))
              isPresented = false
            }
        }
      }
      .animation(animation, value: isPresented)
  }
}

extension View {
  @ViewBuilder
  func toastAlert<Content: View>(
    isPresented: Binding<Bool>,
    position: Position,
    @ViewBuilder content: () -> Content
  ) -> some View {
      self.modifier(
        ToastAlertModifier(
          isPresented: isPresented,
          position: position,
          viewContent: content
        )
      )
  }
}

struct ToastAlertModifier_Preview: PreviewProvider {
  struct Preview: View {
    let position: Position
    @State var isPresented = false
    
    var pencilView: some View {
      VStack(spacing: 4) {
        Text("Apple Pencil")
          .bold()
        
        HStack {
          Text("40%")
            .foregroundColor(.secondary)

          Image(systemName: "battery.50")
            .foregroundColor(.green)
        }
      }
    }
    
    var body: some View {
      Button("Button") {
        isPresented.toggle()
      }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toastAlert(
          isPresented: $isPresented,
          position: position
        ) {
          pencilView
            .frame(maxWidth: 200, maxHeight: 60)
            .toastView()
        }
    }
  }
  
  static var previews: some View {
    VStack {
      Preview(position: .top)
      Preview(position: .bottom)
    }
  }
}
