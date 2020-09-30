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

	private var colorWell: ColorWell!

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Alderis Demo"
		if #available(iOS 13.0, *) {
			view.backgroundColor = .systemBackground
		} else {
			view.backgroundColor = .white
		}

		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 10
		view.addSubview(stackView)

		let mainButton = UIButton(type: .system)
		mainButton.titleLabel!.font = UIFont.systemFont(ofSize: 34, weight: .semibold)
		mainButton.setTitle("Present", for: .normal)
		mainButton.addTarget(self, action: #selector(self.presentColorPicker), for: .touchUpInside)
		stackView.addArrangedSubview(mainButton)

		let buttons: [(String, Selector)] = [
			("Present with customised initial tab", #selector(self.presentColorPickerCustomisedInitialTab)),
			("Present with customised tabs",        #selector(self.presentColorPickerCustomisedTabs)),
			("Present with tabs hidden",            #selector(self.presentColorPickerNoTabs)),
			("Present without overriding Smart Invert", #selector(self.presentColorPickerNoOverrideSmartInvert)),
			("Present using deprecated API",        #selector(self.presentColorPickerDeprecatedAPI))
		]

		for item in buttons {
			let button = UIButton(type: .system)
			button.setTitle(item.0, for: .normal)
			button.addTarget(self, action: item.1, for: .touchUpInside)
			stackView.addArrangedSubview(button)
		}

		let spacerView = UIView()
		stackView.addArrangedSubview(spacerView)

		let wellsLabel = UILabel()
		wellsLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		wellsLabel.textAlignment = .center
		wellsLabel.text = "Color wells (try out drag and drop!)"
		stackView.addArrangedSubview(wellsLabel)

		colorWell = ColorWell()
		colorWell.isDragInteractionEnabled = true
		colorWell.isDropInteractionEnabled = true
		colorWell.addTarget(self, action: #selector(self.colorWellValueChanged(_:)), for: .valueChanged)
		colorWell.addTarget(self, action: #selector(self.presentColorPicker), for: .touchUpInside)

		let dragOrDropColorWell = ColorWell()
		dragOrDropColorWell.isDragInteractionEnabled = true
		dragOrDropColorWell.isDropInteractionEnabled = true
		dragOrDropColorWell.color = .systemPurple

		let nonDraggableWell = ColorWell()
		nonDraggableWell.isDragInteractionEnabled = false
		nonDraggableWell.isDropInteractionEnabled = true
		nonDraggableWell.color = .systemOrange

		let nonDroppableWell = ColorWell()
		nonDroppableWell.isDragInteractionEnabled = true
		nonDroppableWell.isDropInteractionEnabled = false
		nonDroppableWell.color = .systemTeal

		let nonDragOrDropWell = ColorWell()
		nonDragOrDropWell.isDragInteractionEnabled = false
		nonDragOrDropWell.isDropInteractionEnabled = false
		nonDragOrDropWell.color = .systemGreen

		let wellsContainerView = UIView()

		let wellsStackView = UIStackView(arrangedSubviews: [ colorWell,
																												 dragOrDropColorWell,
																												 nonDraggableWell,
																												 nonDroppableWell,
																												 nonDragOrDropWell ])
		wellsStackView.translatesAutoresizingMaskIntoConstraints = false
		wellsStackView.axis = .horizontal
		wellsStackView.spacing = 10
		wellsContainerView.addSubview(wellsStackView)

		stackView.addArrangedSubview(wellsContainerView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

			spacerView.heightAnchor.constraint(equalToConstant: 0),

			wellsStackView.topAnchor.constraint(equalTo: wellsContainerView.topAnchor),
			wellsStackView.bottomAnchor.constraint(equalTo: wellsContainerView.bottomAnchor),
			wellsStackView.centerXAnchor.constraint(equalTo: wellsContainerView.centerXAnchor)
		])

		for view in wellsStackView.arrangedSubviews {
			NSLayoutConstraint.activate([
				view.widthAnchor.constraint(equalToConstant: 32),
				view.heightAnchor.constraint(equalTo: view.widthAnchor)
			])
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		colorWell.color = view.window!.tintColor
	}

	@objc func colorWellValueChanged(_ sender: ColorWell) {
		NSLog("Color dropped with value %@", String(describing: sender.color))
		view.window!.tintColor = sender.color
	}

	@objc func presentColorPicker(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: view.window!.tintColor)
		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerCustomisedInitialTab(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: view.window!.tintColor)
		configuration.initialTab = .map

		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerCustomisedTabs(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: view.window!.tintColor)
		configuration.visibleTabs = [ .map, .sliders ]

		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerNoTabs(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: view.window!.tintColor)
		configuration.showTabs = false

		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerNoOverrideSmartInvert(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: view.window!.tintColor)
		configuration.overrideSmartInvert = false

		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerDeprecatedAPI(_ sender: UIView) {
		let colorPickerViewController = ColorPickerViewController()
		colorPickerViewController.delegate = self
		colorPickerViewController.color = view.window!.tintColor
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

}

extension FirstViewController: ColorPickerDelegate {

	func colorPicker(_ colorPicker: ColorPickerViewController, didSelect color: UIColor) {
		NSLog("Returned with color %@", String(describing: color))
		view.window!.tintColor = color
		colorWell.color = color
	}

	func colorPickerDidCancel(_ colorPicker: ColorPickerViewController) {
		NSLog("Cancelled")
	}

}
