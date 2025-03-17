//
//  PageCurlView.swift
//  Feature
//
//  Created by HUNHEE LEE on 14.12.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import SwiftUI
import UIKit
import DesignSystem

public struct PageCurlView<Page: View>: UIViewControllerRepresentable {
  let pages: [Page]
  @Binding var currentPage: Int
  private var transitionStartAction: ((Int) -> Void)?
  
  init(
    _ pages: [Page],
    currentPage: Binding<Int>
  ) {
    self.pages = pages
    self._currentPage = currentPage
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  public func makeUIViewController(context: Context) -> UIPageViewController {
    let pageViewController = UIPageViewController(
      transitionStyle: .pageCurl,
      navigationOrientation: .horizontal
    )
    
    pageViewController.dataSource = context.coordinator
    pageViewController.delegate = context.coordinator
    
    pageViewController.setViewControllers(
      [context.coordinator.controllers[currentPage]],
      direction: .forward,
      animated: false
    )
    
    return pageViewController
  }
  
  public func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
    context.coordinator.update(transitionStartAction: transitionStartAction)
    
    if let currentViewController = uiViewController.viewControllers?.first,
       let currentIndex = context.coordinator.controllers.firstIndex(of: currentViewController),
       currentIndex != currentPage {
      uiViewController.setViewControllers(
        [context.coordinator.controllers[currentPage]],
        direction: .forward,
        animated: true
      )
    }
  }
  
  public class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var parent: PageCurlView
    var controllers: [UIViewController] = [UIViewController]()
    private var transitionStartAction: ((Int) -> Void)?
    
    init(
      _ pageCurlView: PageCurlView
    ) {
      self.parent = pageCurlView
      self.transitionStartAction = pageCurlView.transitionStartAction
      super.init()
      
      controllers = parent.pages.map { page in
        let hostingController = UIHostingController(
          rootView: page
            .frame(alignment: .leading)
        )
        hostingController.view.backgroundColor = AppColor.appWhite.color
        return hostingController
      }
    }
    
    func update(transitionStartAction: ((Int) -> Void)?) {
      self.transitionStartAction = transitionStartAction
    }
    
    public func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
      guard let index = controllers.firstIndex(of: viewController) else { return nil }
      if index == 0 { return nil }
      return controllers[index - 1]
    }
    
    public func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
      guard let index = controllers.firstIndex(of: viewController) else { return nil }
      if index + 1 >= controllers.count { return nil }
      return controllers[index + 1]
    }
    
    public func pageViewController(
      _ pageViewController: UIPageViewController,
      willTransitionTo pendingViewControllers: [UIViewController]
    ) {
      if let viewController = pendingViewControllers.first,
         let index = controllers.firstIndex(of: viewController) {
        transitionStartAction?(index)
      }
    }
    
    public func pageViewController(
      _ pageViewController: UIPageViewController,
      didFinishAnimating finished: Bool,
      previousViewControllers: [UIViewController],
      transitionCompleted completed: Bool
    ) {
      if completed,
         let visibleViewController = pageViewController.viewControllers?.first,
         let index = controllers.firstIndex(of: visibleViewController) {
        parent.currentPage = index
      }
    }
  }
  
  public func onPageTransitionStart(perform action: @escaping (Int) -> Void) -> PageCurlView {
    var view = self
    view.transitionStartAction = action
    return view
  }
}
