import Foundation
import ProjectDescription

public struct ProjectEnvironment : Sendable {
  public let name: String
  public let organizationName: String
  public let destinations: Destinations
  public let deploymentTargets: DeploymentTargets
  public let baseSetting: SettingsDictionary
}

public let env = ProjectEnvironment(
  name: "TextViewer",
  organizationName: "com.hunhee",
  destinations: [.iPhone],
  deploymentTargets: .iOS("18.0"),
  baseSetting: [:]
)

let forPreview = ProcessInfo.processInfo.environment["TUIST_PREVIEW"]
public let isPreview: Bool = (forPreview == "true")
