//
//  AddEmployeeView.swift
//  EmployeeDetailsApp
//
//  Created by Geetha on 10/01/25.
//

import SwiftUI

struct AddEmployeeView: View {
    @State var name: String = ""
    @State var address: String = ""
    @State var department : DepartmentModel = DepartmentModel(departmentId: 1 , departmentTitle: "Admin" )
    @State var isMale : Bool = true
    @State var isFemale : Bool = false
    @State private var isFresher = false
    @State private var showNameValidation : Bool = false
    @State private var showAdressValidation = false
    @State private var isSaved = false
    @State private var errorInSaving = false
    @State private var navigateToList: Bool = false
    @FocusState private var focusedField: InputType?
    
    @StateObject var dataBaseViewModel  = SQLiteDataBase()
    @State var departments : [DepartmentModel] = [DepartmentModel(departmentId: 1 , departmentTitle: "Admin" ), DepartmentModel(departmentId: 2 , departmentTitle: "HR" ), DepartmentModel(departmentId: 3 , departmentTitle: "Mangager" ), DepartmentModel(departmentId: 4 , departmentTitle: "Developer" ) ]
    
    init(
        
    ) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.init(red: 89 / 255, green: 13 / 255, blue: 228 / 255, alpha: 1)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment : .leading , spacing: 40 ) {
                    Spacer()
                        .frame(height: 30)
                    AppTextFiled(text: $name, placeHolder: "Employee Name", inputType:   .name, fldFocusState : _focusedField ,  isShowError: $showNameValidation)
                    AppTextFiled(text: $address, placeHolder: "Employee Address", inputType: .addess, fldFocusState : _focusedField, isShowError: $showAdressValidation)
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Select Department")
                            .foregroundStyle(.gray)
                        HStack {
                            Text("SELECT")
                                .foregroundStyle(.black)
                            Spacer()
                            DropDown(selectedOption: $department)
                        }
                    }
                    VStack (alignment: .leading , spacing: 20) {
                        Text("Gender")
                            .foregroundStyle(.gray)
                        HStack {
                            GenderView(isSelectd: $isMale, title: "Male")
                                .onChange(of: isMale) { isMale in
                                    isFemale = !isMale
                                }
                            Spacer()
                            GenderView(isSelectd: $isFemale, title: "Female")
                                .onChange(of: isFemale) { isFemale in
                                    isMale = !isFemale
                                }
                        }
                    }
                    HStack {
                        Text("Is a Fresher")
                            .foregroundStyle(.gray)
                        Spacer()
                        Toggle("", isOn: $isFresher)
                            .toggleStyle(SwitchToggleStyle(tint:  AppColors.appMint.getColor()))
                            .scaleEffect(x: 0.8, y: 0.8, anchor: .center)
                            .padding(.vertical, 4)
                    }
                    
                    if errorInSaving {
                        Text("Error in saving the employee details.")
                            .foregroundStyle(.red)
                            . font(. system(size: 12 , weight: .bold))
                    }
                    
                    HStack {
                        AppPrimaryButton(title: "SAVE") {
                            if checkValidations() {
                                saveEmployeeDetails()
                            }
                        }
                        Spacer()
                        AppPrimaryButton(title: "DISCARD") {
                            resetData()
                        }
                    }
                    EmployeeListDetailsView() {
                        navigateToList = true
                    }
                    NavigationLink(
                        destination: EmployeeListView(),
                        isActive: $navigateToList
                    ) {
                        EmptyView()
                    }
                    
                    
                    .hidden()
                    Spacer()
                }
                .padding(.horizontal , 80)
                .toolbar {
                    
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            focusedField = nil // Dismiss the keyboard
                        }
                        .tint(AppColors.appPrimary.getColor())
                    }
                }
                
            }
            .navigationTitle("Add Employee")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $isSaved) {
                Alert(title: Text("Employee Details"), message: Text( " Employee Details Successfully Added.") , dismissButton: .default(Text("Ok")))
            }
            .onReceive(dataBaseViewModel.$errorInSaving) { isError in
                errorInSaving = isError
            }
            .onReceive(dataBaseViewModel.$isDetailsSaved) { issaved in
                isSaved = issaved
            }
            
        }
    }
    
    //    MARK: Check Validations
    
    
    func checkValidations()  -> Bool{
        if name.count == 0 {
            showNameValidation = true
            return false
        } else if address.count == 0 {
            showNameValidation = false
            showAdressValidation = true
            return false
        } else {
            showNameValidation = false
            showAdressValidation = false
            return true
        }
    }
    
    //    MARK: Add Employee Details to the Database
    
    
    func saveEmployeeDetails() {
        var employeeDetails : EmployeeDetails = EmployeeDetails()
        employeeDetails.name = name
        employeeDetails.address = address
        employeeDetails.gender = isMale == true ? "Male" : "Female"
        employeeDetails.isFresher = isFresher
        employeeDetails.departmentTitle = department.departmentTitle
        print(employeeDetails)
        SQLiteDataBase.shared.insert(employee: employeeDetails)
        isSaved = true
        resetData()
        
    }
    
    //    MARK: Reset Data
    
    func resetData() {
        showNameValidation = false
        showAdressValidation = false
        name = ""
        address = ""
        isMale = true
        isFresher = false
        department = DepartmentModel(departmentId: 1 , departmentTitle: "Admin" )
    }
}

#Preview {
    AddEmployeeView()
}

//    MARK: Common App TextFiled


struct AppTextFiled : View {
    @Binding var text : String
    var placeHolder : String
    var inputType : InputType
    @FocusState  var fldFocusState: InputType?
    
    @Binding var isShowError : Bool
    var body: some View {
        VStack {
            TextField(placeHolder , text: $text)
                .focused( $fldFocusState, equals: inputType)
            Divider()
                .frame(height:  isShowError ? 2 : 1)
                .background( isShowError ? AppColors.appMint.getColor() :  Color.black.opacity(0.8))
        }
        .fldVlidation(isShowError: isShowError)
    }
}



//MARK: DropDown Department

struct DropDown: View {
    @State var data : [ DepartmentModel] = []
    @Binding var selectedOption : DepartmentModel
    var body: some View {
        VStack {
            HStack {
                Menu {
                    ForEach(data) { option in
                        Button(action: {
                            selectedOption = option
                        }) {
                            HStack {
                                Text(option.departmentTitle ?? "")
                                if selectedOption == option {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                } label: {
                    Button() {
                    }  label: {
                        HStack {
                            Text(selectedOption.departmentTitle ?? "")
                                .foregroundStyle(.gray)
                            Image(systemName: "arrowtriangle.down.fill" )
                                .tint(Color.gray)
                        }
                    }
                }
            }
        }
        .onAppear() {
            data = [DepartmentModel(departmentId: 1 , departmentTitle: "Admin" ), DepartmentModel(departmentId: 2 , departmentTitle: "HR" ), DepartmentModel(departmentId: 3 , departmentTitle: "Mangager" ), DepartmentModel(departmentId: 4 , departmentTitle: "Developer" ) ]
            
        }
    }
}

//    MARK: Gender View


struct GenderView : View {
    @Binding var isSelectd : Bool
    var title : String
    var body: some View {
        HStack {
            Button{
                isSelectd.toggle()
            } label: {
                Image(systemName:  isSelectd ? "circle.inset.filled" : "circle")
                    .resizable()
                    .frame(width: 20 , height: 20)
                
            }
            
            .tint( isSelectd ? AppColors.appMint.getColor() : .gray)
            Text(title)
        }
    }
}

//    MARK: App Primary Button


struct AppPrimaryButton: View {
    var title: String
    var showLoader: Bool = false
    var action: (() -> ())?
    @State private var isPressed = false
    
    var body: some View {
        Button {
            if let action {
                action()
            }
        } label: {
            ZStack {
                Text(title)
                    .foregroundStyle(showLoader ? .clear : .black)
                    . font(. system(size: 16 , weight: .bold))
                    .padding(.vertical, 13)
                    .frame(minWidth : 100, minHeight : 45)
                if showLoader {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.25)
                }
            }
        }
        .background(isPressed ? .gray.opacity(0.3) : .gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .animation(.easeInOut, value: isPressed)
        .disabled(showLoader)
    }
}

//    MARK: Validation Modifier


struct FldVlidation: ViewModifier {
    var isShow : Bool
    func body(content: Content) -> some View {
        VStack {
            if isShow {
                HStack(spacing: -20) {
                    content
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                }
                VStack( alignment: .trailing,  spacing : 0) {
                    
                    Divider()
                        .frame( width :  200 , height: 4)
                        .background(Color.red)
                    HStack {
                        Spacer()
                        VStack(spacing: 0) {
                            Text("FIELD CANNOT BE EMPTY")
                                .padding(.all , 7)
                                .font(.system(size: 15 , weight: .medium))
                                .foregroundStyle(.white)
                                .background(Color.black)
                        }
                    }
                }
            }else {
                content
            }
        }
    }
}

extension View {
    func fldVlidation(isShowError : Bool) -> some View {
        modifier(FldVlidation(isShow: isShowError))
    }
}

struct EmployeeListDetailsView: View {
    var buttonCallBack : (() -> Void?)?
    var body: some View {
        HStack {
            Text("For  Employee List ")
                .font(.system(size: 16 , weight: .medium))
            Button {
                buttonCallBack?()
            } label: {
                Text(makeAttributedString())
                    .font(.system(size: 16 , weight: .bold))
                    .tint(.black)
                    .padding(0)
            }
            .padding(-3)
            
        }
    }
    func makeAttributedString() -> AttributedString {
        var attributedString = AttributedString("click here")
        if let range = attributedString.range(of: "click here") {
            attributedString[range].foregroundColor = .black
            attributedString[range].underlineStyle = .single
        }
        return attributedString
    }
}


