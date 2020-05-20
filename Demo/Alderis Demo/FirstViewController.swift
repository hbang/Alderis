//
//  FirstViewController.swift
//  Alderis Demo
//
//  Created by Adam Demasi on 15/4/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit
import Alderis

class FirstViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Alderis Demo"
		if #available(iOS 13.0, *) {
			view.backgroundColor = .systemBackground
		} else {
			view.backgroundColor = .white
		}

		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel!.font = UIFont.preferredFont(forTextStyle: .largeTitle)
		button.setTitle("Present", for: .normal)
		button.addTarget(self, action: #selector(self.presentColorPicker), for: .touchUpInside)
		view.addSubview(button)

		NSLayoutConstraint.activate([
			button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
			button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			button.heightAnchor.constraint(equalToConstant: 100)
		])
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		presentColorPicker()
	}

	@objc func presentColorPicker() {
		let colorPickerViewController = ColorPickerViewController()
		colorPickerViewController.delegate = self
		colorPickerViewController.color = view.window!.tintColor
		tabBarController!.present(colorPickerViewController, animated: true)
	}

}

extension FirstViewController: ColorPickerDelegate {

	func colorPicker(_ colorPicker: ColorPickerViewController, didSelect color: UIColor) {
		print("Returned with color \(color)")
		view.window!.tintColor = color
	}

	func colorPickerDidCancel(_ colorPicker: ColorPickerViewController) {
		print("Cancelled")
	}

}
