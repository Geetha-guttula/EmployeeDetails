//
//  AppColors.swift
//  EmployeeDetailsApp
//
//  Created by hb on 10/01/25.
//

import Foundation
import SwiftUI
enum AppColors {
    case appPrimary
    case appMint
    
    func getColor() -> Color {
        switch self {
        case .appPrimary:
            return Color("primary")
        case.appMint:
            return Color("secondary")
        }
    }
}
