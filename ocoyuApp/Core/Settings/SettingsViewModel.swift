//
//  SettingsViewModel.swift
//  ocoyuApp
//
//  Created by Sergio P on 18/10/24.
//

import Foundation

@MainActor

final class SettingsViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    func singOut() throws{
        try AuthManager.shared.signOut()
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    func updateUserName(newName: String) async throws {
        guard let userId = user?.userId else { return }
        try await UserManager.shared.updateUserName(userId: userId, newName: newName)
        self.user?.name = newName // Actualizamos el nombre en la vista también
    }
}

