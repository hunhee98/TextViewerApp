//
//  WatchMessage.swift
//  Domain
//
//  Created by HUNHEE LEE on 24.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//

public enum WatchMessage: Equatable {
  public enum Message: Equatable {
    case text(String)
    case fileRequest
    case fileResponse(success: Bool)
    
    public var dictionary: [String: Any] {
      switch self {
      case .text(let content):
        return ["type": "text", "content": content]
      case .fileRequest:
        return ["type": "fileRequest"]
      case .fileResponse(let success):
        return ["type": "fileResponse", "success": success]
      }
    }
    
    public static func parse(_ dictionary: [String: Any]) -> Message? {
      guard let type = dictionary["type"] as? String else { return nil }
      
      switch type {
      case "text":
        if let content = dictionary["content"] as? String {
          return .text(content)
        }
      case "fileRequest":
        return .fileRequest
      case "fileResponse":
        if let success = dictionary["success"] as? Bool {
          return .fileResponse(success: success)
        }
      default:
        return nil
      }
      return nil
    }
    
    public static func == (lhs: Message, rhs: Message) -> Bool {
      switch (lhs, rhs) {
      case let (.text(lhsContent), .text(rhsContent)):
        return lhsContent == rhsContent
      case (.fileRequest, .fileRequest):
        return true
      case let (.fileResponse(lhsSuccess), .fileResponse(rhsSuccess)):
        return lhsSuccess == rhsSuccess
      default:
        return false
      }
    }
  }
}
