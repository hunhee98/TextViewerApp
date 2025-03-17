import ProjectDescription

public extension SettingsDictionary {
  static let codeSign = SettingsDictionary()
        .codeSignIdentityAppleDevelopment()
        .automaticCodeSigning(devTeam: "HL89CPH3NA")
}
