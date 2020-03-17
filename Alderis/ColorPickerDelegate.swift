//
//  ColorPickerDelegate.swift
//  Alderis
//
//  Created by Adam Demasi on 16/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

@objc protocol ColorPickerDelegate: NSObjectProtocol {

	@objc func colorPicker(_ colorPicker: ColorPickerViewController, didSelectColor color: UIColor)
	@objc optional func colorPickerDidCancel(_ colorPicker: ColorPickerViewController)

}
