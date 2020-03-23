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
    var colorPickerViewController: ColorPickerViewController!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)

        let tableViewController = UITableViewController()
        tableViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Present", style: .plain, target: self, action: #selector(presentColorPicker)
        )

		navigationController = UINavigationController(rootViewController: tableViewController)
		window!.rootViewController = navigationController
		window!.makeKeyAndVisible()

		colorPickerViewController = ColorPickerViewController()
		colorPickerViewController.delegate = self
		colorPickerViewController.color = UIColor(red: 0.333333, green: 0.0627451, blue: 0.160784, alpha: 1)
        presentColorPicker()

		return true
	}

    @objc func presentColorPicker() {
        navigationController.present(colorPickerViewController, animated: true)
    }

}

extension AppDelegate: ColorPickerDelegate {

	func colorPicker(_ colorPicker: ColorPickerViewController, didSelect color: UIColor) {
		print("Returned with color \(color)")
		navigationController.navigationBar.barTintColor = color
	}

	func colorPickerDidCancel(_ colorPicker: ColorPickerViewController) {
		print("Cancelled")
	}

}
