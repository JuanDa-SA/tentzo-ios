//
//  SignInEmailView.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 02/10/24.
//

import SwiftUI
@MainActor
final class SignUpEmailViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String? = nil
    
    func signUp() async throws {
        // Verificar que los campos no estén vacíos
        guard !email.isEmpty else {
            errorMessage = "El campo de email no puede estar vacío."
            return
        }
        guard !password.isEmpty else {
            errorMessage = "El campo de contraseña no puede estar vacío."
            return
        }

        // Verificar que la contraseña cumpla con los requisitos
        guard password.count > 6 else {
            errorMessage = "La contraseña debe tener más de 6 caracteres."
            return
        }

        do {
            let authDataResult = try await AuthManager.shared.createUser(email: email, password: password)
            let user = DBUser(userId: authDataResult.uid, email: authDataResult.email, dateCreated: Date())
            try await UserManager.shared.createNewUser(user: user)
        } catch {
            errorMessage = "Error al registrarse: \(error.localizedDescription)"
        }
    }

}


struct SignUpEmailView: View {
    @StateObject private var viewModel = SignUpEmailViewModel()
    @State private var isPasswordVisible = false // Estado para controlar la visibilidad de la contraseña

    @Binding var showSignUpView: Bool
    @Binding var showSignInView: Bool
    var body: some View {
        VStack {
            Text("Registrate")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 60)

            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.90, green: 0.90, blue: 0.90))
                )

            HStack(spacing: 0) {
                if isPasswordVisible {
                    TextField("Contraseña", text: $viewModel.password)
                        .padding()
                        .background(Color.grisTextField)
                        .cornerRadius(6)
                } else {
                    SecureField("Contraseña", text: $viewModel.password)
                        .padding()
                        .background(Color.grisTextField)
                        .cornerRadius(6)
                }
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Text("Mostrar")
                        .foregroundColor(.verde)
                        .padding()
                }
                .background(Color.grisTextField)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.grisStroke)
            )
            .padding(.bottom, 30)

            // Mostrar mensaje de error
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
            }

            Button {
                Task {
                    do {
                        viewModel.errorMessage = nil
                        try await viewModel.signUp()
                        if viewModel.errorMessage == nil { // Solo cambia de vista si no hay error
                            showSignUpView = false
                            showSignInView = false
                        }
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Registrate")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.14, green: 0.49, blue: 0.23))
                    .cornerRadius(30)
                    .padding(.bottom, 30)
            }

            Spacer()
        }
//        .padding(.horizontal)
        .padding(.top, 0)
        .padding(.horizontal)// Ajustar el padding superior del VStack
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("Regístrate")
//                    .font(.system(size: 35))
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//            }
//        }
    }
}

#Preview {
    NavigationStack{
        SignUpEmailView(showSignUpView: .constant(false), showSignInView: .constant(false))
    }
    
}
