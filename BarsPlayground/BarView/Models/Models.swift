//
//  Models.swift
//  BarsPlayground
//
//  Created by Дмитрий Кузнецов on 12.03.2024.
//

import UIKit

/// Модель гистограммы
struct BarChartModel {
    /// Массив столбцов
    let bars: [Bar]
    
    /// Расстояние между столбцами
    let space: CGPoint
    
    /// Ширина столбцов
    let width: CGPoint
    
    /// Количество делений на вертикальной шкале
    let verticalScaleDivisionCount: Int
}

/// Модель столбца
struct Bar {
    /// Описание столбца
    let description: String
    
    /// Значение столбца
    let value: CGPoint
    
    /// Цвет столбца
    let color: UIColor
}

