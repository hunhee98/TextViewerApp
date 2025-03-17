//
//  AppFont.swift
//  DesignSystem
//
//  Created by HUNHEE LEE on 26.08.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import SwiftUI

public enum AppFont {
  case pretendard(Pretendard)
  case ridiBatang
  
  public func of(size: CGFloat) -> Font {
    switch self {
    case .pretendard(let pretendard):
      return pretendard.fontFamily.swiftUIFont(size: size)
    case .ridiBatang:
      return DesignSystemFontFamily.RIDIBatang.regular.swiftUIFont(size: size)
    }
  }
  
  public func uiFont(size: CGFloat) -> UIFont {
    switch self {
    case .pretendard(let pretendard):
      return pretendard.fontFamily.font(size: size)
    case .ridiBatang:
      return DesignSystemFontFamily.RIDIBatang.regular.font(size: size)
    }
  }
}

public enum Pretendard: String, CaseIterable {
  case black
  case bold
  case extraBold
  case light
  case extraLight
  case medium
  case regular
  case semiBold
  case thin
  
  var fontFamily: DesignSystemFontConvertible {
    typealias Pretendard = DesignSystemFontFamily.Pretendard
    switch self {
    case .black:
      return Pretendard.black
    case .bold:
      return Pretendard.bold
    case .extraBold:
      return Pretendard.extraBold
    case .light:
      return Pretendard.light
    case .extraLight:
      return Pretendard.extraLight
    case .medium:
      return Pretendard.medium
    case .regular:
      return Pretendard.regular
    case .semiBold:
      return Pretendard.semiBold
    case .thin:
      return Pretendard.thin
    }
  }
}
