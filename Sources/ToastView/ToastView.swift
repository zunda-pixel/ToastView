//
//  ToastView.swift
//

import SwiftUI

extension View {
  func toastView() -> some View {
    background(Color(uiColor: .systemBackground))
    .clipShape(Capsule())
    .shadow(
      color: Color.secondary.opacity(0.5),
      radius: 10
    )
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
    ApplePencilView()
      .frame(maxWidth: 200, maxHeight: 60)
      .toastView()
      .preferredColorScheme(.light)
      
    ApplePencilView()
      .frame(maxWidth: 200, maxHeight: 60)
      .toastView()
      .preferredColorScheme(.dark)
  }
}
