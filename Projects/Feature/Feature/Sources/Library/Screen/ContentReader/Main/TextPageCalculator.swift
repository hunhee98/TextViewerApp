//
//  TextPageCalculator.swift
//  Feature
//
//  Created by HUNHEE LEE on 13.12.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import UIKit
import DesignSystem
import SwiftUICore

class TextPageCalculator {
  struct PageConfig {
    let pageSize: CGSize
    let fontSize: CGFloat
    let lineSpacing: CGFloat
    let padding: CGFloat
  }
  
  static func calculatePages(text: String, config: PageConfig) -> [Page] {
    let attributedString = NSAttributedString(
      string: text,
      attributes: [
        .font: UIFont.systemFont(ofSize: config.fontSize),
        .paragraphStyle: {
          let style = NSMutableParagraphStyle()
          style.lineSpacing = config.lineSpacing
          return style
        }()
      ]
    )
    
    let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
    let contentSize = CGSize(
      width: config.pageSize.width - (config.padding * 2),
      height: config.pageSize.height - (config.padding * 2)
    )
    
    var pages: [Page] = []
    var currentPosition = 0
    var pageNumber = 1
    let totalLength = attributedString.length
    
    while currentPosition < totalLength {
      let path = CGPath(
        rect: CGRect(origin: .zero, size: contentSize),
        transform: nil
      )
      
      let frame = CTFramesetterCreateFrame(
        framesetter,
        CFRangeMake(currentPosition, 0),
        path,
        nil
      )
      
      let range = CTFrameGetVisibleStringRange(frame)
      let length = range.length
      
      if length > 0 {
        let pageRange = NSRange(location: currentPosition, length: length)
        let pageText = (attributedString.string as NSString).substring(with: pageRange)
        
        // 빈 페이지 제외
        if !pageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          pages.append(Page(
            pageNumber: pageNumber,
            content: pageText,
            startIndex: currentPosition,
            endIndex: currentPosition + length
          ))
          pageNumber += 1
        }
        
        currentPosition += length
      } else {
        break
      }
    }
    
    return pages
  }
}
