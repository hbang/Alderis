//
//  ColorPickerInnerViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 12/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

extension ColorPickerTab {
	var tabClass: ColorPickerTabViewController.Type {
		switch self {
		case .swatch:  return ColorPickerSwatchViewController.self
		case .map: 		 return ColorPickerMapViewController.self
		case .sliders: return ColorPickerSlidersViewController.self
		}
	}

	var index: Int {
		Self.allCases.firstIndex(of: self)!
	}
}

internal class ColorPickerInnerViewController: UIViewController {

	weak var delegate: ColorPickerDelegate?
	let configuration: ColorPickerConfiguration
	var color: Color

	var tab: ColorPickerTab {
		get { configuration.visibleTabs[currentTab] }
		set { currentTab = configuration.visibleTabs.firstIndex(of: newValue) ?? 0 }
	}

	private var colorPicker: ColorPickerViewController {
		// swiftlint:disable:next force_cast
		parent as! ColorPickerViewController
	}

	init(delegate: ColorPickerDelegate?, configuration: ColorPickerConfiguration) {
		self.delegate = delegate
		self.configuration = configuration
		self.currentTab = 0
		self.color = Color(uiColor: configuration.color)
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private var currentTab: Int {
		didSet {
			tabDidChange(oldValue: oldValue)
		}
	}

	func setColor(_ color: Color, withSource source: ColorPickerTabViewControllerBase? = nil) {
		self.color = color
		colorDidChange(withSource: source)
	}

	private var pageViewController: UIPageViewController!
	private var tabs = [ColorPickerTabViewController]()
	private var tabsView: UISegmentedControl!
	private var oldTabButtons = [UIButton]()
	private var titleLabel: UILabel!
	private var cancelButton: DialogButton!
	private var saveButton: DialogButton!
	private var tabsBackgroundView: UIView!
	private var buttonsBackgroundView: UIView!
	private var heightConstraint: NSLayoutConstraint!
	private var backgroundView: UIView!

	override func viewDidLoad() {
		super.viewDidLoad()

		for tabType in configuration.visibleTabs {
			let tab = tabType.tabClass.init(tabDelegate: self, configuration: configuration, color: color)
			// Force the view to be initialised
			_ = tab.view
			tabs.append(tab)
		}

		view.addInteraction(UIDropInteraction(delegate: self))

		backgroundView = UIView()
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		view.addSubview(backgroundView)

		let tabsCheckerboardView = UIView()
		tabsCheckerboardView.translatesAutoresizingMaskIntoConstraints = false
		tabsCheckerboardView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		tabsCheckerboardView.backgroundColor = Assets.checkerboardPatternColor
		view.addSubview(tabsCheckerboardView)

		tabsBackgroundView = UIView()
		tabsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
		tabsBackgroundView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		view.addSubview(tabsBackgroundView)

		let topSeparatorView = SeparatorView(direction: .horizontal)
		topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
		tabsBackgroundView.addSubview(topSeparatorView)

		let buttonsCheckerboardView = UIView()
		buttonsCheckerboardView.translatesAutoresizingMaskIntoConstraints = false
		buttonsCheckerboardView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		buttonsCheckerboardView.backgroundColor = Assets.checkerboardPatternColor
		view.addSubview(buttonsCheckerboardView)

		buttonsBackgroundView = UIView()
		buttonsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
		buttonsBackgroundView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		view.addSubview(buttonsBackgroundView)

		let bottomSeparatorView = SeparatorView(direction: .horizontal)
		bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
		buttonsBackgroundView.addSubview(bottomSeparatorView)

		let titleView = UIView()
		titleView.translatesAutoresizingMaskIntoConstraints = false
		titleView.isHidden = configuration.title == nil || configuration.title!.isEmpty

		titleLabel = UILabel()
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textAlignment = .center
		titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
		titleLabel.text = configuration.title
		titleView.addSubview(titleLabel)

		let actualTabsView: UIView!
		if #available(iOS 13, *) {
			actualTabsView = UIView()
			actualTabsView.translatesAutoresizingMaskIntoConstraints = false

			tabsView = UISegmentedControl()
			tabsView.translatesAutoresizingMaskIntoConstraints = false
			tabsView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
			tabsView.addTarget(self, action: #selector(segmentControlChanged(_:)), for: .valueChanged)
			tabsView.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.35)

			for (i, tab) in tabs.enumerated() {
				tabsView.insertSegment(with: type(of: tab).image, at: i, animated: false)
			}

			actualTabsView.addSubview(tabsView)

			NSLayoutConstraint.activate([
				tabsView.leadingAnchor.constraint(equalTo: actualTabsView.leadingAnchor, constant: 4),
				tabsView.trailingAnchor.constraint(equalTo: actualTabsView.trailingAnchor, constant: -4),
				tabsView.topAnchor.constraint(equalTo: actualTabsView.topAnchor, constant: 4),
				tabsView.bottomAnchor.constraint(equalTo: actualTabsView.bottomAnchor, constant: -4)
			])
		} else {
			for (i, tab) in tabs.enumerated() {
				let button = UIButton(type: .system)
				button.translatesAutoresizingMaskIntoConstraints = false
				button.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
				button.tag = i
				button.accessibilityLabel = tab.title
				button.setImage(type(of: tab).image, for: .normal)
				button.addTarget(self, action: #selector(oldTabButtonTapped(_:)), for: .touchUpInside)
				oldTabButtons.append(button)
			}

			let oldTabsView = UIStackView(arrangedSubviews: oldTabButtons)
			oldTabsView.translatesAutoresizingMaskIntoConstraints = false
			oldTabsView.axis = .horizontal
			oldTabsView.alignment = .fill
			oldTabsView.distribution = .fillEqually
			actualTabsView = oldTabsView
		}

		actualTabsView.isHidden = !configuration.showTabs

		let pageViewContainer = UIView()
		pageViewContainer.translatesAutoresizingMaskIntoConstraints = false

		pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
		pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
		pageViewController.willMove(toParent: self)
		addChild(pageViewController)
		pageViewContainer.addSubview(pageViewController.view)

		cancelButton = DialogButton()
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		cancelButton.titleLabel!.font = .systemFont(ofSize: 17, weight: .regular)
		cancelButton.setTitle(Assets.uikitLocalize("Cancel"), for: .normal)
		cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

		saveButton = DialogButton()
		saveButton.translatesAutoresizingMaskIntoConstraints = false
		saveButton.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		saveButton.titleLabel!.font = .systemFont(ofSize: 17, weight: .semibold)
		saveButton.setTitle(Assets.uikitLocalize("Done"), for: .normal)
		saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

		let buttonSeparatorView = SeparatorView(direction: .vertical)
		buttonSeparatorView.translatesAutoresizingMaskIntoConstraints = false
		buttonsBackgroundView.addSubview(buttonSeparatorView)

		let buttonsView = UIStackView(arrangedSubviews: [ cancelButton, saveButton ])
		buttonsView.translatesAutoresizingMaskIntoConstraints = false
		buttonsView.axis = .horizontal
		buttonsView.alignment = .fill

		let mainStackView = UIStackView(arrangedSubviews: [ titleView, actualTabsView, pageViewContainer, buttonsView ])
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.axis = .vertical
		mainStackView.alignment = .fill
		mainStackView.distribution = .fill
		view.addSubview(mainStackView)

		heightConstraint = pageViewContainer.heightAnchor.constraint(equalToConstant: 0)

		let barHeight: CGFloat = 48
		let topHeight = (titleView.isHidden ? 0 : barHeight) + (actualTabsView.isHidden ? 0 : barHeight)
		let titleLabelTopOffset: CGFloat = actualTabsView.isHidden ? 0 : 3
		NSLayoutConstraint.activate([
			backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
			backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

			mainStackView.topAnchor.constraint(equalTo: view.topAnchor),
			mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

			titleView.heightAnchor.constraint(equalToConstant: barHeight),
			actualTabsView.heightAnchor.constraint(equalToConstant: barHeight),
			buttonsView.heightAnchor.constraint(equalToConstant: barHeight),

			titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: titleLabelTopOffset),
			titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
			titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),

			tabsBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
			tabsBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tabsBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tabsBackgroundView.heightAnchor.constraint(equalToConstant: topHeight),

			tabsCheckerboardView.topAnchor.constraint(equalTo: tabsBackgroundView.topAnchor),
			tabsCheckerboardView.bottomAnchor.constraint(equalTo: tabsBackgroundView.bottomAnchor),
			tabsCheckerboardView.leadingAnchor.constraint(equalTo: tabsBackgroundView.leadingAnchor),
			tabsCheckerboardView.trailingAnchor.constraint(equalTo: tabsBackgroundView.trailingAnchor),

			buttonsBackgroundView.topAnchor.constraint(equalTo: buttonsView.topAnchor),
			buttonsBackgroundView.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
			buttonsBackgroundView.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
			buttonsBackgroundView.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),

			buttonsCheckerboardView.topAnchor.constraint(equalTo: buttonsBackgroundView.topAnchor),
			buttonsCheckerboardView.bottomAnchor.constraint(equalTo: buttonsBackgroundView.bottomAnchor),
			buttonsCheckerboardView.leadingAnchor.constraint(equalTo: buttonsBackgroundView.leadingAnchor),
			buttonsCheckerboardView.trailingAnchor.constraint(equalTo: buttonsBackgroundView.trailingAnchor),

			topSeparatorView.leadingAnchor.constraint(equalTo: tabsBackgroundView.leadingAnchor),
			topSeparatorView.trailingAnchor.constraint(equalTo: tabsBackgroundView.trailingAnchor),
			topSeparatorView.bottomAnchor.constraint(equalTo: tabsBackgroundView.bottomAnchor),

			bottomSeparatorView.leadingAnchor.constraint(equalTo: buttonsBackgroundView.leadingAnchor),
			bottomSeparatorView.trailingAnchor.constraint(equalTo: buttonsBackgroundView.trailingAnchor),
			bottomSeparatorView.topAnchor.constraint(equalTo: buttonsBackgroundView.topAnchor),

			buttonSeparatorView.heightAnchor.constraint(equalToConstant: barHeight / 2),
			buttonSeparatorView.centerXAnchor.constraint(equalTo: buttonsBackgroundView.centerXAnchor),
			buttonSeparatorView.centerYAnchor.constraint(equalTo: buttonsBackgroundView.centerYAnchor),

			pageViewController.view.topAnchor.constraint(equalTo: pageViewContainer.topAnchor),
			pageViewController.view.bottomAnchor.constraint(equalTo: pageViewContainer.bottomAnchor),
			pageViewController.view.leadingAnchor.constraint(equalTo: pageViewContainer.leadingAnchor),
			pageViewController.view.trailingAnchor.constraint(equalTo: pageViewContainer.trailingAnchor),
			heightConstraint,

			cancelButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor)
		])

		colorDidChange()
		tab = configuration.initialTab
		tabsView?.selectedSegmentIndex = currentTab
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
		heightConstraint.constant = (view.frame.size.width / 12) * 10
		preferredContentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
	}

	@objc private func segmentControlChanged(_ sender: UISegmentedControl) {
		UIView.animate(withDuration: 0.2) {
			self.currentTab = self.tabsView.selectedSegmentIndex
		}
	}

	@objc private func oldTabButtonTapped(_ sender: UIButton) {
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

	private func colorDidChange(withSource source: ColorPickerTabViewControllerBase? = nil) {
		let foregroundColor: UIColor = color.isDark ? .white : .black

		view.tintColor = color.uiColor
		tabsBackgroundView.backgroundColor = color.uiColor
		buttonsBackgroundView.backgroundColor = color.uiColor
		titleLabel.textColor = foregroundColor
		cancelButton.setTitleColor(foregroundColor, for: .normal)
		saveButton.setTitleColor(foregroundColor, for: .normal)
		cancelButton.highlightBackgroundColor = foregroundColor.withAlphaComponent(0.25)
		saveButton.highlightBackgroundColor = foregroundColor.withAlphaComponent(0.25)

		if #available(iOS 13, *) {
			tabsView.setTitleTextAttributes([ .foregroundColor: foregroundColor ], for: .normal)
		} else {
			for (i, button) in oldTabButtons.enumerated() {
				button.tintColor = i == currentTab ? foregroundColor : foregroundColor.withAlphaComponent(0.6)
			}
		}

		// Even though `shouldBroadcast: false` avoids recursion if we call setColor on the callee tab,
		// doing so on ColorPickerSlidersViewController would reset `hexOptions`, leading to a buggy
		// typing experience in `hexTextField`
		for tab in tabs where tab != source {
			tab.setColor(color, shouldBroadcast: false)
		}

		backgroundView.backgroundColor = color.uiColor.withAlphaComponent(color.alpha * 0.1)
	}

	private func tabDidChange(oldValue: Int) {
		let direction: UIPageViewController.NavigationDirection = currentTab < oldValue ? .reverse : .forward
		pageViewController.setViewControllers([ tabs[currentTab] ], direction: direction, animated: true)
		colorDidChange()

		UIView.animate(withDuration: 0.2) {
			self.view.layoutIfNeeded()
		}
	}

}

extension ColorPickerInnerViewController: ColorPickerTabDelegate {

	func colorPickerTab(_ tab: ColorPickerTabViewControllerBase, didSelect color: Color) {
		self.setColor(color, withSource: tab)
	}

}

extension ColorPickerInnerViewController: UIDropInteractionDelegate {

	public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
		return session.items.count == 1 && session.canLoadObjects(ofClass: UIColor.self)
	}

	public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
		return UIDropProposal(operation: .copy)
	}

	public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
		session.loadObjects(ofClass: UIColor.self) { items in
			if let color = items.first as? UIColor {
				self.setColor(Color(uiColor: color), withSource: nil)
			}
		}
	}

}
