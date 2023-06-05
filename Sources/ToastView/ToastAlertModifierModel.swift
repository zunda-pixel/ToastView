//
//  ToastAlertModifierModel.swift
//

import Foundation

class ToastAlertModifierModel: ObservableObject {
  @Published var offset: CGSize
  @Published var isTouching: Bool
  let duration: Duration?
  
  var shadowOpacity: CGFloat {
    isTouching ? 0.3 : 0
  }
  var scale: CGFloat {
    isTouching ? 1.05 : 1.0
  }
  
  var task: Task<(), Error>?
  
  init(
    offset: CGSize,
    isTouching: Bool,
    duration: Duration?
  ) {
    self.offset = offset
    self.isTouching = isTouching
    self.duration = duration
    self.task = nil
  }
  
  func dismiss(dismiss: () -> ()) async {
    guard let duration else {
      dismiss()
      return
    }
    do {
      try await Task.sleep(for: duration)
      dismiss()
    } catch {
      
    }
  }
}
