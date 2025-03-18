//
//  SQLiteDataBase.swift
//  EmployeeDetailsApp
//
//  Created by hb on 09/01/25.
//

import Foundation
import SQLite3


class SQLiteDataBase : ObservableObject {
    static let shared = SQLiteDataBase()
    private let dbPath: String = "employeeDetails.sqlite"
    private var db: OpaquePointer?
    
    @Published var errorInSaving : Bool = false
    @Published var isDetailsSaved : Bool = false

     init() {
        db = openDatabase()
        createTable()
    }

    private func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return nil
        }
        print("Successfully opened connection to database at \(dbPath)")
        return db
    }
    
//    MARK: CREAT SQL TABLE

    private func createTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS employee(
            id TEXT PRIMARY KEY,
            name TEXT,
            address TEXT,
            departmentId INTEGER,
            departmentTitle TEXT,
            gender TEXT,
            isFresher INTEGER
        );
        """
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Employee table created.")
            } else {
                print("Employee table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }

    //    MARK: INSERT Employee Details

    func insert(employee: EmployeeDetails) {
        let insertStatementString = """
        INSERT INTO employee (id, name, address, departmentId, departmentTitle, gender, isFresher)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (employee.id as NSString).utf8String, -1, nil)

            if let name = employee.name {
                sqlite3_bind_text(insertStatement, 2, (name as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(insertStatement, 2)
            }

            if let address = employee.address {
                sqlite3_bind_text(insertStatement, 3, (address as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(insertStatement, 3)
            }

            if let departmentId = employee.departmentId {
                sqlite3_bind_int(insertStatement, 4, Int32(departmentId))
            } else {
                sqlite3_bind_null(insertStatement, 4)
            }

            if let departmentTitle = employee.departmentTitle {
                sqlite3_bind_text(insertStatement, 5, (departmentTitle as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(insertStatement, 5)
            }

            if let gender = employee.gender {
                sqlite3_bind_text(insertStatement, 6, (gender as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(insertStatement, 6)
            }

            if let isFresher = employee.isFresher {
                sqlite3_bind_int(insertStatement, 7, isFresher ? 1 : 0)
            } else {
                sqlite3_bind_null(insertStatement, 7)
            }

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
                errorInSaving = false
                isDetailsSaved = true

            } else {
                print("Could not insert row.")
                errorInSaving = true
                isDetailsSaved = false
            }
        } else {
            print("INSERT statement could not be prepared.")
            errorInSaving = true
            isDetailsSaved = false

        }
        sqlite3_finalize(insertStatement)
    }
    
    //    MARK: FETCH Employee Details

    func fetchAllEmployees() -> [EmployeeDetails] {
        let queryStatementString = "SELECT * FROM employee;"
        var queryStatement: OpaquePointer? = nil
        var employees: [EmployeeDetails] = []

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(queryStatement, 0))
                let name = sqlite3_column_text(queryStatement, 1).map { String(cString: $0) }
                let address = sqlite3_column_text(queryStatement, 2).map { String(cString: $0) }
                let departmentId = sqlite3_column_type(queryStatement, 3) != SQLITE_NULL ? Int(sqlite3_column_int(queryStatement, 3)) : nil
                let departmentTitle = sqlite3_column_text(queryStatement, 4).map { String(cString: $0) }
                let gender = sqlite3_column_text(queryStatement, 5).map { String(cString: $0) }
                let isFresher = sqlite3_column_type(queryStatement, 6) != SQLITE_NULL ? (sqlite3_column_int(queryStatement, 6) == 1) : nil

                employees.append(EmployeeDetails(
                    id: id,
                    name: name,
                    address: address,
                    departmentId: departmentId,
                    departmentTitle: departmentTitle,
                    gender: gender,
                    isFresher: isFresher
                ))
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        sqlite3_finalize(queryStatement)
        return employees
    }
}
