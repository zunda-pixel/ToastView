//
//  ToastAlertModifier.swift
//

import SwiftUI

struct ToastAlertModifier<ContentView: View>: ViewModifier {
  @Binding var isPresented: Bool
  let viewContent: ContentView
  let position: Position
  let animation: Animation
  let duration: Duration?
  @State var offset: CGSize = .zero
  @State var isTouching = false
  var shadowOpacity: CGFloat {
    isTouching ? 0.3 : 0
  }
  var scale: CGFloat {
    isTouching ? 1.05 : 1.0
  }
  
  init(
    isPresented: Binding<Bool>,
    position: Position,
    animation: Animation,
    duration: Duration?,
    @ViewBuilder viewContent: () -> ContentView
  ) {
    self._isPresented = isPresented
    self.position = position
    self.animation = animation
    self.duration = duration
    self.viewContent = viewContent()
  }
  
  var dragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        self.isTouching = true
        self.offset = value.translation
      }
      .onEnded { _ in
        withAnimation(.spring()) {
          self.offset = .zero
        }
        self.isTouching = false
      }
  }
  
  func dismiss() async {
    guard let duration else { return }
    try? await Task.sleep(for: duration)
    if offset == .zero, !isTouching {
      isPresented = false
    }
  }
  
  func body(content: Content) -> some View {
    content
      .overlay(alignment: position.alignment) {
        if isPresented {
          viewContent
            .scaleEffect(scale)
            .shadow(color: .secondary.opacity(shadowOpacity), radius: 10)
            .offset(offset)
            .gesture(dragGesture)
            .transition(
              .move(edge: position.edge)
              .combined(with: .opacity)
            )
            ._onButtonGesture { pressing in
              self.isTouching = pressing
            } perform: {
              isPresented = false
            }
            .task(id: isPresented) {
              await dismiss()
            }
            .task(id: offset) {
              if offset == .zero {
                await dismiss()
              }
            }
        }
      }
      .animation(animation, value: isPresented)
      .animation(.default, value: isTouching)
      .onChange(of: isPresented) { newValue in
        if !newValue {
          offset = .zero
        }
      }
  }
}

extension View {
  @ViewBuilder
  func toastAlert<Content: View>(
    isPresented: Binding<Bool>,
    position: Position,
    animation: Animation = .spring(response: 1),
    duration: Duration?,
    @ViewBuilder content: () -> Content
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
          duration: .seconds(2)
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
          .buttonStyle(.borderless)
        }
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
