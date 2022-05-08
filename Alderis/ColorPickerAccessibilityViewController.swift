//
//  ColorPickerAccessibilityViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 8/5/2022.
//  Copyright © 2022 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class ColorPickerAccessibilityViewController: ColorPickerTabViewController {

	static let imageName = "circle.righthalf.fill"

	private static let percentFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .percent
		return formatter
	}()

	private var backgroundMode: AccessibilityContrastSelector.Mode = .white {
		didSet { colorDidChange() }
	}
	private var foregroundMode: AccessibilityContrastSelector.Mode = .color {
		didSet { colorDidChange() }
	}

	private var scrollView: UIScrollView!

	private var demoContainerView: UIView!
	private var demoLabels: [UIView]!

	private var contrastStackView: UIStackView!
	private var contrastRatioLabel: UILabel!
	private var aaComplianceLabel: AccessibilityComplianceLabel!
	private var aaaComplianceLabel: AccessibilityComplianceLabel!

	private var backgroundSelector: AccessibilityContrastSelector!
	private var foregroundSelector: AccessibilityContrastSelector!

	override func viewDidLoad() {
		super.viewDidLoad()

		let demoTitleLabel = UILabel()
		demoTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		demoTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
		demoTitleLabel.text = "Size 18 Lorem ipsum dolor sit amet"

		let demoImageView = UIImageView(image: Assets.systemImage(named: "sparkles", font: .systemFont(ofSize: 16, weight: .semibold)))
		demoImageView.translatesAutoresizingMaskIntoConstraints = false

		let titleStackView = UIStackView(arrangedSubviews: [demoImageView, demoTitleLabel])
		titleStackView.translatesAutoresizingMaskIntoConstraints = false
		titleStackView.spacing = 6
		titleStackView.alignment = .center

		let demoSubtitleLabel = UILabel()
		demoSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		demoSubtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
		demoSubtitleLabel.text = "Size 15 Morbi urna dolor, molestie eu finibus"

		let demoTextLabel = TextViewLabel()
		demoTextLabel.translatesAutoresizingMaskIntoConstraints = false
		demoTextLabel.linkTextAttributes = [
			.underlineStyle: NSUnderlineStyle.single.rawValue
		]
		let explainerText = "Size 12 Contrast Ratio is a measure of how easily text and images can be read, especially by people with lower vision. Learn more about minimum (AA) and enhanced (AAA) contrast."
		let attributedString = NSMutableAttributedString(string: explainerText,
																										 attributes: [
																											.font: UIFont.systemFont(ofSize: 12, weight: .regular)
																										 ])
		attributedString.addAttribute(.link,
																	value: URL(string: "https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum")!,
																	range: (attributedString.string as NSString).range(of: "minimum (AA)"))
		attributedString.addAttribute(.link,
																	value: URL(string: "https://www.w3.org/WAI/WCAG21/Understanding/contrast-enhanced")!,
																	range: (attributedString.string as NSString).range(of: "enhanced (AAA)"))
		demoTextLabel.attributedText = attributedString

		demoLabels = [demoTitleLabel, demoSubtitleLabel, demoTextLabel]

		let demoStackView = UIStackView(arrangedSubviews: [titleStackView, demoSubtitleLabel, demoTextLabel])
		demoStackView.translatesAutoresizingMaskIntoConstraints = false
		demoStackView.axis = .vertical
		demoStackView.alignment = .leading
		demoStackView.spacing = 8

		demoContainerView = UIView()
		demoContainerView.translatesAutoresizingMaskIntoConstraints = false
		demoContainerView.layer.cornerRadius = 12
		if #available(iOS 13, *) {
			demoContainerView.layer.cornerCurve = .continuous
		}
		demoContainerView.addSubview(demoStackView)

		contrastRatioLabel = UILabel()
		contrastRatioLabel.translatesAutoresizingMaskIntoConstraints = false
		contrastRatioLabel.font = .systemFont(ofSize: 16, weight: .medium)

		aaComplianceLabel = AccessibilityComplianceLabel(text: "AA")
		aaaComplianceLabel = AccessibilityComplianceLabel(text: "AAA")

		let complianceStackView = UIStackView(arrangedSubviews: [aaComplianceLabel, aaaComplianceLabel])
		complianceStackView.translatesAutoresizingMaskIntoConstraints = false
		complianceStackView.spacing = 12

		contrastStackView = UIStackView(arrangedSubviews: [contrastRatioLabel, UIView(), complianceStackView])
		contrastStackView.translatesAutoresizingMaskIntoConstraints = false
		contrastStackView.spacing = 8

		backgroundSelector = AccessibilityContrastSelector(text: "Background", value: backgroundMode)
		backgroundSelector.handleChange = { self.backgroundMode = $0 }

		foregroundSelector = AccessibilityContrastSelector(text: "Foreground", value: foregroundMode)
		foregroundSelector.handleChange = { self.foregroundMode = $0 }

		scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)

		let rootStackView = UIStackView(arrangedSubviews: [demoContainerView, contrastStackView, backgroundSelector, foregroundSelector])
		rootStackView.translatesAutoresizingMaskIntoConstraints = false
		rootStackView.axis = .vertical
		rootStackView.alignment = .fill
		rootStackView.distribution = .equalSpacing
		rootStackView.spacing = 10
		scrollView.addSubview(rootStackView)

		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

			rootStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 15),
			rootStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -15),
			rootStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 15),
			rootStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -15),
			rootStackView.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor, constant: -30),
			scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			scrollView.contentLayoutGuide.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),

			demoStackView.topAnchor.constraint(equalTo: demoContainerView.topAnchor, constant: 16),
			demoStackView.bottomAnchor.constraint(equalTo: demoContainerView.bottomAnchor, constant: -17),
			demoStackView.leadingAnchor.constraint(equalTo: demoContainerView.leadingAnchor, constant: 20),
			demoStackView.trailingAnchor.constraint(equalTo: demoContainerView.trailingAnchor, constant: -20),

			contrastStackView.heightAnchor.constraint(greaterThanOrEqualTo: backgroundSelector.heightAnchor),
			contrastStackView.heightAnchor.constraint(greaterThanOrEqualTo: foregroundSelector.heightAnchor)
		])
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		scrollView.flashScrollIndicators()
	}

	override func colorDidChange() {
		let backgroundColor: Color
		let foregroundColor: Color
		switch backgroundMode {
		case .color: backgroundColor = color
		case .black: backgroundColor = .black
		case .white: backgroundColor = .white
		}
		switch foregroundMode {
		case .color: foregroundColor = color
		case .black: foregroundColor = .black
		case .white: foregroundColor = .white
		}

		if backgroundColor == foregroundColor {
			// Change one or the other to not be identical
			if backgroundMode == foregroundMode {
				switch backgroundMode {
				case .black, .white: foregroundMode = .color
				default:             foregroundMode = .white
				}
			} else {
				if foregroundMode == .color {
					backgroundMode = backgroundColor == .white ? .black : .white
				} else if backgroundMode == .color {
					foregroundMode = foregroundColor == .white ? .black : .white
				}
			}
			return
		}

		backgroundSelector.value = backgroundMode
		foregroundSelector.value = foregroundMode

		demoContainerView.backgroundColor = backgroundColor.uiColor
		demoContainerView.tintColor = foregroundColor.uiColor
		for label in demoLabels {
			if let label = label as? UILabel {
				label.textColor = foregroundColor.uiColor
			} else if let label = label as? UITextView {
				let attributedString = label.attributedText.mutableCopy() as! NSMutableAttributedString
				attributedString.addAttribute(.foregroundColor,
																			value: foregroundColor.uiColor,
																			range: NSRange(location: 0, length: attributedString.string.count))
				label.attributedText = attributedString
			}
		}

		let contrastRatio = foregroundColor.perceivedBrightness(onBackgroundColor: backgroundColor)
		contrastRatioLabel.text = "Contrast Ratio: \(String(format: "%.2f", contrastRatio)) (\(Self.percentFormatter.string(for: contrastRatio / 21)!))"
		aaComplianceLabel.isCompliant = contrastRatio > 7
		aaaComplianceLabel.isCompliant = contrastRatio > 4.5
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		contrastStackView.axis = view.frame.size.width > 300 ? .horizontal : .vertical
	}

}
