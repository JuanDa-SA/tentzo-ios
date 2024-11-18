//
//  SignInEmailViewModel.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 18/10/24.
//

import Foundation

@MainActor
final class SignInEmailViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    
    func signIn() async throws{
        guard !email.isEmpty, !password.isEmpty else { print("No email or password found.")
            return
        }
        try await AuthManager.shared.signInUser(email: email, password: password)
                print("Logeado")
        }
    
    }
