//
//  EmpDetailsAppApp.swift
//  EmpDetailsApp
//
//  Created by Geetha on 1/10/25.
//

import SwiftUI

@main
struct EmpDetailsAppApp: App {
    var body: some Scene {
        WindowGroup {
            AddEmployeeView()
                .preferredColorScheme(.light)
        }
    }
}
