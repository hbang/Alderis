//
//  ColorPickerSlider.swift
//  Alderis
//
//  Created by Kabir Oberai on 28/03/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class ColorPickerSliderBase: UIControl {

	var overrideSmartInvert: Bool {
		didSet {
			slider.accessibilityIgnoresInvertColors = overrideSmartInvert
		}
	}

	let stackView: UIStackView
	let slider: ColorSlider

	var value: CGFloat {
		get { CGFloat(slider.value) }
		set { slider.value = Float(newValue) }
	}

	init(overrideSmartInvert: Bool) {
		self.overrideSmartInvert = overrideSmartInvert

		slider = ColorSlider()
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.accessibilityIgnoresInvertColors = overrideSmartInvert

		stackView = UIStackView(arrangedSubviews: [slider])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.distribution = .fill

		super.init(frame: .zero)

		slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
		addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			stackView.topAnchor.constraint(equalTo: self.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc internal func sliderChanged() {
		sendActions(for: .valueChanged)
	}

}

internal protocol ColorPickerSliderProtocol: ColorPickerSliderBase {
	func setColor(_ color: Color)
	func apply(to color: inout Color)
}

internal typealias ColorPickerSlider = ColorPickerSliderBase & ColorPickerSliderProtocol

internal class ColorPickerComponentSlider: ColorPickerSlider {

	let component: Color.Component

	init(component: Color.Component, overrideSmartInvert: Bool) {
		self.component = component
		super.init(overrideSmartInvert: overrideSmartInvert)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setColor(_ color: Color) {
		value = color[keyPath: component.keyPath]
		slider.gradientColors = component.sliderTintColor(for: color).map(\.uiColor)
	}

	func apply(to color: inout Color) {
		color[keyPath: component.keyPath] = value
	}

}

internal class ColorSlider: UISlider {

	var gradientColors = [UIColor]() {
		didSet { gradientLayer.colors = gradientColors.map(\.cgColor) }
	}

	private var checkerboardView: UIView!
	private var gradientLayer: CAGradientLayer!

	override init(frame: CGRect) {
		super.init(frame: frame)

		var useSliderTrack = !isCatalystMac
		if #available(iOS 15, *) {
			preferredBehavioralStyle = .pad
			useSliderTrack = true
		}
		if useSliderTrack {
			setMinimumTrackImage(UIImage(), for: .normal)
			setMaximumTrackImage(UIImage(), for: .normal)
		}

		checkerboardView = UIView()
		checkerboardView.translatesAutoresizingMaskIntoConstraints = false
		checkerboardView.backgroundColor = Assets.checkerboardPatternColor
		checkerboardView.clipsToBounds = true
		if #available(iOS 13, *) {
			checkerboardView.layer.cornerCurve = .continuous
		}
		insertSubview(checkerboardView, at: 0)

		gradientLayer = CAGradientLayer()
		gradientLayer.startPoint = CGPoint(x: 0, y: 0)
		gradientLayer.endPoint = CGPoint(x: 1, y: 0)
		gradientLayer.allowsGroupOpacity = false
		checkerboardView.layer.addSublayer(gradientLayer)

		NSLayoutConstraint.activate([
			checkerboardView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: UIFloat(-3)),
			checkerboardView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: UIFloat(3)),
			checkerboardView.topAnchor.constraint(equalTo: self.topAnchor, constant: -1),
			checkerboardView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 1)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		gradientLayer.frame = checkerboardView.bounds
		checkerboardView.layer.cornerRadius = checkerboardView.frame.size.height / 2
	}

}
