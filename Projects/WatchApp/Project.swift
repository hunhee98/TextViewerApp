import ConfigurationPlugin
import DependencyPlugin
import EnvironmentPlugin
import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "\(env.name) WatchApp",
    organizationName: env.organizationName,
    options: .options(
      automaticSchemesOptions: .enabled(
        targetSchemesGrouping: .singleScheme,
        codeCoverageEnabled: false,
        testingOptions: .randomExecutionOrdering,
        testLanguage: nil,
        testRegion: nil,
        testScreenCaptureFormat: nil,
        runLanguage: nil,
        runRegion: nil
      )
    ),
    settings: .settings(base: env.baseSetting.merging(.codeSign)),
    targets: [
      .target(
        name: "TextViewerWatchApp",
        destinations: .watchOS,
        product: .watch2App,
        bundleId: "\(env.organizationName).\(env.name).watchkitapp",
        deploymentTargets: .watchOS("9.0"),
        infoPlist:  .file(path: "Info.plist"),
        resources: ["Resources/**"],
        dependencies: [
          .sdk(name: "WatchConnectivity.framework", type: .framework)
        ],
        settings: .settings(base: env.baseSetting.merging(.codeSign))
      )
    ]
)
