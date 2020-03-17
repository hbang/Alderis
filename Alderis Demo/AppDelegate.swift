//
//  AppDelegate.swift
//  Alderis Demo
//
//  Created by Adam Demasi on 12/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit
import Alderis

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		let navigationController = UINavigationController(rootViewController: UITableViewController())
		window!.rootViewController = navigationController
		window!.makeKeyAndVisible()

		let colorPickerViewController = ColorPickerViewController()
		navigationController.present(colorPickerViewController, animated: true, completion: nil)

		return true
	}

}
