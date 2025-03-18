//
//  EmployeeListView.swift
//  EmployeeDetailsApp
//
//  Created by Geetha on 09/01/25.
//

import SwiftUI
struct EmployeeListView: View {
    @State var employeeList: [EmployeeDetails] = []

    var body: some View {
        VStack(alignment: .leading) {
            Text("Employee List")
                .font(.system(size: 25, weight: .bold))
                .padding(.bottom, 10)

            if employeeList.isEmpty {
                NodataView()
            } else {
                List {
                    ForEach(employeeList) { employee in
                        EmployeeListItemRow(item: employee)
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 5)
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .onAppear {
            employeeList = SQLiteDataBase.shared.fetchAllEmployees()
        }
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    EmployeeListView()
}

struct NodataView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No employee data found. Add employee details to see the list.")
                .multilineTextAlignment(.center)
                .font(.system(size: 14, weight: .bold))
                .padding()
            Spacer()
        }
    }
}

struct EmployeeListItemRow: View {
    var item: EmployeeDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(item.name ?? "")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text(item.departmentTitle ?? "")
                    .font(.system(size: 16, weight: .bold))
            }

            HStack {
                Text("Address:")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Text(item.address ?? "")
                    .font(.system(size: 16, weight: .bold))
            }

            HStack {
                Text("Gender:")
                    .font(.system(size: 16, weight: .medium))
                +
                Text(item.gender ?? "")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text("Fresher:")
                    .font(.system(size: 16, weight: .medium))
                +
                Text(item.isFresher ?? false ? "True" : "False")
                    .font(.system(size: 16, weight: .bold))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}
