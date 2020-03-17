//
//  ColorPickerColor.swift
//  Alderis
//
//  Created by Adam Demasi on 16/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

class Color {

	static let brightnessThreshold: CGFloat = {
		let differentiateWithoutColor: Bool
		if #available(iOS 13, *) {
			differentiateWithoutColor = UIAccessibility.shouldDifferentiateWithoutColor
		} else {
			differentiateWithoutColor = false
		}
		return UIAccessibility.isReduceTransparencyEnabled || differentiateWithoutColor ? 128.0 : 80.0
	}()

	class func perceivedBrightness(for color: UIColor) -> CGFloat {
		// W3C perceived brightness algorithm
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		color.getRed(&r, green: &g, blue: &b, alpha: nil)
		return ((r * 255 * 299) + (g * 255 * 587) + (b * 255 * 114)) / 1000
	}

}
