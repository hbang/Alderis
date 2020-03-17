//
//  RawColor.swift
//  Alderis
//
//  Created by Adam Demasi on 15/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

struct RawColor {

	var r: CGFloat = 0
	var g: CGFloat = 0
	var b: CGFloat = 0
	var h: CGFloat = 0
	var s: CGFloat = 0
	var br: CGFloat = 0

	init(_ color: UIColor) {
		color.getRed(&r, green: &g, blue: &b, alpha: nil)
		color.getHue(&h, saturation: &s, brightness: &br, alpha: nil)
	}

	init(r: CGFloat, g: CGFloat, b: CGFloat, color: UIColor) {
		self.r = r
		self.g = g
		self.b = b
		color.getHue(&h, saturation: &s, brightness: &br, alpha: nil)
	}

	init(h: CGFloat, s: CGFloat, br: CGFloat, color: UIColor) {
		self.h = h
		self.s = s
		self.br = br
		color.getRed(&r, green: &g, blue: &b, alpha: nil)
	}

}
