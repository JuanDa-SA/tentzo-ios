//
//  SignInEmailView.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 02/10/24.
//

import SwiftUI


struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    @Binding var showSignUpView: Bool
    @State private var isPasswordVisible = false
    @State private var showAlert = false // Estado para controlar la alerta
    @State private var errorMessage = "" // Mensaje de error a mostrar

    var body: some View {
        VStack {
            Text("Iniciar Sesión")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 60)

            TextField("Correo", text: $viewModel.email)
                .padding()
                .background(Color.grisTextField)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.grisStroke)
                )
                .padding(.bottom, 5)

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

            Button {
                Task {
                    do {
                        guard !viewModel.email.isEmpty, !viewModel.password.isEmpty else {
                            errorMessage = "Por favor ingresa un correo y contraseña válidos."
                            showAlert = true
                            return
                        }
                        try await viewModel.signIn()
                        showSignInView = false
                        showSignUpView = false
                    } catch {
                        errorMessage = "Error al iniciar sesión: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            } label: {
                Text("Iniciar sesión")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.14, green: 0.49, blue: 0.23))
                    .cornerRadius(30)
                    .padding(.bottom, 30)
            }

            Button {
                // Acción para "Olvidé mi contraseña"
            } label: {
                Text("Olvidé mi contraseña")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.14, green: 0.49, blue: 0.23))
            }

            Spacer()
        }
        .padding(.top, 0)
        .padding(.horizontal)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("Aceptar"))
            )
        }
    }
}


#Preview {
    NavigationStack{
        SignInEmailView(showSignInView: .constant(false), showSignUpView: .constant(false))
    }
    
}
