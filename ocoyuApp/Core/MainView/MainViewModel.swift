//
//  SettingsViewModel.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 05/11/24.
//


//
//  SettingsViewModel.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 18/10/24.
//

import Foundation

@MainActor

final class MainViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var achievements: [Achievement] = []

    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        if let userId = user?.userId {
            achievements = try await UserManager.shared.getAchievements(userId: userId)
                }
    }
    func updateUserName(newName: String) async throws {
        guard let userId = user?.userId else { return }
        try await UserManager.shared.updateUserName(userId: userId, newName: newName)
        self.user?.name = newName // Actualizamos el nombre en la vista también
    }
}

