//
//  ToastItemAlertModifier.swift
//

import SwiftUI

struct ToastItemAlertModifier<Item: Equatable, ContentView: View>: ViewModifier {
  @State var isPresented: Bool
  @Binding var item: Item?
  let viewContent: (Item) -> ContentView
  let position: Position
  let animation: Animation
  let duration: Duration?
  
  @StateObject var model: ToastAlertModifierModel
  
  init(
    item: Binding<Item?>,
    position: Position,
    animation: Animation,
    duration: Duration?,
    @ViewBuilder viewContent: @escaping (Item) -> ContentView
  ) {
    self._item = item
    self._isPresented = .init(wrappedValue: item.wrappedValue != nil)
    self.position = position
    self.animation = animation
    self.duration = duration
    self.viewContent = viewContent
    self._model = .init(
      wrappedValue: .init(
        offset: .zero,
        isTouching: false
      )
    )
  }
  
  func dismiss() {
    guard let duration else { return }
    
    model.task = Task {
      await self.model.dismiss(duration: duration) {
        isPresented = false
      }
    }
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
        dismiss()
      }
  }
  #endif
  
  func body(content: Content) -> some View {
    content
      .onChange(of: item) { newItem in
        isPresented = newItem != nil
      }
      .overlay(alignment: position.alignment) {
        if let item, isPresented {
          viewContent(item)
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
        dismiss()
      }
  }
}

public extension View {
  @ViewBuilder
  func toastAlert<Item: Equatable, Content: View>(
    item: Binding<Item?>,
    position: Position,
    animation: Animation = .spring(response: 1),
    duration: Duration?,
    @ViewBuilder content: @escaping (Item) -> Content
  ) -> some View {
      self.modifier(
        ToastItemAlertModifier(
          item: item,
          position: position,
          animation: animation,
          duration: duration,
          viewContent: content
        )
      )
  }
}

struct ToastItemAlertModifier_Preview: PreviewProvider {
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
    @State var topDate: Date?
    @State var bottomDate: Date?

    var body: some View {
      VStack {
        Button("Top Button") {
          topDate = Date.now
        }

        Button("Bottom Button") {
          bottomDate = Date.now
        }
      }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toastAlert(
          item: $topDate,
          position: .top,
          duration: .seconds(1)
        ) { date in
          Text(date, format: .dateTime)
            .frame(maxWidth: 200, maxHeight: 60)
            .toastView()
        }
        .toastAlert(
          item: $bottomDate,
          position: .bottom,
          duration: .seconds(1)
        ) { date in
          Text(date, format: .dateTime)
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
          .buttonStyle(.automatic)
        }
      }
      .toastAlert(
        isPresented: $isPresented,
        position: .top,
        duration: nil
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
