//
//  Models.swift
//  BarsPlayground
//
//  Created by Дмитрий Кузнецов on 12.03.2024.
//

import CoreGraphics

/// Модель столбца
struct Bar {
	/// Описание столбца
	let description: String

	/// Значение столбца
	let value: CGFloat

	/// Выделен ли столбец
	let isSelected: Bool
}

extension BarChartView {
	/// Конфигуратор для view
	struct ViewConfig {
		/// Конфигурация столбцов
		let barConfig: BarConfig

		/// Конфигурация текста
		let textConfig: TextConfig

		/// Конфигурация сетки значений
		let gridConfig: GridConfig

		/// Цвет фона
		let viewBackgroundColor: CGColor
	}

	/// Модель конфигурации столбцов
	struct BarConfig {
		/// Цвет столбца
		let color: CGColor

		/// Радиус закругления
		let cornerRadius: CGFloat

		/// Расстояние между столбцами
		let space: CGFloat

		/// Ширина столбцов
		let width: CGFloat
	}

	/// Модель конфигурации текста
	struct TextConfig {
		/// Размер шрифта
		let fontSize: CGFloat

		/// Цвет текста
		let color: CGColor

		/// Отступ от текста
		let offset: CGFloat
	}

	/// Модель конфигурации сетки
	struct GridConfig {
		/// Ширина линии
		let width: CGFloat

		/// Цвет линии
		let color: CGColor

		/// Отступ
		let offset: CGFloat

		/// Количество линий
		let count: Int

		/// Шаг между линиями
		let step: Int
	}
}
