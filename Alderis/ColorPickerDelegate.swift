//
//  ColorPickerDelegate.swift
//  Alderis
//
//  Created by Adam Demasi on 16/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

/// Use ColorPickerDelegate to handle the user’s response to `ColorPickerViewController`.
@objc(HBColorPickerDelegate)
public protocol ColorPickerDelegate: NSObjectProtocol {

	/// Informs the delegate that the user has dismissed the color picker with a positive response,
	/// having selected the selected color. Required.
	///
	/// - parameter colorPicker: The `ColorPickerViewController` instance that triggered the action.
	/// - parameter color: The `UIColor` selection the user made.
	@objc(colorPicker:didSelectColor:)
	func colorPicker(_ colorPicker: ColorPickerViewController, didSelect color: UIColor)

	/// Informs the delegate that the user has dismissed the color picker with a negative response.
	/// Optional.
	///
	/// You usually do not need to handle this condition.
	///
	/// - parameter colorPicker: The `ColorPickerViewController` instance that triggered the action.
	@objc(colorPickerDidCancel:)
	optional func colorPickerDidCancel(_ colorPicker: ColorPickerViewController)

}
