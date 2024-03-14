//
//  ViewController.swift
//  BarsPlayground
//
//  Created by Дмитрий Кузнецов on 12.03.2024.
//

import UIKit

class ViewController: UIViewController {

	let barView = BarChartView(viewConfig: .get(), bars: Bar.getModel())

	lazy var height: NSLayoutConstraint = barView.heightAnchor.constraint(equalToConstant: 350)
	lazy var width: NSLayoutConstraint = barView.widthAnchor.constraint(equalToConstant: 350)

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(barView)
		barView.layer.cornerRadius = 12
		barView.translatesAutoresizingMaskIntoConstraints = false
		setupBaseConstraints()
		setupSizeConstraint(size: CGSize(width: 350, height: 350))

		DispatchQueue.main.asyncAfter(deadline: .now()+10) {
			self.setupSizeConstraint(size: CGSize(width: 300, height: 350))
		}
	}

	func setupSizeConstraint(size: CGSize) {
		NSLayoutConstraint.deactivate([
			width,
			height
		])

		width = barView.widthAnchor.constraint(equalToConstant: size.width)
		height = barView.heightAnchor.constraint(equalToConstant: size.height)

		NSLayoutConstraint.activate([
			width,
			height
		])
	}

	func setupBaseConstraints() {
		NSLayoutConstraint.activate([
			view.centerXAnchor.constraint(equalTo: barView.centerXAnchor),
			view.centerYAnchor.constraint(equalTo: barView.centerYAnchor)
		])
	}
}

extension BarChartView.ViewConfig {
	static func get() -> BarChartView.ViewConfig {
		let barConfig = BarChartView.BarConfig(
			color: CGColor(red: 0.5, green: 0, blue: 0.5, alpha: 1),
			cornerRadius: 15,
			space: 8,
			width: 32
		)
		
		let textConfig = BarChartView.TextConfig(
			fontSize: 14,
			color: .init(red: 0, green: 0, blue: 0, alpha: 1),
			offset: 8
		)

		let gridConfig = BarChartView.GridConfig(
			width: 1,
			color: UIColor.gray.cgColor,
			offset: 20,
			count: 5,
			step: 50
		)

		return BarChartView.ViewConfig(
			barConfig: barConfig,
			textConfig: textConfig,
			gridConfig: gridConfig,
			viewBackgroundColor: CGColor(gray: 0.90, alpha: 0.7)
		)
	}
}

extension Bar {
	static func getModel() -> [Bar] {
		[
			Bar(description: "150", value: 150, isSelected: true),
			Bar(description: "25", value: 25, isSelected: false),
			Bar(description: "50", value: 50, isSelected: false),
			Bar(description: "100", value: 100, isSelected: false),
			Bar(description: "10", value: 10, isSelected: false),
			Bar(description: "36", value: 36, isSelected: false),
			Bar(description: "200", value: 200, isSelected: true),
			Bar(description: "33", value: 33, isSelected: false),
		]
	}
}
