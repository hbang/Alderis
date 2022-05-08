//
//  Assets.swift
//  Alderis
//
//  Created by Adam Demasi on 27/9/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal struct Assets {

	internal enum SymbolScale: Int {
		case `default` = -1
		case unspecified, small, medium, large

		@available(iOS 13, *)
		var uiImageSymbolScale: UIImage.SymbolScale { UIImage.SymbolScale(rawValue: rawValue)! }
	}

	private static let bundle: Bundle = {
		let myBundle = Bundle(for: ColorPickerViewController.self)
		if let resourcesURL = myBundle.url(forResource: "Alderis", withExtension: "bundle"),
			 let resourcesBundle = Bundle(url: resourcesURL) {
			return resourcesBundle
		}
		return myBundle
	}()
	private static let uikitBundle = Bundle(for: UIView.self)

	// MARK: - Localization

	static func uikitLocalize(_ key: String) -> String {
		uikitBundle.localizedString(forKey: key, value: nil, table: nil)
	}

	// MARK: - Images

	static func systemImage(named name: String, font: UIFont? = nil, scale: SymbolScale = .default) -> UIImage? {
		if #available(iOS 13, *) {
			var configuration: UIImage.SymbolConfiguration?
			if let font = font {
				configuration = UIImage.SymbolConfiguration(font: font, scale: scale.uiImageSymbolScale)
			}
			return UIImage(systemName: name, withConfiguration: configuration)
		}
		return UIImage(named: name, in: bundle, compatibleWith: nil)
	}

	// MARK: - Fonts

	static func niceMonospaceDigitFont(ofSize size: CGFloat) -> UIFont {
		// Take the monospace digit font and enable stylistic alternative 6, which provides a
		// high-legibility, monospace-looking style of the system font.
		let font = UIFont.monospacedDigitSystemFont(ofSize: size, weight: .regular)
		let fontDescriptor = font.fontDescriptor.addingAttributes([
			.featureSettings: [
				[
					.alderisFeature: kStylisticAlternativesType,
					.alderisSelector: kStylisticAltSixOnSelector
				]
			] as [[UIFontDescriptor.FeatureKey: Int]]
		])
		return UIFont(descriptor: fontDescriptor, size: 0)
	}

	// MARK: - Colors

	static let backdropColor  = UIColor(white: 0, alpha: 0.2)
	static let separatorColor = UIColor(white: 1, alpha: 0.15)

	static let labelColor: UIColor = {
		if #available(iOS 13, *) {
			return .label
		}
		return .black
	}()

	static let borderColor: UIColor = {
		if #available(iOS 13, *) {
			return .separator
		}
		return UIColor(white: 1, alpha: 0.35)
	}()

	private static let checkerboardPattern: [UIUserInterfaceStyle: UIColor] = [
		.light: renderCheckerboardPattern(colors: (UIColor(white: 200 / 255, alpha: 1),
																							 UIColor(white: 255 / 255, alpha: 1))),
		.dark:  renderCheckerboardPattern(colors: (UIColor(white: 140 / 255, alpha: 1),
																							 UIColor(white: 186 / 255, alpha: 1)))
	]

	static let checkerboardPatternColor: UIColor = {
		if #available(iOS 13, *) {
			return UIColor { checkerboardPattern[$0.userInterfaceStyle] ?? checkerboardPattern[.light]! }
		}
		return checkerboardPattern[.light]!
	}()

	private static func renderCheckerboardPattern(colors: (dark: UIColor, light: UIColor)) -> UIColor {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20))
		let image = renderer.image { context in
			colors.dark.setFill()
			context.fill(CGRect(x: 0, y: 0, width: 20, height: 20))
			colors.light.setFill()
			context.fill(CGRect(x: 10, y: 0, width: 10, height: 10))
			context.fill(CGRect(x: 0, y: 10, width: 10, height: 10))
		}
		return UIColor(patternImage: image)
	}

}
