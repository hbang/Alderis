//
//  ColorPickerMapViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 14/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

class ColorPickerMapViewController: UIViewController, ColorPickerTabProtocol {

	weak var colorPickerDelegate: ColorPickerTabDelegate!
	var color: UIColor! {
		get {
			return _color
		}
		set {
			updateColor(newValue)
		}
	}
	private var _color: UIColor!
	var overrideSmartInvert = true

	private var wheelView: ColorPickerWheelView!
	private var brightnessSlider: UISlider!

	private var rawColor = RawColor(.white)

	override func viewDidLoad() {
		super.viewDidLoad()

		wheelView = ColorPickerWheelView()
		wheelView.translatesAutoresizingMaskIntoConstraints = false
		wheelView.accessibilityIgnoresInvertColors = overrideSmartInvert
		wheelView.delegate = self
		view.addSubview(wheelView)

		brightnessSlider = UISlider()
		brightnessSlider.translatesAutoresizingMaskIntoConstraints = false
		brightnessSlider.accessibilityIgnoresInvertColors = overrideSmartInvert
		brightnessSlider.addTarget(self, action: #selector(self.brightnessSliderChanged), for: .valueChanged)

		let minImage: UIImage
		let maxImage: UIImage
		let imageTintColor: UIColor
		if #available(iOS 13, *) {
			minImage = UIImage(systemName: "sun.min")!
			maxImage = UIImage(systemName: "sun.max")!
			imageTintColor = .label
		} else {
			// TODO
			minImage = UIImage()
			maxImage = UIImage()
			imageTintColor = .black
		}

		let brightnessLeftImageView = UIImageView(image: minImage)
		brightnessLeftImageView.translatesAutoresizingMaskIntoConstraints = false
		brightnessLeftImageView.tintColor = imageTintColor

		let brightnessRightImageView = UIImageView(image: maxImage)
		brightnessRightImageView.translatesAutoresizingMaskIntoConstraints = false
		brightnessRightImageView.tintColor = imageTintColor

		let brightnessStackView = UIStackView(arrangedSubviews: [brightnessSlider])// brightnessLeftImageView, brightnessSlider, brightnessRightImageView ])
		brightnessStackView.translatesAutoresizingMaskIntoConstraints = false
		brightnessStackView.axis = .horizontal
		brightnessStackView.alignment = .center
		brightnessStackView.distribution = .fill
		brightnessStackView.spacing = 10

		let mainStackView = UIStackView(arrangedSubviews: [ wheelView, brightnessStackView ])
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.axis = .vertical
		mainStackView.alignment = .fill
		mainStackView.distribution = .fill
		view.addSubview(mainStackView)

		NSLayoutConstraint.activate([
			mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
			mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
			mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
		])
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateColor(color, force: true)
		wheelView.color = color
	}

	@objc private func brightnessSliderChanged() {
		rawColor = RawColor(h: rawColor.h, s: rawColor.s, br: CGFloat(brightnessSlider.value), color: _color)
		_color = UIColor(hue: rawColor.h, saturation: rawColor.s, brightness: rawColor.br, alpha: 1)
		colorPickerDelegate.colorPicker(didSelectColor: color)
		wheelView.color = color
		updateBrightnessSliderTintColor()
	}

	private func updateBrightnessSliderTintColor() {
		var h: CGFloat = 0
		var br: CGFloat = 0
		color.getHue(&h, saturation: nil, brightness: &br, alpha: nil)
		brightnessSlider.tintColor = UIColor(hue: h, saturation: 0.75, brightness: br, alpha: 1)
	}

	private func updateColor(_ newValue: UIColor, force: Bool = false) {
		if _color != newValue || force {
			_color = newValue
			wheelView.color = newValue

			var h: CGFloat = 0
			var br: CGFloat = 0
			newValue.getHue(&h, saturation: nil, brightness: &br, alpha: nil)
			rawColor = RawColor(_color)
			brightnessSlider.value = Float(br)
			updateBrightnessSliderTintColor()
		}
	}

}

extension ColorPickerMapViewController: ColorPickerWheelViewDelegate {

	func colorPickerWheelView(didSelectColor color: UIColor) {
		self.color = color
		colorPickerDelegate.colorPicker(didSelectColor: self.color)
	}

}
