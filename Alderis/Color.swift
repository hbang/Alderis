//
//  Color.swift
//  Alderis
//
//  Created by Adam Demasi on 15/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal struct Color: Equatable, Hashable {
	static let black = Color(white: 0, alpha: 1)
	static let white = Color(white: 1, alpha: 1)

	var red: CGFloat = 0 {
		didSet {
			self = Color(red: red, green: green, blue: blue, alpha: alpha)
		}
	}
	var green: CGFloat = 0 {
		didSet {
			self = Color(red: red, green: green, blue: blue, alpha: alpha)
		}
	}
	var blue: CGFloat = 0 {
		didSet {
			self = Color(red: red, green: green, blue: blue, alpha: alpha)
		}
	}

	var hue: CGFloat = 0 {
		didSet {
			self = Color(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
		}
	}
	var saturation: CGFloat = 0 {
		didSet {
			self = Color(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
		}
	}
	var brightness: CGFloat = 0 {
		didSet {
			self = Color(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
		}
	}

	var white: CGFloat = 0 {
		didSet {
			self = Color(white: white, alpha: alpha)
		}
	}

	var alpha: CGFloat = 0

	static func == (lhs: Color, rhs: Color) -> Bool {
		lhs.red == rhs.red &&
		lhs.green == rhs.green &&
		lhs.blue == rhs.blue &&
		lhs.alpha == rhs.alpha
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(red)
		hasher.combine(green)
		hasher.combine(blue)
		hasher.combine(alpha)
	}

	var uiColor: UIColor { .init(red: red, green: green, blue: blue, alpha: alpha) }

	init(uiColor: UIColor) {
		uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
		self.white = brightness
	}

	init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
		self.red = red
		self.green = green
		self.blue = blue
		self.alpha = alpha
		let uiColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
		uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
		self.white = brightness
	}

	init(white: CGFloat, alpha: CGFloat) {
		self.init(red: white, green: white, blue: white, alpha: alpha)
	}

	init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
		self.hue = hue
		self.saturation = saturation
		self.brightness = brightness
		self.white = brightness
		self.alpha = alpha
		let uiColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
		uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
	}
}

extension Color {
	static var brightnessThreshold: CGFloat {
		// Accessibility enabled:  conforms to WCAG 2.1 AAA
		// Accessibility disabled: conforms to WCAG 2.1 AA
		return UIAccessibility.isDarkerSystemColorsEnabled ? 4.5 : 7
	}

	var relativeLuminanceValues: (CGFloat, CGFloat, CGFloat) {
		let values = [red, green, blue]
			.map { $0 <= 0.03928 ? $0 / 12.92 : pow((($0 + 0.055) / 1.055), 2.4) }
		return (values[0], values[1], values[2])
	}

	var relativeLuminance: CGFloat {
		// https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
		let (r, g, b) = relativeLuminanceValues
		return (r * 0.2126) + (g * 0.7152) + (b * 0.0722)
	}

	func perceivedBrightness(onBackgroundColor background: Color) -> CGFloat {
		// https://www.w3.org/TR/WCAG21/#dfn-contrast-ratio - between 0-21
		let a = relativeLuminance + 0.05
		let b = background.relativeLuminance + 0.05
		return a > b ? a / b : b / a
	}

	var isDark: Bool { perceivedBrightness(onBackgroundColor: Self.white) > Self.brightnessThreshold && alpha > 0.5 }
}

extension Color {
	struct HexOptions: OptionSet {
		let rawValue: Int
		static let allowShorthand = Self(rawValue: 1 << 0)
		static let forceAlpha = Self(rawValue: 1 << 1)
	}

	// if the character in `value` is repeated, `repeatedValue` is a single copy of that character. If
	// `value` consists of two unique characters, `repeatedValue` is nil
	// e.g. valid return values are `("AA", "A")` and `("AB", nil)`
	private func hex(_ val: CGFloat) -> (value: String, repeatedValue: Character?) {
		let byte = Int(val * 255) & 0xFF
		let isRepeated = (byte & 0xF) == (byte >> 4)
		let value = String(format: "%02X", byte)
		return (value, isRepeated ? value.first : nil)
	}

	func hexString(with options: HexOptions = []) -> String {
		let (r, rRep) = hex(red)
		let (g, gRep) = hex(green)
		let (b, bRep) = hex(blue)
		let (a, aRep) = hex(alpha)
		let showAlpha = options.contains(.forceAlpha) || alpha != 1
		if options.contains(.allowShorthand),
			let rRep = rRep, let gRep = gRep, let bRep = bRep, let aRep = aRep {
			return "#\(rRep)\(gRep)\(bRep)\(showAlpha ? "\(aRep)" : "")"
		} else {
			return "#\(r)\(g)\(b)\(showAlpha ? a : "")"
		}
	}
}

extension Color {
	struct Component {
		let keyPath: WritableKeyPath<Color, CGFloat>
		let limit: CGFloat
		let title: String
		private let sliderTintColorForColor: (Color) -> Color

		init(
			keyPath: WritableKeyPath<Color, CGFloat>,
			limit: CGFloat,
			title: String,
			sliderTintColorForColor: @escaping (Color) -> Color
		) {
			self.keyPath = keyPath
			self.limit = limit
			self.title = title
			self.sliderTintColorForColor = sliderTintColorForColor
		}

		init(
			keyPath: WritableKeyPath<Color, CGFloat>,
			limit: CGFloat,
			title: String,
			sliderTint: Color
		) {
			self.keyPath = keyPath
			self.limit = limit
			self.title = title
			self.sliderTintColorForColor = { _ in sliderTint }
		}

		func sliderTintColor(for color: Color) -> Color {
			sliderTintColorForColor(color)
		}

		static let red: Component = .init(
			keyPath: \.red, limit: 255, title: "Red",
			sliderTint: Color(red: 1, green: 0.231373, blue: 0.188235, alpha: 1)
		)

		static let green: Component = .init(
			keyPath: \.green, limit: 255, title: "Green",
			sliderTint: Color(red: 0.298039, green: 0.85098, blue: 0.392157, alpha: 1)
		)

		static let blue: Component = .init(
			keyPath: \.blue, limit: 255, title: "Blue",
			sliderTint: Color(red: 0, green: 0.478431, blue: 1, alpha: 1)
		)

		static let hue: Component = .init(keyPath: \.hue, limit: 360, title: "Hue") { color in
			Color(hue: color.hue, saturation: 0.75, brightness: 0.5, alpha: 1)
		}

		static let saturation: Component = .init(keyPath: \.saturation, limit: 100, title: "Satur.") { color in
			Color(hue: color.hue, saturation: color.saturation, brightness: 0.75, alpha: 1)
		}

		static let brightness: Component = .init(keyPath: \.brightness, limit: 100, title: "Bright") { color in
			Color(hue: color.hue, saturation: 0.75, brightness: color.brightness, alpha: 1)
		}

		static let white: Component = .init(keyPath: \.white, limit: 255, title: "White") { color in
			Color(white: color.white * 0.85, alpha: 1)
		}

		static let alpha: Component = .init(keyPath: \.alpha, limit: 100, title: "Alpha") { color in
			Color(red: color.red, green: color.green, blue: color.blue, alpha: max(color.alpha, 0.5))
		}
	}
}
