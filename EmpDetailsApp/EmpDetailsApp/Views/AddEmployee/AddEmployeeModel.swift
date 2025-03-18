//
//  AddEmployeeModel.swift
//  EmployeeDetailsApp
//
//  Created by Geetha on 10/01/25.
//

import Foundation
enum Gender : String {
    case male = "Male"
    case female = "Female"
}

struct EmployeeDetails  : Identifiable , Hashable{
    var id : String = UUID().uuidString
    var name : String?
    var address : String?
    var departmentId : Int?
    var departmentTitle : String?
    var gender : String?
    var isFresher : Bool?
}
struct DepartmentModel : Identifiable  , Hashable{
    var id : Int {
        return departmentId ?? 0
    }
    var departmentId : Int?
    var departmentTitle : String?
}

enum InputType {
    case name
    case addess
}
