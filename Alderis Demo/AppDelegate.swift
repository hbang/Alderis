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
	var navigationController: UINavigationController!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		navigationController = UINavigationController(rootViewController: UITableViewController())
		window!.rootViewController = navigationController
		window!.makeKeyAndVisible()

		let colorPickerViewController = ColorPickerViewController()
		colorPickerViewController.delegate = self
		colorPickerViewController.color = UIColor(red: 0.333333, green: 0.0627451, blue: 0.160784, alpha: 1)
		navigationController.present(colorPickerViewController, animated: true, completion: nil)

		return true
	}

}

extension AppDelegate: ColorPickerDelegate {

	func colorPicker(_ colorPicker: ColorPickerViewController, didSelectColor color: UIColor) {
		print("Returned with color \(color)")
		navigationController.navigationBar.barTintColor = color
	}

	func colorPickerDidCancel(_ colorPicker: ColorPickerViewController) {
		print("Cancelled")
	}

}
