//
//  AppDelegate.swift
//  Bare
//
//  Created by Zach Eriksen on 3/27/19.
//  Copyright © 2019 ol. All rights reserved.
//

import UIKit

protocol BuilderView: UIView {
    associatedtype ViewType
    init()
    func with<T>(_ property: ReferenceWritableKeyPath<ViewType, T>, value: T) -> ViewType
    func add(toView view: UIView?) -> ViewType
}

protocol ContainerView: BuilderView {
    init(customView: UIView)
    
    func add(child view: UIView?) -> Self
    func add(children views: UIView...) -> Self
}

class BareView: UIView, BuilderView {
    typealias ViewType = BareView
    
    @discardableResult
    func add(toView view: UIView?) -> Self {
        guard let view = view else { fatalError("View is nil") }
        view.addSubview(self)
        return self
    }
    
    @discardableResult
    func with<T>(_ property: ReferenceWritableKeyPath<ViewType, T>, value: T) -> Self {
        self[keyPath: property] = value
        return self
    }
}

class View: BareView, ContainerView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(customView: UIView) {
        super.init(frame: .zero)
        add(child: customView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    func add(child view: UIView?) -> Self {
        guard let view = view else { fatalError("View is nil") }
        addSubview(view)
        return self
    }

    @discardableResult
    func add(children views: UIView...) -> Self {
        views.forEach { view in addSubview(view) }
        return self
    }
}

class BaseBView: BareView {
    var navigationView: NavigationBView = .view
    var contentView: ContentBView = .view
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        navigationView.add(toView: self)
        contentView.add(toView: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NavigationBView: View {
    static var view: NavigationBView = {
        return NavigationBView()
            .with(\.frame, value: CGRect(origin: .zero,
                                         size: CGSize(width: UIScreen.main.bounds.width,
                                                      height: 60)))
            .with(\.backgroundColor, value: .darkGray)
    }()
}

class ContentBView: View {
    static var view: ContentBView = {
        return ContentBView()
            .with(\.frame, value: CGRect(origin: CGPoint(x: 0, y: 60),
                                         size: CGSize(width: UIScreen.main.bounds.width,
                                                      height: UIScreen.main.bounds.height - 60)))
            .with(\.backgroundColor, value: .brown)
    }()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create the root window
        window = UIWindow(frame: UIScreen.main.bounds)

        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        
        // Create the base view
        let base = BaseBView()
            .add(toView: window)

        // Add subview
        View()
            .with(\.frame, value: window?.bounds ?? .zero)
            .with(\.backgroundColor, value: .red)
            .with(\.layer.cornerRadius, value: 16)
            .add(child: BareView()
                .with(\.frame, value: CGRect(x: 50, y: 50, width: 100, height: 100))
                .with(\.backgroundColor, value: .black))
            .add(children:
                BareView()
                    .with(\.frame, value: CGRect(x: 50, y: 100, width: 50, height: 30))
                    .with(\.backgroundColor, value: .black),
                 BareView()
                    .with(\.frame, value: CGRect(x: 350, y: 50, width: 100, height: 300))
                    .with(\.backgroundColor, value: .black),
                 BareView()
                    .with(\.frame, value: CGRect(x: 450, y: 450, width: 100, height: 300))
                    .with(\.backgroundColor, value: .black))
            .add(toView: base)


        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

