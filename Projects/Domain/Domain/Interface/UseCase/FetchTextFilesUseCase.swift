//
//  FetchTextFilesUseCase.swift
//  Domain
//
//  Created by HUNHEE LEE on 24.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//

public protocol FetchTextFilesUseCase {
  func execute() -> AsyncStream<ContentItem>
}
