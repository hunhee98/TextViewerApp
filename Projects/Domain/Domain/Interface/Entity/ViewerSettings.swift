//
//  ViewerSettings.swift
//  Domain
//
//  Created by HUNHEE LEE on 12.12.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

public struct ViewerSettings: Equatable {
  public let readingMode: ReadingMode
  public let fontSize: Int
  public let lineHeight: Double
  
  public init(
    readingMode: ReadingMode = .scroll,
    fontSize: Int,
    lineHeight: Double
  ) {
    self.readingMode = readingMode
    self.fontSize = fontSize
    self.lineHeight = lineHeight
  }
  
  public var lineSpacing: Double {
    lineHeight * Double(fontSize)
  }
}

public enum ReadingMode: Int, Equatable {
  case scroll = 0
  case page = 1
  
  public var description: String {
    switch self {
    case .scroll: return "스크롤"
    case .page: return "페이지"
    }
  }
}
