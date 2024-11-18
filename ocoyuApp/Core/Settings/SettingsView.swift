////
////  SettingsView.swift
////  ocoyuApp
////
////  Created by Javier Cuatepotzo on 02/10/24.
////
//
//import SwiftUI
//
//struct SettingsView: View {
//    
//    @StateObject private var viewModel = SettingsViewModel()
//    @Binding var showSignUpView : Bool
//    @State private var isEditingName = false
//    @State private var newName = ""
//    var body: some View {
//        List{
//            Button("Log Out"){
//                Task{
//                    do{
//                        try viewModel.singOut()
//                        showSignUpView = true
//                    }catch{
//                        print(error)
//                    }
//                }
//            }
//            if let user = viewModel.user {
//                if isEditingName {
//                    TextField("Enter new name", text: $newName)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    
//                    Button("Save") {
//                        Task {
//                            try? await viewModel.updateUserName(newName: newName)
//                            isEditingName = false
//                        }
//                    }
//                } else {
//                    if let name = user.name {
//                        Text("Name: \(name)")
//                    }
//                    Button("Edit Name") {
//                        newName = user.name ?? ""
//                        isEditingName = true
//                    }
//                }
//            }
//        }
//        .task {
//            try? await viewModel.loadCurrentUser()
//        }
//        .navigationTitle("Settings")
//    }
//}
//
//#Preview {
//    NavigationStack{
//        SettingsView(showSignUpView: .constant(false))
//    }
//}
////