//
//  ColorPickerCircleView.swift
//  Alderis
//
//  Created by Adam Demasi on 15/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

class ColorPickerCircleView: UIView {

	var borderColor: UIColor? {
		get { return layer.borderColor == nil ? nil : UIColor(cgColor: layer.borderColor!) }
		set { layer.borderColor = newValue?.cgColor }
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		clipsToBounds = true
		borderColor = .white
		layer.masksToBounds = false
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = .zero
		layer.shadowOpacity = 0.75
		layer.shadowRadius = 1
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = frame.size.width / 2
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()
		let scale = window?.screen.scale ?? 1
		layer.borderWidth = (scale > 2 ? 2 : 1) / scale
	}

}
