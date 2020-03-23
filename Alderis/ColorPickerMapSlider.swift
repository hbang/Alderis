//
//  ColorPickerMapSlider.swift
//  Alderis
//
//  Created by Kabir Oberai on 23/03/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

class ColorPickerMapSlider: UIControl {
	let component: Color.Component
	let minImage: UIImage
	let maxImage: UIImage
	let imageTintColor: UIColor

	var overrideSmartInvert: Bool {
		didSet {
			slider.accessibilityIgnoresInvertColors = overrideSmartInvert
		}
	}

	private var slider: UISlider!

	var value: CGFloat {
		get { CGFloat(slider.value) }
		set {
			slider.value = Float(newValue)
		}
	}

	init(minImageName: String, maxImageName: String, component: Color.Component, overrideSmartInvert: Bool) {
		self.component = component
		self.overrideSmartInvert = overrideSmartInvert
		if #available(iOS 13, *) {
			minImage = UIImage(systemName: minImageName)!
			maxImage = UIImage(systemName: maxImageName)!
			imageTintColor = .secondaryLabel
		} else {
			let bundle = Bundle(for: Self.self)
			minImage = UIImage(named: minImageName, in: bundle, compatibleWith: nil)!
			maxImage = UIImage(named: maxImageName, in: bundle, compatibleWith: nil)!
			imageTintColor = UIColor(white: 60 / 255, alpha: 0.6)
		}
		super.init(frame: .zero)

		slider = UISlider()
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.accessibilityIgnoresInvertColors = overrideSmartInvert
		slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

		let leftImageView = UIImageView(image: minImage)
		leftImageView.translatesAutoresizingMaskIntoConstraints = false
		leftImageView.contentMode = .scaleAspectFit
		leftImageView.tintColor = imageTintColor

		let rightImageView = UIImageView(image: maxImage)
		rightImageView.translatesAutoresizingMaskIntoConstraints = false
		rightImageView.contentMode = .scaleAspectFit
		rightImageView.tintColor = imageTintColor

		let stackView = UIStackView(arrangedSubviews: [leftImageView, slider, rightImageView])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .fill
		stackView.spacing = 10
		addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			leftImageView.widthAnchor.constraint(equalToConstant: 22),
			leftImageView.widthAnchor.constraint(equalTo: rightImageView.widthAnchor),
			leftImageView.heightAnchor.constraint(equalTo: leftImageView.widthAnchor),
			rightImageView.heightAnchor.constraint(equalTo: rightImageView.widthAnchor)
		])
	}
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc private func sliderChanged() {
		sendActions(for: .valueChanged)
	}

	func update(with color: Color) {
		value = color[keyPath: component.keyPath]
		slider.tintColor = component.sliderTintColor(for: color).uiColor
	}

	func modify(_ color: inout Color) {
		color[keyPath: component.keyPath] = value
	}
}
