//
//  Assets.swift
//  Alderis
//
//  Created by Adam Demasi on 27/9/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import Foundation

internal struct Assets {

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
		return uikitBundle.localizedString(forKey: key, value: nil, table: nil)
	}

	// MARK: - Images

	static func image(named name: String) -> UIImage? {
		return UIImage(named: name, in: bundle, compatibleWith: nil)
	}

	static func systemImage(named name: String, fontSize: CGFloat? = nil) -> UIImage? {
		if #available(iOS 13, *) {
			var configuration: UIImage.SymbolConfiguration?
			if let fontSize = fontSize {
				configuration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: fontSize))
			}
			return UIImage(systemName: name, withConfiguration: configuration)
		} else {
			return image(named: name)
		}
	}

	// MARK: - Fonts

	static func niceMonospaceDigitFont(ofSize size: CGFloat) -> UIFont {
		// Take the monospace digit font and enable stylistic alternative 6, which provides a
		// high-legibility, monospace-looking, style of the system font.
		let font = UIFont.monospacedDigitSystemFont(ofSize: size, weight: .regular)
		let fontDescriptor = font.fontDescriptor.addingAttributes([
			.featureSettings: [
				[
					.featureIdentifier: kStylisticAlternativesType,
					.typeIdentifier: kStylisticAltSixOnSelector
				]
			] as [[UIFontDescriptor.FeatureKey: Int]]
		])

		return UIFont(descriptor: fontDescriptor, size: 0)
	}

	// MARK: - Colors

	static let backdropColor  = UIColor(white:   0 / 255, alpha: 0.2)
	static let separatorColor = UIColor(white: 217 / 255, alpha: 1)

	static let borderColor: UIColor = {
		if #available(iOS 13, *) {
			return .separator
		} else {
			return UIColor(white: 1, alpha: 0.35)
		}
	}()

	private static let checkerboardPatternLightGrey  = UIColor(white: 200 / 255, alpha: 1)
	private static let checkerboardPatternLightWhite = UIColor(white: 255 / 255, alpha: 1)
	private static let checkerboardPatternDarkGrey   = UIColor(white: 140 / 255, alpha: 1)
	private static let checkerboardPatternDarkWhite  = UIColor(white: 186 / 255, alpha: 1)

	static let checkerboardPatternColor: UIColor = {
		if #available(iOS 13, *) {
			return UIColor { traitCollection -> UIColor in
				switch traitCollection.userInterfaceStyle {
				case .light, .unspecified:
					return renderCheckerboardPattern(darkColor: checkerboardPatternLightGrey,
																					 lightColor: checkerboardPatternLightWhite)
				case .dark:
					return renderCheckerboardPattern(darkColor: checkerboardPatternDarkGrey,
																					 lightColor: checkerboardPatternDarkWhite)
				@unknown default:
					return renderCheckerboardPattern(darkColor: checkerboardPatternLightGrey,
																					 lightColor: checkerboardPatternLightWhite)
				}
			}
		} else {
			return renderCheckerboardPattern(darkColor: checkerboardPatternLightGrey,
																			 lightColor: checkerboardPatternLightWhite)
		}
	}()

	private static func renderCheckerboardPattern(darkColor: UIColor, lightColor: UIColor) -> UIColor {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20))
		let image = renderer.image { context in
			darkColor.setFill()
			context.fill(CGRect(x: 0, y: 0, width: 20, height: 20))
			lightColor.setFill()
			context.fill(CGRect(x: 10, y: 0, width: 10, height: 10))
			context.fill(CGRect(x: 0, y: 10, width: 10, height: 10))
		}
		return UIColor(patternImage: image)
	}

}
