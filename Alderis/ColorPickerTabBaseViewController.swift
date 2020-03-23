//
//  ColorPickerTabBaseViewController.swift
//  Alderis
//
//  Created by Kabir Oberai on 23/03/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

protocol ColorPickerTabDelegate: class {
	func colorPicker(didSelect color: Color)
}

class ColorPickerTabViewControllerBase: UIViewController {

	unowned var tabDelegate: ColorPickerTabDelegate

	var overrideSmartInvert: Bool

	var color: Color {
		didSet { updateColor() }
	}

	func updateColor() {}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	required init(tabDelegate: ColorPickerTabDelegate, overrideSmartInvert: Bool, color: Color) {
		self.tabDelegate = tabDelegate
		self.overrideSmartInvert = overrideSmartInvert
		self.color = color
		super.init(nibName: nil, bundle: nil)
	}

}

protocol ColorPickerTabViewControllerProtocol: ColorPickerTabViewControllerBase {
	static var imageName: String { get }
	var image: UIImage { get }
}
extension ColorPickerTabViewControllerProtocol {
	var image: UIImage {
		if #available(iOS 13, *) {
			return UIImage(systemName: Self.imageName)!
		} else {
			let bundle = Bundle(for: type(of: self))
			return UIImage(named: Self.imageName, in: bundle, compatibleWith: nil)!
		}
	}
}

typealias ColorPickerTabViewController = ColorPickerTabViewControllerBase & ColorPickerTabViewControllerProtocol
