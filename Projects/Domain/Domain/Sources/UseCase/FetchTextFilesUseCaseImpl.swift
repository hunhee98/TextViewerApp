//
//  FetchTextFilesUseCaseImpl.swift
//  Domain
//
//  Created by HUNHEE LEE on 24.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//

import DomainInterface

public struct FetchTextFilesUseCaseImpl: FetchTextFilesUseCase {
  private let repository: FileRepository
  
  public init(repository: FileRepository) {
    self.repository = repository
  }
  
  public func execute() -> AsyncStream<ContentItem> {
    return AsyncStream { continuation in
      let task = Task {
        for await fileInfo in repository.listTextFilesRecursivelyAsync(at: "") {
          if let domainItem = fileInfo.todomain(),
             let contentItem = domainItem as? ContentItem {
            continuation.yield(contentItem)
          }
        }
        continuation.finish()
      }
      
      continuation.onTermination = { _ in
        task.cancel()
      }
    }
  }
}
