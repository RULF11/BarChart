//
//  BarChartView.swift
//  BarsPlayground
//
//  Created by Дмитрий Кузнецов on 12.03.2024.
//

import UIKit
import CoreGraphics

class BarChartView: UIScrollView {
	/// Модель столбца для отрисовки
	private struct BarViewModel {
		/// Исходная модель
		let bar: Bar

		/// Высота столбца
		let height: CGFloat
	}

	/// Конфигурация вью
	private var viewConfig: ViewConfig
	/// Модельки для отрисовки
	private var bars: [Bar]
	/// Текущий размер вью (нужно, чтобы постоянно не перерисовывать график)
	private var currentSize: CGSize?
	/// Рутовый слой ( на нем все строится)
	private lazy var rootLayer = setupRootLayer()

	init(
		viewConfig: ViewConfig,
		bars: [Bar]
	) {
		self.viewConfig = viewConfig
		self.bars = bars
		super.init(frame: .zero)
		setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		if currentSize != bounds.size {
			rootLayer.sublayers?.removeAll()
			currentSize = bounds.size
			drawBarChart()
		}
	}
}

private extension BarChartView {
	func setupRootLayer() -> CALayer {
		let rootLayer = CALayer()
		rootLayer.backgroundColor = viewConfig.viewBackgroundColor
		return rootLayer
	}

	func setupView() {
		bounces = false
		layer.addSublayer(rootLayer)
	}

	func drawBarChart() {
		let textFrames = addTextColumn(to: rootLayer)
		let barStartXPoint = textFrames.max { $0.maxX < $1.maxX }?.maxX ?? .zero
		let gridLinesOrigin = textFrames.map { CGPoint(x: $0.maxX, y: $0.midY) }
		let barViewModels = createBarViewModels(with: bars, and: gridLinesOrigin)

		draw(bars: barViewModels, startXPoint: barStartXPoint)

		let rootLayerMaxX = rootLayer.sublayers?.map { $0.frame.maxX }.max() ?? 0
		rootLayer.frame = CGRect(
			x: 0,
			y: 0,
			width: max(rootLayerMaxX, bounds.width),
			height: bounds.height
		)
		contentSize.width = max(rootLayerMaxX, bounds.width)
		addHorizontalGrid(for: gridLinesOrigin)
	}

	private func draw(bars: [BarViewModel], startXPoint: CGFloat ) {
		var previousX = startXPoint

		bars.forEach { bar in
			let xPosition = previousX
			let yPosition = bounds.height
				- viewConfig.textConfig.offset
				- viewConfig.textConfig.fontSize
				- viewConfig.textConfig.offset
				- bar.height

			let barOrigin = CGPoint(x: xPosition, y: yPosition)
			let barLayer = createBar(with: bar, at: barOrigin)
			let textLayer = createXTextLayer(with: bar, at: barLayer.frame.origin)

			rootLayer.addSublayer(textLayer)
			rootLayer.addSublayer(barLayer)

			previousX = barLayer.frame.maxX
		}
	}

	private func createBar(with barModel: BarViewModel, at point: CGPoint) -> CALayer {
		let barLayer = CALayer()
		barLayer.backgroundColor = viewConfig.barConfig.color
		barLayer.opacity = barModel.bar.isSelected ? 1 : 0.5
		barLayer.cornerRadius = viewConfig.barConfig.cornerRadius
		barLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		barLayer.frame = .init(
			x: point.x + viewConfig.barConfig.space,
			y: point.y,
			width: viewConfig.barConfig.width,
			height: barModel.height
		)

		return barLayer
	}

	private func createXTextLayer(with barModel: BarViewModel, at point: CGPoint) -> CATextLayer {
		let textLayer = getCATextLayer(text: barModel.bar.description)
		textLayer.frame = .init(
			x: point.x,
			y: point.y + barModel.height + viewConfig.textConfig.offset,
			width: viewConfig.barConfig.width,
			height: viewConfig.textConfig.fontSize
		)

		return textLayer
	}

	/// Создать слой с текстом для оси Y
	func createYTextLayer(point: CGPoint, text: String) -> CATextLayer {
		let textLayer = getCATextLayer(text: text)
		textLayer.frame.size = textLayer.preferredFrameSize()
		textLayer.frame.origin = CGPoint(
			x: point.x,
			y: point.y - textLayer.frame.size.height/2
		)

		return textLayer
	}

	/// Добавить на корневой слой вертикальные подписи слева
	///   - Returns: Метод возвращает рамки добавленных подписей
	func addTextColumn(to rootLayer: CALayer) -> [CGRect] {
		let minY = viewConfig.gridConfig.offset
		let maxY = bounds.height
			- viewConfig.textConfig.offset
			- viewConfig.textConfig.fontSize
			- viewConfig.textConfig.offset

		let height = maxY - minY
		let stepHeight = height / CGFloat(viewConfig.gridConfig.count)

		var maxWidth: CGFloat = .zero

		let textLayers = (0...viewConfig.gridConfig.count)
			.map { scaleNumber in
				let y = maxY - CGFloat(scaleNumber) * stepHeight
				let textLayer = createYTextLayer(
					point: CGPoint(x: 0, y: y),
					text: "\(scaleNumber * viewConfig.gridConfig.step)"
				)

				maxWidth = max(maxWidth, textLayer.frame.width)
				return textLayer
			}

		textLayers.forEach {
			/// Приведение всех слоев к одному самому большому размеру
			$0.frame.size.width = maxWidth
			rootLayer.addSublayer($0)
		}

		return textLayers.map { $0.frame }
	}

	func getCATextLayer(text: String) -> CATextLayer {
		let textLayer = CATextLayer()
		textLayer.alignmentMode = .center
		textLayer.string = text
		textLayer.fontSize = viewConfig.textConfig.fontSize
		textLayer.foregroundColor = viewConfig.textConfig.color

		return textLayer
	}

	func addHorizontalGrid(for startPoint: [CGPoint]) {
		startPoint.forEach {
			let endPoint = CGPoint(x: contentSize.width, y: $0.y)
			drawLine(start: $0, end: endPoint)
		}
	}

	func drawLine(start p0: CGPoint, end p1: CGPoint) {
		let shapeLayer = CAShapeLayer()
		shapeLayer.strokeColor = viewConfig.gridConfig.color
		shapeLayer.lineWidth = viewConfig.gridConfig.width
		shapeLayer.lineDashPattern = [7, 3]

		let path = CGMutablePath()
		path.addLines(between: [p0, p1])
		shapeLayer.path = path
		rootLayer.sublayers?.insert(shapeLayer, at: 0) // помещаем в подложку
	}

	/// Создание viewModel
	/// - Parameters:
	///   - bars: Модель столбоцов
	///   - gridLines: точки построения сетки
	private func createBarViewModels(with bars: [Bar], and gridLines: [CGPoint]) -> [BarViewModel] {
		let yPositions = gridLines.map { $0.y } // точки по оси Y
		let heightAvailable = (yPositions.max() ?? 0) - (yPositions.min() ?? 0)
		return bars.map {
			BarViewModel(
				bar: $0,
				height: getReducedHeight(currentHeight: $0.value, maxAvailableHeight: heightAvailable)
			)
		}
	}

	/// Расчет приведенной высоты столбца для попадания в сетку значений
	///  - Parameters:
	///   - currentHeight: текущее значение высоты
	///   - maxAvailableHeight: максимально допустимое значение высоты
	/// - Returns: Возвращает оптимальное значение высоты
	func getReducedHeight(currentHeight: CGFloat, maxAvailableHeight: CGFloat) -> CGFloat {
		// Максимальная величина сетки значений
		let gridMaxValue = viewConfig.gridConfig.step * viewConfig.gridConfig.count
		return maxAvailableHeight / CGFloat(gridMaxValue) * currentHeight
	}
}
