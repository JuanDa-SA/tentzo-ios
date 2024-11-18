//
//  AuthView.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 02/10/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthView: View {
    @StateObject var viewModel = AuthViewModel()
    @Binding var showSignUpView: Bool
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            Text("Bienvenido")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 130) // Espaciado debajo del título
            
            Image("launchScreen")
                .padding(.bottom, 130) // Espaciado debajo del título
            
            
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView, showSignUpView: $showSignUpView)
            } label: {
                Text("Iniciar sesión")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.verde)
                    .cornerRadius(25)
            }.padding(.bottom, 10)
            
            NavigationLink {
                SignUpEmailView(showSignUpView: $showSignUpView, showSignInView: $showSignInView)
            } label: {
                Text("Registrate")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.verde)
                    .cornerRadius(25)
            }.padding(.bottom, 10)
            
           
            
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                        showSignUpView = false
                    } catch {
                        print("error: \(error.localizedDescription)")
                    }
                }
            }) {
                HStack {
                    Image("logoGoogle")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Inicia sesión con Google")
                        .font(.headline)
                }
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 25) // Borde redondeado
                        .stroke(Color.black, lineWidth: 2) // Color y grosor del borde
                )
                .foregroundColor(.black)
                .cornerRadius(25)
            }
            Spacer()
        }
        .padding()
        .navigationBarHidden(true) // Oculta la barra de navegación
    }
}

#Preview {
    NavigationStack {
        AuthView(showSignUpView: .constant(false), showSignInView: .constant(false))
    }
}
