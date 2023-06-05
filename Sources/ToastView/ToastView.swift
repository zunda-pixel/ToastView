//
//  ToastView.swift
//

import SwiftUI

extension View {
  public func toastView() -> some View {
    self
      .background(Color.systemBackground)
      .clipShape(Capsule())
      .shadow(
        color: Color.secondary.opacity(0.5),
        radius: 10
      )
  }
}

private extension Color {
#if os(macOS)
  static let systemBackground = Color(nsColor: .controlBackgroundColor)
#else
  static let systemBackground = Color(uiColor: .systemBackground)
#endif
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
    .padding(100)
  }
}
