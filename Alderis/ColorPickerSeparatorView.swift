//
//  ColorPickerSeparatorView.swift
//  Alderis
//
//  Created by Adam Demasi on 12/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

extension UIBlurEffect.Style {
	static let systemVibrantBackgroundRegular = UIBlurEffect.Style.init(rawValue: 1200)!
}

class ColorPickerSeparatorView: UIView {

	enum Direction: Int {
		case horizontal, vertical
	}

	var direction = Direction.horizontal {
		didSet {
			updateConstraints()
		}
	}

	private var widthConstraint: NSLayoutConstraint!
	private var heightConstraint: NSLayoutConstraint!

	override init(frame: CGRect) {
		super.init(frame: frame)

		if #available(iOS 13, *) {
			// Matches the separator views used in UIAlertController since iOS 13
			let visualEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemMaterial), style: .separator))
			visualEffectView.frame = bounds
			visualEffectView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
			addSubview(visualEffectView)
			backgroundColor = UIColor.separator
		} else {
			backgroundColor = UIColor(white: 0.5, alpha: 0.5)
		}

		widthConstraint = widthAnchor.constraint(equalToConstant: 1.0)
		heightConstraint = heightAnchor.constraint(equalToConstant: 1.0)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func updateConstraints() {
		super.updateConstraints()

		let constant = 1.0 / (window?.screen.scale ?? 1.0)

		switch direction {
		case .horizontal:
			widthConstraint.isActive = false
			heightConstraint.isActive = true
			heightConstraint.constant = constant
			break
		case .vertical:
			widthConstraint.isActive = true
			heightConstraint.isActive = false
			widthConstraint.constant = constant
			break
		}
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()
		updateConstraints()
	}

}
