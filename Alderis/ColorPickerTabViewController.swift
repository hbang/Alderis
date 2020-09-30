//
//  ColorPickerTabViewController.swift
//  Alderis
//
//  Created by Kabir Oberai on 23/03/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal protocol ColorPickerTabDelegate: class {
	func colorPickerTab(_ tab: ColorPickerTabViewControllerBase, didSelect color: Color)
}

internal class ColorPickerTabViewControllerBase: UIViewController {

	unowned var tabDelegate: ColorPickerTabDelegate

	private(set) var configuration: ColorPickerConfiguration

	private(set) var color: Color {
		didSet {
			colorDidChange()
		}
	}

	func colorDidChange() {}

	func setColor(_ color: Color, shouldBroadcast: Bool = true) {
		self.color = color
		if shouldBroadcast {
			tabDelegate.colorPickerTab(self, didSelect: color)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	required init(tabDelegate: ColorPickerTabDelegate, configuration: ColorPickerConfiguration, color: Color) {
		self.tabDelegate = tabDelegate
		self.configuration = configuration
		self.color = color
		super.init(nibName: nil, bundle: nil)
	}

}

internal protocol ColorPickerTabViewControllerProtocol: ColorPickerTabViewControllerBase {
	static var imageName: String { get }
	static var image: UIImage { get }
}
extension ColorPickerTabViewControllerProtocol {
	static var image: UIImage { Assets.systemImage(named: imageName, fontSize: 20)! }
}

internal typealias ColorPickerTabViewController = ColorPickerTabViewControllerBase & ColorPickerTabViewControllerProtocol
