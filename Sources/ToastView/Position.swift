//
//  Position.swift
//

import SwiftUI

public enum Position {
  case top
  case bottom
  
  var alignment: Alignment {
    switch self {
    case .top: return .top
    case .bottom: return .bottom
    }
  }
  
  var edge: Edge {
    switch self {
    case .top: return .top
    case .bottom: return .bottom
    }
  }
}
