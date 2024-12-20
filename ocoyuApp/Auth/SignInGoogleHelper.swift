//
//  SignInGoogleHelper.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 09/10/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift



struct GoogleSignInresultModel{
    let idToken: String
    let accessToken: String
    let name: String?
    let email: String?
}

final class SignInGoogleHelper {
    @MainActor
    func signIn()async throws ->  GoogleSignInresultModel{
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        guard let idToken  = gidSignInResult.user.idToken?.tokenString else{
            throw URLError(.badServerResponse)
        }
        let aceessToken  = gidSignInResult.user.accessToken.tokenString
        let name = gidSignInResult.user.profile?.name
        let email = gidSignInResult.user.profile?.email
        
        let tokens = GoogleSignInresultModel(idToken: idToken, accessToken: aceessToken, name: name, email: email)
        return tokens
    }
}
