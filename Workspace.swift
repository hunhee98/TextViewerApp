//
//  Workspace.swift
//  Packages
//
//  Created by HUNHEE LEE on 12.08.2024.
//

import EnvironmentPlugin
import ProjectDescription

let workspace = Workspace(
  name: env.name,
  projects: [
    "Projects/App"
  ]
)
