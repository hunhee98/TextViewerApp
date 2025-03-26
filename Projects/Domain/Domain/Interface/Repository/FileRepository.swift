//
//  FileRepository.swift
//  DomainInterface
//
//  Created by HUNHEE LEE on 27.08.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import Foundation

public protocol FileRepository {
  func createDirectory(
    name: String,
    at path: String
  ) throws
  
  func saveFile(
    file: Data,
    at fileName: String
  ) throws
  
  func deleteFile(at path: String) throws
  func renameFile(at path: String, newName: String) throws
  func listFiles(at path: String) throws -> [FileInfo]
  func listTextFilesRecursivelyAsync(at path: String) -> AsyncStream<FileInfo>
}

public enum FileRepositoryError: Error {
  case directoryAlreadyExists
  case fileAlreadyExists
  case fileDoesNotExist(fileName: String)
  case createDirectoryFailed(error: Error)
  case writeFailed(error: Error)
  case deleteFailed(error: Error)
  case listFilesFailed(error: Error)
  case urlEncodingFailed
  case renameFailed(error: Error)

  public var localizedDescription: String {
    switch self {
    case .directoryAlreadyExists:
      return "A directory with the same name already exists."
    case .fileAlreadyExists:
      return "A file with the same name already exists."
    case let .fileDoesNotExist(fileName):
      return "File not found: \(fileName)"
    case let .createDirectoryFailed(error):
      return "Failed to create directory: \(error.localizedDescription)"
    case let .writeFailed(error):
      return "Failed to write data to file: \(error.localizedDescription)"
    case let .deleteFailed(error):
      return "Failed to delete file: \(error.localizedDescription)"
    case let .listFilesFailed(error):
      return "Failed to list files: \(error.localizedDescription)"
    case .urlEncodingFailed:
      return "URL encoding failed for an unknown reason."
    case .renameFailed(let error):
      return "Failed to rename file: \(error.localizedDescription)"
    }
  }
}

extension FileRepositoryError: Equatable {
  public static func == (
    lhs: FileRepositoryError,
    rhs: FileRepositoryError
  ) -> Bool {
    switch (lhs, rhs) {
    case let (.fileDoesNotExist(lhsName), .fileDoesNotExist(rhsName)):
      return lhsName == rhsName
    case let (
      .createDirectoryFailed(lhsError), .createDirectoryFailed(rhsError)
    ),
      let (.writeFailed(lhsError), .writeFailed(rhsError)),
      let (.deleteFailed(lhsError), .deleteFailed(rhsError)),
      let (.listFilesFailed(lhsError), .listFilesFailed(rhsError)),
      let (.renameFailed(lhsError), .renameFailed(rhsError)):
      return (lhsError as NSError) == (rhsError as NSError)
    default:
      return false
    }
  }
}
