//
//  FolderItem.swift
//  Domain
//
//  Created by HUNHEE LEE on 26.08.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import Foundation

public struct FolderItem: LibraryItem {
  public var id: UUID = UUID()
  
  public var name: String
  public let createdDate: Date
  public let subfilesCount: Int
  public let type: LibraryItemType = .folder
  public let path: String

  public init(
    name: String,
    createdDate: Date,
    subfilesCount: Int,
    path: String
  ) {
    self.name = name
    self.createdDate = createdDate
    self.subfilesCount = subfilesCount
    self.path = path
  }
  
  public static func == (lhs: FolderItem, rhs: FolderItem) -> Bool {
    return lhs.name == rhs.name &&
    lhs.createdDate == rhs.createdDate &&
    lhs.subfilesCount == rhs.subfilesCount &&
    lhs.path == rhs.path
  }
}
