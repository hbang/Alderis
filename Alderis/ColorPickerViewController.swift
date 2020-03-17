//
//  ColorPickerViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 12/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

@objc(HBColorPickerViewController)
open class ColorPickerViewController: UIViewController {

	weak var delegate: ColorPickerDelegate? {
		didSet {
			innerViewController?.delegate = delegate
		}
	}
	var overrideSmartInvert = true {
		didSet {
			innerViewController?.overrideSmartInvert = overrideSmartInvert
		}
	}

	private var innerViewController: ColorPickerInnerViewController!
	private var backgroundView: UIVisualEffectView!
	private var widthLayoutConstraint: NSLayoutConstraint!
	private var bottomLayoutConstraint: NSLayoutConstraint!

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
		modalPresentationStyle = .overCurrentContext
	}

	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override open func viewDidLoad() {
		super.viewDidLoad()

		navigationController?.isNavigationBarHidden = true
		view.backgroundColor = UIColor(white: 0, alpha: 0.2)

		let containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(containerView)

		backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.clipsToBounds = true
		if #available(iOS 13, *) {
			backgroundView.layer.cornerRadius = 13
			backgroundView.layer.cornerCurve = .continuous
		} else {
			backgroundView._continuousCornerRadius = 13
		}
		containerView.addSubview(backgroundView)

		innerViewController = ColorPickerInnerViewController()
		innerViewController.willMove(toParent: self)
		addChild(innerViewController)
		innerViewController.view.translatesAutoresizingMaskIntoConstraints = false
		innerViewController.view.clipsToBounds = true
		if #available(iOS 13, *) {
			innerViewController.view.layer.cornerRadius = 13
			innerViewController.view.layer.cornerCurve = .continuous
		} else {
			innerViewController.view._continuousCornerRadius = 13
		}
		containerView.addSubview(innerViewController.view)

		var layoutGuide = view as LayoutGuide
		if #available(iOS 11, *) {
			layoutGuide = view.safeAreaLayoutGuide
		}

		// Find a width divisible by 12 (the number of items wide in the swatch).
		var finalWidth = min(384, view.frame.size.width - 30)
		while finalWidth.truncatingRemainder(dividingBy: 12) != 0 {
			finalWidth -= 1
		}
		widthLayoutConstraint = containerView.widthAnchor.constraint(equalToConstant: finalWidth)
		bottomLayoutConstraint = layoutGuide.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 15)

		NSLayoutConstraint.activate([
			containerView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
			widthLayoutConstraint,
			bottomLayoutConstraint,
			backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
			backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			innerViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			innerViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			innerViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
			innerViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
		])
	}

	override open func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		// Find a width divisible by 12 (the number of items wide in the swatch).
		var finalWidth = min(384, view.frame.size.width - 30)
		while finalWidth.truncatingRemainder(dividingBy: 12) != 0 {
			finalWidth -= 1
		}
		widthLayoutConstraint.constant = finalWidth
	}

	override open func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if animated {
			view.backgroundColor = view.backgroundColor!.withAlphaComponent(0)
			UIView.animate(withDuration: 0.3) {
				self.view.backgroundColor = self.view.backgroundColor!.withAlphaComponent(0.2)
			}
		}
	}

	override open func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardFrameWillChange(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardFrameWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardFrameWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}

	override open func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

		if animated {
			UIView.animate(withDuration: 0.3) {
				self.view.backgroundColor = self.view.backgroundColor!.withAlphaComponent(0)
			}
		}
	}

	@objc private func keyboardFrameWillChange(_ notification: Notification) {
		let isHiding = notification.name == UIResponder.keyboardWillHideNotification
		let keyboardEndFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
		let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
		let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
		let options = UIView.AnimationOptions(rawValue: (curve << 16) + UIView.AnimationOptions.beginFromCurrentState.rawValue)

		bottomLayoutConstraint.constant = max(isHiding ? 0 : keyboardEndFrame.size.height, 30)
		UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
	}

}
