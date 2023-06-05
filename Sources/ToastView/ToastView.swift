//
//  ToastView.swift
//

import SwiftUI

struct ToastViewModifier: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  
  func body(content: Content) -> some View {
    content
      .background(colorScheme == .dark ? .black : .white)
      .clipShape(Capsule())
      .shadow(
        color: Color.secondary.opacity(0.5),
        radius: 10
      )
  }
}

extension View {
  public func toastView() -> some View {
    self.modifier(ToastViewModifier())
  }
}

struct ToastView_Preview: PreviewProvider {
  struct ApplePencilView: View {
    var body: some View {
      VStack(spacing: 4) {
        Text("Apple Pencil")
          .bold()
        
        Text("\(Text("40%").foregroundColor(.secondary)) \(Image(systemName: "battery.50"))").foregroundColor(.green)
      }
    }
  }
  
  static var previews: some View {
    VStack(spacing: 100) {
      ApplePencilView()
        .frame(maxWidth: 200, maxHeight: 60)
        .toastView()
      
      ApplePencilView()
        .frame(maxWidth: 200, maxHeight: 60)
        .toastView()
    }
    .padding(10)
  }
}
