//
//  ToastAlertModifier.swift
//

import SwiftUI

struct ToastAlertModifier<ContentView: View>: ViewModifier {
  @Binding var isPresented: Bool
  let viewContent: () -> ContentView
  let position: Position
  let animation: Animation
  
  @StateObject var model: ToastAlertModifierModel
  
  init(
    isPresented: Binding<Bool>,
    position: Position,
    animation: Animation,
    duration: Duration?,
    @ViewBuilder viewContent: @escaping () -> ContentView
  ) {
    self._isPresented = isPresented
    self.position = position
    self.animation = animation
    self.viewContent = viewContent
    self._model = .init(
      wrappedValue: .init(
        offset: .zero,
        isTouching: false,
        duration: duration
      )
    )
  }
  
  #if !os(tvOS)
  var dragGesture: some Gesture {
    DragGesture(minimumDistance: 5)
      .onChanged { value in
        model.task?.cancel()
        model.isTouching = true
        model.offset = value.translation
      }
      .onEnded { _ in
        model.isTouching = false
        model.offset = .zero
        model.task = Task {
          await self.model.dismiss {
            isPresented = false
          }
        }
      }
  }
  #endif
  
  func body(content: Content) -> some View {
    content
      .overlay(alignment: position.alignment) {
        if isPresented {
          viewContent()
            .scaleEffect(model.scale)
            .shadow(color: .secondary.opacity(model.shadowOpacity), radius: 10)
            .offset(model.offset)
            #if !os(tvOS)
            .gesture(dragGesture)
            #endif
            .transition(
              .move(edge: position.edge)
              .combined(with: .opacity)
            )
            ._onButtonGesture { pressing in
              model.isTouching = pressing
            } perform: {
              model.task?.cancel()
              isPresented = false
            }
        }
      }
      .animation(animation, value: isPresented)
      .animation(.default, value: model.isTouching)
      .task(id: isPresented) {
        model.task?.cancel()
        guard isPresented else { return }
        model.task = Task {
          await model.dismiss {
            isPresented = false
          }
        }
      }
  }
}

public extension View {
  @ViewBuilder
  func toastAlert<Content: View>(
    isPresented: Binding<Bool>,
    position: Position,
    animation: Animation = .spring(response: 1),
    duration: Duration?,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
      self.modifier(
        ToastAlertModifier(
          isPresented: isPresented,
          position: position,
          animation: animation,
          duration: duration,
          viewContent: content
        )
      )
  }
}

struct ToastAlertModifier_Preview: PreviewProvider {
  struct PencilView: View {
    var body: some View {
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
  }
  
  struct VStack_Preview: View {
    @State var isPresentedTop = false
    @State var isPresentedBottom = false
    
    var body: some View {
      VStack {
        Button("Top Button") {
          isPresentedTop.toggle()
        }
        
        Button("Bottom Button") {
          isPresentedBottom.toggle()
        }
      }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toastAlert(
          isPresented: $isPresentedTop,
          position: .top,
          duration: .seconds(1)
        ) {
          PencilView()
            .frame(maxWidth: 200, maxHeight: 60)
            .toastView()
        }
        .toastAlert(
          isPresented: $isPresentedBottom,
          position: .bottom,
          duration: .seconds(1)
        ) {
          PencilView()
            .frame(maxWidth: 200, maxHeight: 60)
            .toastView()
        }
    }
  }
  
  struct Navigation_Preview: View {
    @State var isPresented = false
    
    var body: some View {
      NavigationStack {
        List {
          Button("Button") {
            isPresented.toggle()
          }
          .buttonStyle(.bordered)
        }
        .listStyle(.plain)
      }
      .toastAlert(
        isPresented: $isPresented,
        position: .top,
        duration: .seconds(2)
      ) {
        PencilView()
          .frame(maxWidth: 200, maxHeight: 60)
          .toastView()
      }
    }
  }
  
  static var previews: some View {
    VStack_Preview()
      .previewDisplayName("VStack")
    
    Navigation_Preview()
      .previewDisplayName("NavigationStack")
  }
}
