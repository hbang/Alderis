//
//  ColorPickerMapViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 14/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

class ColorPickerMapViewController: ColorPickerTabViewController {

    static let imageName = "slider.horizontal.below.rectangle"

	private var wheelView: ColorPickerWheelView!
    private var sliders: [ColorPickerMapSlider] = []

	override func viewDidLoad() {
		super.viewDidLoad()

        wheelView = ColorPickerWheelView(color: color)
		wheelView.translatesAutoresizingMaskIntoConstraints = false
		wheelView.accessibilityIgnoresInvertColors = overrideSmartInvert
		wheelView.delegate = self
		view.addSubview(wheelView)

        #warning("TODO: Add eye.slash and eye images")
        sliders = [
            ColorPickerMapSlider(
                minImageName: "sun.min", maxImageName: "sun.max", component: .brightness,
                overrideSmartInvert: overrideSmartInvert
            ),
            ColorPickerMapSlider(
                minImageName: "eye.slash", maxImageName: "eye", component: .alpha,
                overrideSmartInvert: overrideSmartInvert
            )
        ]

        sliders.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        }

		let mainStackView = UIStackView(arrangedSubviews: [wheelView] + sliders)
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.axis = .vertical
		mainStackView.alignment = .fill
		mainStackView.distribution = .fill
		view.addSubview(mainStackView)

		NSLayoutConstraint.activate([
			mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
			mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
			mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
		])
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateColor()
	}

    @objc private func sliderChanged(_ slider: ColorPickerMapSlider) {
        slider.modify(&color)
        tabDelegate.colorPicker(didSelect: color)
    }

	override func updateColor() {
        wheelView.color = color
        sliders.forEach { $0.update(with: color) }
	}

}

extension ColorPickerMapViewController: ColorPickerWheelViewDelegate {

	func colorPickerWheelView(didSelectColor color: Color) {
		self.color = color
		tabDelegate.colorPicker(didSelect: color)
	}

}
