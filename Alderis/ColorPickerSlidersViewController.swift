//
//  ColorPickerSlidersViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 14/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

class ColorPickerSlidersViewController: ColorPickerTabViewController {

	static let imageName = "slider.horizontal.3"

	private enum Mode: CaseIterable {
		case rgb, hsb

		var title: String {
			switch self {
			case .rgb: return "RGB"
			case .hsb: return "HSB"
			}
		}

		var components: [Color.Component] {
			switch self {
			case .rgb:
				return [ .red, .green, .blue ]
			case .hsb:
				return [ .hue, .saturation, .brightness ]
			}
		}

		func color(withValues values: [CGFloat]) -> Color {
			switch self {
			case .rgb: return Color(red: values[0], green: values[1], blue: values[2], alpha: 1)
			case .hsb: return Color(hue: values[0], saturation: values[1], brightness: values[2], alpha: 1)
			}
		}
	}

	private var mode: Mode = .rgb {
		didSet {
			updateMode()
		}
	}

	private var segmentedControl: UISegmentedControl!
	private var labels = [UILabel]()
	private var sliders = [UISlider]()
	private var fields = [UITextField]()
	private var hexTextField: UITextField!
	private var hexOptions = Color.HexOptions()
	private var eggLabel: UILabel!
	private var eggString = ""

	override func viewDidLoad() {
		super.viewDidLoad()

		segmentedControl = UISegmentedControl(items: Mode.allCases.map { $0.title })
		segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		segmentedControl.accessibilityIgnoresInvertColors = overrideSmartInvert
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.addTarget(self, action: #selector(segmentControlChanged(_:)), for: .valueChanged)

		let topSpacerView = UIView()
		topSpacerView.translatesAutoresizingMaskIntoConstraints = false

		let mainStackView = UIStackView(arrangedSubviews: [ segmentedControl, topSpacerView ])
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.axis = .vertical
		mainStackView.alignment = .fill
		mainStackView.distribution = .fill
		mainStackView.spacing = 10
		view.addSubview(mainStackView)

		var colorRows = [UIStackView]()
		for _ in mode.components {
			let label = UILabel()
			label.translatesAutoresizingMaskIntoConstraints = false
			label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
			labels.append(label)

			let slider = UISlider()
			slider.translatesAutoresizingMaskIntoConstraints = false
			slider.accessibilityIgnoresInvertColors = overrideSmartInvert
			slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
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
			textField.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular)
			fields.append(textField)

			let stackView = UIStackView(arrangedSubviews: [ label, slider, textField ])
			stackView.translatesAutoresizingMaskIntoConstraints = false
			stackView.axis = .horizontal
			stackView.alignment = .fill
			stackView.distribution = .fill
			stackView.spacing = 5
			mainStackView.addArrangedSubview(stackView)
			colorRows.append(stackView)

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
		hexTextField.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular)

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
			hexStackView.heightAnchor.constraint(equalTo: colorRows[0].heightAnchor)
		])

		updateMode()
	}

	@objc func segmentControlChanged(_ sender: UISegmentedControl) {
		view.endEditing(true)
		mode = Mode.allCases[sender.selectedSegmentIndex]
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		view.endEditing(true)
	}

	func updateMode() {
		zip(labels, mode.components).forEach { $0.text = $1.title }
		updateColor()
	}

	@objc func sliderChanged() {
		hexOptions = []
		color = mode.color(withValues: sliders.map { CGFloat($0.value) })
		tabDelegate.colorPicker(didSelect: color)
	}

	override func updateColor() {
		for (i, component) in mode.components.enumerated() {
			sliders[i].value = Float(color[keyPath: component.keyPath])
			sliders[i].tintColor = component.sliderTintColor(for: color).uiColor
			fields[i].text = "\(Int((color[keyPath: component.keyPath] * component.limit).rounded()))"
		}

		hexTextField.text = color.hexString(with: hexOptions)

		if #available(iOS 13, *) {
		} else {
			let foregroundColor = color.isDark ? UIColor.white : UIColor.black
			segmentedControl.setTitleTextAttributes([
				.foregroundColor: foregroundColor
			], for: .selected)
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
		guard !newString.isEmpty else { return true }

		if fields.contains(textField) {
			// Numeric only, 0-255
			let badCharacterSet = CharacterSet(charactersIn: "0123456789").inverted
			guard newString.rangeOfCharacter(from: badCharacterSet) == nil else {
				return false
			}
			let index = fields.firstIndex(of: textField)!
			let limit = mode.components[index].limit
			guard let value = Int(newString), (0...limit).contains(CGFloat(value)) else {
				return false
			}
			// Run this after the input is fully processed by enqueuing it onto the run loop
			OperationQueue.main.addOperation {
				self.sliders[index].value = Float(value) / Float(limit)
				self.sliderChanged()
			}
		} else if textField == hexTextField {
			// #AAAAAA
			eggString = "\(eggString.suffix(3))\(string)"
			if eggString.lowercased() == "holo" {
				hexOptions = []
				color = Color(red: 51 / 255, green: 181 / 255, blue: 229 / 255, alpha: 1)
				tabDelegate.colorPicker(didSelect: color)
				eggLabel.text = "Praise DuARTe"
				eggLabel.textColor = color.uiColor
				eggLabel.isHidden = false
				eggString = ""
				return false
			}

			let canonicalizedString = newString.hasPrefix("#") ? newString.dropFirst() : Substring(newString)
			guard canonicalizedString.count <= 6 else {
				return false
			}

			let badCharacterSet = CharacterSet(charactersIn: "0123456789ABCDEFabcdef").inverted
			guard canonicalizedString.rangeOfCharacter(from: badCharacterSet) == nil else {
				return false
			}

			if canonicalizedString.count != 3 && canonicalizedString.count != 6 {
				// User is probably still typing it out. Don’t do anything yet.
				return true
			}

			guard let uiColor = UIColor(hbcp_propertyListValue: "#\(canonicalizedString)") else {
				return true
			}

			let color = Color(uiColor: uiColor)
			OperationQueue.main.addOperation {
				self.hexOptions = canonicalizedString.count == 3 ? .allowShorthand : []
				self.color = color
				self.tabDelegate.colorPicker(didSelect: color)
			}
		}
		return true
	}

}
