import Foundation
import WatchConnectivity

extension WCSession {
  func sendMessageAsync(_ message: [String: Any]) async throws -> [String: Any] {
    try await withCheckedThrowingContinuation { continuation in
      sendMessage(message) { reply in
        continuation.resume(returning: reply)
      } errorHandler: { error in
        continuation.resume(throwing: error)
      }
    }
  }
}
