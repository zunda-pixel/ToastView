//
//  ToastAlertModifierModel.swift
//

import Foundation

class ToastAlertModifierModel: ObservableObject {
  @Published var offset: CGSize
  @Published var isTouching: Bool
  
  var shadowOpacity: CGFloat {
    isTouching ? 0.3 : 0
  }
  var scale: CGFloat {
    isTouching ? 1.05 : 1.0
  }
  
  var task: Task<(), Error>?
  
  init(
    offset: CGSize,
    isTouching: Bool
  ) {
    self.offset = offset
    self.isTouching = isTouching
    self.task = nil
  }
  
  func dismiss(duration: Duration, dismiss: () -> ()) async {
    do {
      try await Task.sleep(for: duration)
      dismiss()
    } catch {
      
    }
  }
}
