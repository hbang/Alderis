//
//  ColorPickerSlidersViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 14/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

class ColorPickerSlidersViewController: UIViewController, ColorPickerTabProtocol {

	private enum Mode: Int {
		case rgb, hsb
	}

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
	private var mode = Mode.rgb {
		didSet {
			updateMode()
		}
	}
	private var rawColor = RawColor(.white)

	private var segmentedControl: UISegmentedControl!
	private var labels = [UILabel]()
	private var sliders = [UISlider]()
	private var fields = [UITextField]()
	private var hexTextField: UITextField!
	private var eggLabel: UILabel!
	private var eggString = ""

	override func viewDidLoad() {
		super.viewDidLoad()

		segmentedControl = UISegmentedControl(items: [ "RGB", "HSB" ])
		segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		segmentedControl.accessibilityIgnoresInvertColors = overrideSmartInvert
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.addTarget(self, action: #selector(self.segmentControlChanged(_:)), for: .valueChanged)

		let topSpacerView = UIView()
		topSpacerView.translatesAutoresizingMaskIntoConstraints = false

		let mainStackView = UIStackView(arrangedSubviews: [ segmentedControl, topSpacerView ])
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.axis = .vertical
		mainStackView.alignment = .fill
		mainStackView.distribution = .fill
		mainStackView.spacing = 10
		view.addSubview(mainStackView)

		var anyColorRow: UIStackView! = nil
		for _ in 0..<3 {
			let label = UILabel()
			label.translatesAutoresizingMaskIntoConstraints = false
			label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
			labels.append(label)

			let slider = UISlider()
			slider.translatesAutoresizingMaskIntoConstraints = false
			slider.accessibilityIgnoresInvertColors = overrideSmartInvert
			slider.addTarget(self, action: #selector(self.sliderChanged(_:)), for: .valueChanged)
			sliders.append(slider)

			let textField = UITextField()
			textField.translatesAutoresizingMaskIntoConstraints = false
			textField.delegate = self
			textField.returnKeyType = .next
			textField.keyboardType = .numberPad
			textField.autocapitalizationType = .none
			textField.autocorrectionType = .no
			textField.spellCheckingType = .no
			textField.textAlignment = .right
			textField.font = UIFont.systemFont(ofSize: 16)
			fields.append(textField)

			let stackView = UIStackView(arrangedSubviews: [ label, slider, textField ])
			stackView.translatesAutoresizingMaskIntoConstraints = false
			stackView.axis = .horizontal
			stackView.alignment = .fill
			stackView.distribution = .fill
			stackView.spacing = 5
			mainStackView.addArrangedSubview(stackView)

			if anyColorRow == nil {
				anyColorRow = stackView
			}

			NSLayoutConstraint.activate([
				label.widthAnchor.constraint(equalToConstant: 50),
				textField.widthAnchor.constraint(equalToConstant: 35)
			])
		}

		hexTextField = UITextField()
		hexTextField.translatesAutoresizingMaskIntoConstraints = false
		hexTextField.delegate = self
		hexTextField.textAlignment = .right
		hexTextField.returnKeyType = .done
		hexTextField.autocapitalizationType = .none
		hexTextField.autocorrectionType = .no
		hexTextField.spellCheckingType = .no
		hexTextField.font = UIFont.systemFont(ofSize: 16)

		eggLabel = UILabel()
		eggLabel.translatesAutoresizingMaskIntoConstraints = false
		eggLabel.accessibilityIgnoresInvertColors = overrideSmartInvert
		eggLabel.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
		eggLabel.isHidden = true

		let hexSpacerView = UIView()
		hexSpacerView.translatesAutoresizingMaskIntoConstraints = false

		let hexStackView = UIStackView(arrangedSubviews: [ eggLabel, hexSpacerView, hexTextField ])
		hexStackView.translatesAutoresizingMaskIntoConstraints = false
		hexStackView.axis = .horizontal
		hexStackView.alignment = .fill
		hexStackView.distribution = .fill
		hexStackView.spacing = 5
		mainStackView.addArrangedSubview(hexStackView)

		let bottomSpacerView = UIView()
		bottomSpacerView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.addArrangedSubview(bottomSpacerView)

		NSLayoutConstraint.activate([
			mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
			mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
			mainStackView.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: -15),
			topSpacerView.heightAnchor.constraint(equalToConstant: 0),
			hexTextField.widthAnchor.constraint(equalToConstant: 100),
			hexStackView.heightAnchor.constraint(equalTo: anyColorRow.heightAnchor)
		])

		updateMode()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateColor(color, force: true)
	}

	@objc func segmentControlChanged(_ sender: UISegmentedControl) {
		view.endEditing(true)
		mode = Mode(rawValue: sender.selectedSegmentIndex)!
	}

	@objc func sliderChanged(_ sender: UISegmentedControl) {
		updateFromSliders()
		colorPickerDelegate.colorPicker(didSelectColor: _color)
		updateFields()
		updateHexField()
		updateTintColor()
	}

	func updateColor(_ newValue: UIColor, force: Bool = false) {
		if color != newValue || force {
			_color = newValue
			rawColor = RawColor(_color)

			updateSliders()
			updateFields()
			updateHexField()
			updateTintColor()
		}
	}

	func updateMode() {
		switch mode {
		case .rgb:
			labels[0].text = "Red"
			labels[1].text = "Green"
			labels[2].text = "Blue"
			break

		case .hsb:
			labels[0].text = "Hue"
			labels[1].text = "Satur."
			labels[2].text = "Bright"
			break
		}

		updateSliders()
		updateFields()
		updateHexField()
		updateTintColor()
	}

	func updateFromSliders() {
		let sliderValues = sliders.map { slider in CGFloat(slider.value) }

		switch mode {
		case .rgb:
			_color = UIColor(red: sliderValues[0], green: sliderValues[1], blue: sliderValues[2], alpha: 1)
			rawColor = RawColor(r: sliderValues[0], g: sliderValues[1], b: sliderValues[2], color: _color)
			break

		case .hsb:
			_color = UIColor(hue: sliderValues[0], saturation: sliderValues[1], brightness: sliderValues[2], alpha: 1)
			rawColor = RawColor(h: sliderValues[0], s: sliderValues[1], br: sliderValues[2], color: _color)
			break
		}
	}

	func updateSliders() {
		switch mode {
		case .rgb:
			sliders[0].value = Float(rawColor.r)
			sliders[1].value = Float(rawColor.g)
			sliders[2].value = Float(rawColor.b)
			break

		case .hsb:
			sliders[0].value = Float(rawColor.h)
			sliders[1].value = Float(rawColor.s)
			sliders[2].value = Float(rawColor.br)
			break
		}
	}

	func updateFields() {
		switch mode {
		case .rgb:
			fields[0].text = String(format: "%i", Int(rawColor.r * 255))
			fields[1].text = String(format: "%i", Int(rawColor.g * 255))
			fields[2].text = String(format: "%i", Int(rawColor.b * 255))
			break

		case .hsb:
			fields[0].text = String(format: "%i", Int(rawColor.h * 360))
			fields[1].text = String(format: "%i", Int(rawColor.s * 100))
			fields[2].text = String(format: "%i", Int(rawColor.br * 100))
			break
		}
	}

	func updateHexField() {
		let hex = ((Int(rawColor.r * 255) & 0xFF) << 16) + ((Int(rawColor.g * 255) & 0xFF) << 8) + (Int(rawColor.b * 255) & 0xFF)
		hexTextField.text = String(format: "#%06X", hex)
	}

	func updateTintColor() {
		if #available(iOS 13, *) {
		} else {
			let perceivedBrightness = Color.perceivedBrightness(for: _color ?? .white)
			let foregroundColor = perceivedBrightness < Color.brightnessThreshold ? UIColor.white : UIColor.black
			segmentedControl.setTitleTextAttributes([
				.foregroundColor: foregroundColor
			], for: .selected)
		}

		switch mode {
		case .rgb:
			sliders[0].tintColor = UIColor(red: 1.0,      green: 0.231373, blue: 0.188235, alpha: 1)
			sliders[1].tintColor = UIColor(red: 0.298039, green: 0.85098,  blue: 0.392157, alpha: 1)
			sliders[2].tintColor = UIColor(red: 0.0,      green: 0.478431, blue: 1.0,      alpha: 1)
			break

		case .hsb:
			sliders[0].tintColor = UIColor(hue: rawColor.h, saturation: 0.75,       brightness: 0.5,         alpha: 1)
			sliders[1].tintColor = UIColor(hue: rawColor.h, saturation: rawColor.s, brightness: 0.75,        alpha: 1)
			sliders[2].tintColor = UIColor(hue: rawColor.h, saturation: 0.75,       brightness: rawColor.br, alpha: 1)
			break
		}
	}

}

extension ColorPickerSlidersViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == hexTextField {
			view.endEditing(true)
		}
		return true
	}

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let newString = textField.text!.replacingCharacters(in: Range(range, in: textField.text!)!, with: string)
		if newString.count == 0 {
			return true
		}

		if fields.contains(textField) {
			// Numeric only, 0-255
			let badCharacterSet = NSCharacterSet(charactersIn: "0123456789").inverted
			if newString.rangeOfCharacter(from: badCharacterSet) != nil {
				return false
			}
			guard let value = Int(newString) else {
				return false
			}
			if value < 0 || value > 255 {
				return false
			}

			let index = fields.firstIndex(of: textField)!
			sliders[index].value = Float(value) / 255
			updateFromSliders()
			colorPickerDelegate.colorPicker(didSelectColor: _color)
			updateHexField()
		} else if textField == hexTextField {
			// #AAAAAA
			eggString += string
			if eggString.count > 4 {
				eggString = String(eggString.dropFirst(eggString.count - 4))
			}
			if eggString.lowercased() == "holo" {
				color = UIColor(red: 51 / 255, green: 181 / 255, blue: 229 / 255, alpha: 1)
				colorPickerDelegate.colorPicker(didSelectColor: color)
				eggLabel.text = "Praise DuARTe"
				eggLabel.textColor = color
				eggLabel.isHidden = false
				eggString = ""
				return false
			}

			let expectedLength = newString.hasPrefix("#") ? 7 : 6
			if newString.count > expectedLength {
				return false
			}

			let badCharacterSet = NSCharacterSet(charactersIn: "0123456789ABCDEFabcdef#").inverted
			if newString.rangeOfCharacter(from: badCharacterSet) != nil {
				return false
			}

			if newString.count != expectedLength {
				// User is probably still typing it out. Don’t do anything yet.
				return true
			}

			guard let color = UIColor(hbcp_propertyListValue: newString) else {
				return true
			}
			_color = color
			rawColor = RawColor(color)
			colorPickerDelegate.colorPicker(didSelectColor: color)
			updateFields()
			updateSliders()
		}
		updateTintColor()
		return true
	}

}
