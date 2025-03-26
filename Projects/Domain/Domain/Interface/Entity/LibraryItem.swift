//
//  LibraryItem.swift
//  Feature
//
//  Created by HUNHEE LEE on 26.08.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import Foundation

/// LibraryItem(Folder, Conetnt)에 공통적인 요구사항을 정의한 Protocol이에요.
public protocol LibraryItem: Hashable, Identifiable {
  var name: String { get }
  var createdDate: Date { get }
  var type: LibraryItemType { get }
  var path: String { get }
}

/// LibraryItem의 유형을 정의한 열거형이에요.
public enum LibraryItemType: Hashable {
  case content(ContentItemType)
  case folder
}

/// ContentItem의 유형을 정의한 열거형이에요.
///
/// __txt__ 텍스트 파일
public enum ContentItemType: String, Hashable {
  case txt
}
