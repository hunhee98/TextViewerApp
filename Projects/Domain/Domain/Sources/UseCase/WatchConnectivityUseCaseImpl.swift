import Foundation
import Combine
import DomainInterface

public final class WatchConnectivityUseCaseImpl: WatchConnectivityUseCase {
  private let repository: WatchConnectivityInterface
  
  public init(repository: WatchConnectivityInterface) {
    self.repository = repository
  }
  
  public var isWatchAppInstalled: Bool {
    repository.isWatchAppInstalled
  }
  
  public var messagePublisher: PassthroughSubject<WatchMessage.Message, Never> {
    return repository.messagePublisher
  }
  
  public func sendTextFileToWatch(fileName: String, content: String) throws {
    guard !fileName.isEmpty, !content.isEmpty else {
        throw WatchConnectivityError.invalidContent
    }
    
    try repository.sendFileToWatch(fileName: fileName, content: content)
  }
}

public enum WatchConnectivityError: Error {
  case invalidContent
}
