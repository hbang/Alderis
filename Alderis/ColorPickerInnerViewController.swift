//
//  ColorPickerInnerViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 12/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

class ColorPickerInnerViewController: UIViewController {

	private let tabClasses: [ColorPickerTabViewController.Type] = [
		ColorPickerSwatchViewController.self,
		ColorPickerMapViewController.self,
		ColorPickerSlidersViewController.self
	]

	weak var delegate: ColorPickerDelegate?
	var overrideSmartInvert: Bool
	var color: Color {
		didSet { colorDidChange() }
	}

	private var colorPicker: ColorPickerViewController {
		parent as! ColorPickerViewController
	}

	init(delegate: ColorPickerDelegate?, overrideSmartInvert: Bool, color: Color) {
		self.delegate = delegate
		self.overrideSmartInvert = overrideSmartInvert
		self.color = color
		super.init(nibName: nil, bundle: nil)
	}
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private var currentTab = 0 {
		didSet {
			tabDidChange(oldValue: oldValue)
		}
	}

	private var pageViewController: UIPageViewController!
	private var tabs: [ColorPickerTabViewController] = []
	private var tabButtons: [UIButton] = []
	private var cancelButton: UIButton!
	private var saveButton: UIButton!
	private var tabsBackgroundView: UIView!
	private var buttonsBackgroundView: UIView!
	private var heightConstraint: NSLayoutConstraint!
	private var backgroundView: UIView!

	override func viewDidLoad() {
		super.viewDidLoad()

		tabs = tabClasses.map { $0.init(tabDelegate: self, overrideSmartInvert: overrideSmartInvert, color: color) }
		tabs.forEach { _ = $0.view }

		backgroundView = UIView()
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.accessibilityIgnoresInvertColors = overrideSmartInvert
		view.addSubview(backgroundView)

		tabsBackgroundView = UIView()
		tabsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
		tabsBackgroundView.accessibilityIgnoresInvertColors = overrideSmartInvert
		view.addSubview(tabsBackgroundView)

		let topSeparatorView = ColorPickerSeparatorView(direction: .horizontal)
		topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
		tabsBackgroundView.addSubview(topSeparatorView)

		buttonsBackgroundView = UIView()
		buttonsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
		buttonsBackgroundView.accessibilityIgnoresInvertColors = overrideSmartInvert
		view.addSubview(buttonsBackgroundView)

		let bottomSeparatorView = ColorPickerSeparatorView(direction: .horizontal)
		bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
		buttonsBackgroundView.addSubview(bottomSeparatorView)

		for (i, tab) in tabs.enumerated() {
			let button = UIButton(type: .system)
			button.translatesAutoresizingMaskIntoConstraints = false
			button.accessibilityIgnoresInvertColors = overrideSmartInvert
			button.tag = i
			button.accessibilityLabel = tab.title
			button.setImage(tab.image, for: .normal)
			button.addTarget(self, action: #selector(tabButtonTapped), for: .touchUpInside)
			tabButtons.append(button)
		}

		let tabsView = UIStackView(arrangedSubviews: tabButtons)
		tabsView.translatesAutoresizingMaskIntoConstraints = false
		tabsView.axis = .horizontal
		tabsView.alignment = .fill
		tabsView.distribution = .fillEqually

		pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
		pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
		pageViewController.willMove(toParent: self)
		addChild(pageViewController)

		cancelButton = UIButton(type: .system)
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.accessibilityIgnoresInvertColors = overrideSmartInvert
		cancelButton.titleLabel!.font = .systemFont(ofSize: 17, weight: .regular)
		cancelButton.setTitle("Cancel", for: .normal)
		cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

		saveButton = UIButton(type: .system)
		saveButton.translatesAutoresizingMaskIntoConstraints = false
		saveButton.accessibilityIgnoresInvertColors = overrideSmartInvert
		saveButton.titleLabel!.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
		saveButton.setTitle("Done", for: .normal)
		saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

		let buttonSeparatorView = ColorPickerSeparatorView(direction: .vertical)
		buttonSeparatorView.translatesAutoresizingMaskIntoConstraints = false

		let buttonsView = UIStackView(arrangedSubviews: [cancelButton, buttonSeparatorView, saveButton])
		buttonsView.translatesAutoresizingMaskIntoConstraints = false
		buttonsView.axis = .horizontal
		buttonsView.alignment = .fill

		let mainStackView = UIStackView(arrangedSubviews: [tabsView, pageViewController.view, buttonsView])
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.axis = .vertical
		mainStackView.alignment = .fill
		mainStackView.distribution = .fill
		view.addSubview(mainStackView)

		heightConstraint = pageViewController.view.heightAnchor.constraint(equalToConstant: 300)
		heightConstraint.priority = .defaultHigh

		let tabsHeight: CGFloat = 44
		NSLayoutConstraint.activate([
			backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
			backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			mainStackView.topAnchor.constraint(equalTo: view.topAnchor),
			mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tabsView.heightAnchor.constraint(equalToConstant: tabsHeight),
			buttonsView.heightAnchor.constraint(equalToConstant: tabsHeight),
			tabsBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
			tabsBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tabsBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tabsBackgroundView.heightAnchor.constraint(equalToConstant: tabsHeight),
			buttonsBackgroundView.topAnchor.constraint(equalTo: buttonsView.topAnchor),
			buttonsBackgroundView.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
			buttonsBackgroundView.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
			buttonsBackgroundView.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
			topSeparatorView.leadingAnchor.constraint(equalTo: tabsBackgroundView.leadingAnchor),
			topSeparatorView.trailingAnchor.constraint(equalTo: tabsBackgroundView.trailingAnchor),
			topSeparatorView.bottomAnchor.constraint(equalTo: tabsBackgroundView.bottomAnchor),
			bottomSeparatorView.leadingAnchor.constraint(equalTo: buttonsBackgroundView.leadingAnchor),
			bottomSeparatorView.trailingAnchor.constraint(equalTo: buttonsBackgroundView.trailingAnchor),
			bottomSeparatorView.topAnchor.constraint(equalTo: buttonsBackgroundView.topAnchor),
			heightConstraint,
			cancelButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor)
		])

		colorDidChange()
		currentTab = 0
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		updateHeightConstraint()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateHeightConstraint()
	}

	override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
		super.preferredContentSizeDidChange(forChildContentContainer: container)
		updateHeightConstraint()
	}

	private func updateHeightConstraint() {
		DispatchQueue.main.async {
			self.tabs.forEach { $0.view.layoutIfNeeded() }
			let preferredHeight = self.tabs[self.currentTab].preferredContentSize.height
			if preferredHeight > 0 {
				self.heightConstraint?.constant = preferredHeight
			}
		}
	}

	@objc private func tabButtonTapped(_ sender: UIButton) {
		UIView.animate(withDuration: 0.2) {
			self.currentTab = sender.tag
		}
	}

	@objc private func cancelTapped() {
		delegate?.colorPickerDidCancel?(colorPicker)
		dismiss(animated: true)
	}

	@objc private func saveTapped() {
		delegate?.colorPicker(colorPicker, didSelect: color.uiColor)
		dismiss(animated: true)
	}

	private func colorDidChange() {
		let foregroundColor: UIColor = color.isDark ? .white : .black

		view.tintColor = color.uiColor
		tabsBackgroundView.backgroundColor = color.uiColor
		buttonsBackgroundView.backgroundColor = color.uiColor
		cancelButton.tintColor = foregroundColor
		saveButton.tintColor = foregroundColor

		for (i, button) in tabButtons.enumerated() {
			button.tintColor = foregroundColor.withAlphaComponent(i == currentTab ? 1 : 0.6)
		}

		tabs.forEach { $0.color = color }

		backgroundView.backgroundColor = color.uiColor.withAlphaComponent(0.1)
	}

	private func tabDidChange(oldValue: Int) {
		let direction: UIPageViewController.NavigationDirection = currentTab < oldValue ? .reverse : .forward
		pageViewController.setViewControllers([tabs[currentTab]], direction: direction, animated: true)
		colorDidChange()

		UIView.animate(withDuration: 0.2) {
			self.view.layoutIfNeeded()
		}
	}

}

extension ColorPickerInnerViewController: ColorPickerTabDelegate {
	func colorPicker(didSelect color: Color) {
		self.color = color
	}
}
