//
//  UIColor+HBAdditions.swift
//  Alderis
//
//  Created by Ryan Nair on 10/5/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

extension UIColor {
	
	/// Initializes and returns a color object using data from the specified object.
	///
	/// The value is expected to be one of:
	///
	/// * An array of 3 or 4 integer RGB or RGBA color components, with values between 0 and 255 (e.g.
	///   `@[ 218, 192, 222 ]`)
	/// * A CSS-style hex string, with an optional alpha component (e.g. `#DAC0DE` or `#DACODE55`)
	/// * A short CSS-style hex string, with an optional alpha component (e.g. `#DC0` or `#DC05`)
	///
	/// @param value The object to retrieve data from. See the discussion for the supported object
	/// types.
	/// @returns An initialized color object. The color information represented by this object is in the
	/// device RGB colorspace.
	
	convenience init?(hbcp_propertyListValue value: Any?) {
		
			if value == nil {
						return nil
			} else if value is NSArray && (value as? [AnyHashable])?.count == 3 || (value as? [AnyHashable])?.count == 4 {
						let array = value as! [AnyHashable]
						self.init(
								red: (array[0] as? CGFloat ?? 0) / 255.0,
								green: (array[1] as? CGFloat ?? 0) / 255.0,
								blue: (array[2] as? CGFloat ?? 0) / 255.0,
								alpha: CGFloat(array.count == 4 ? (array[3] as? Double ?? 0.0) : 1))
			}
			else if value is NSString {
						var string = value as! String
						let colonLocation = (string as NSString?)?.range(of: ":").location ?? 0
						if colonLocation != NSNotFound {
								string = (string as NSString?)!.substring(to: colonLocation)
						}

						if (string.count) == 4 || (string.count) == 5 {
								let r = (string as NSString).substring(with: NSRange(location: 1, length: 1))
								let g = (string as NSString).substring(with: NSRange(location: 2, length: 1))
								let b = (string as NSString).substring(with: NSRange(location: 3, length: 1))
								let a = string.count == 5 ? (string as NSString?)!.substring(with: NSRange(location: 4, length: 1)) : "F"
								string = String(format: "#%1$@%1$@%2$@%2$@%3$@%3$@%4$@%4$@", r, g, b, a)
						}

						var hex: UInt64 = 0
						let scanner = Scanner(string: string)
						scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
						scanner.scanHexInt64(&hex)

						if (string.count) == 9 {
								self.init(
										red: CGFloat(((hex & 0xff000000) >> 24)) / 255.0,
										green: CGFloat(((hex & 0x00ff0000) >> 16)) / 255.0,
										blue: CGFloat(((hex & 0x0000ff00) >> 8)) / 255.0,
										alpha: CGFloat(((hex & 0x000000ff) >> 0)) / 255.0)
						}
						else {
								self.init(
										red: CGFloat(((hex & 0xff0000) >> 16)) / 255.0,
										green: CGFloat(((hex & 0x00ff00) >> 8)) / 255.0,
										blue: CGFloat(((hex & 0x0000ff) >> 0)) / 255.0,
										alpha: 1)
						}
			}
	
			return nil
	}


	func hbcp_propertyListValue() -> String? {
			var r: CGFloat = 0
			var g: CGFloat = 0
			var b: CGFloat = 0
			var a: CGFloat = 0
			
			self.getRed(&r, green: &g, blue: &b, alpha: &a)
		
			let hex = ((UInt(r * 255.0) & 0xff) << 16) + ((UInt(g * 255.0) & 0xff) << 8) + (UInt(b * 255.0) & 0xff)
			let alphaString = a == 1 ? "" : String(format: ":%.5G", a)
			return String(format: "#%06X%@", hex, alphaString)
		}
}
