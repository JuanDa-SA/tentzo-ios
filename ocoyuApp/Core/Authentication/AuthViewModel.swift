//
//  AuthViewModel.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 18/10/24.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject{
    func signInGoogle()async throws {
       let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(userId: authDataResult.uid, email: authDataResult.email, profileImageUrl: authDataResult.profileImageUrl?.description, dateCreated: Date() )
        try await UserManager.shared.createNewUser(user: user)
    }
}
