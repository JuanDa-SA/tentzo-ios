//
//  SettingsViewModel.swift
//  ocoyuApp
//
//  Created by Sergio P on 18/10/24.
//

import Foundation

import FirebaseStorage
import UIKit
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var achievements: [Achievement] = []
    @Published private(set) var routes: [Route] = []

    func singOut() throws{
        try AuthManager.shared.signOut()
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        if let userId = user?.userId {
            achievements = try await UserManager.shared.getAchievements(userId: userId)
            routes = try await UserManager.shared.getRoutes(userId: userId)
                }
    }
    func addTestAchievement() async throws {
            let testAchievement = Achievement(title: "Primer Logro", description: "Has completado tu primer desafío.", dateAchieved: Date())
            guard let userId = user?.userId else { return }
            try await UserManager.shared.addAchievement(userId: userId, achievement: testAchievement)
            achievements.append(testAchievement)  // Añadir el logro a la vista
        }
    
    func updateUserName(newName: String) async throws {
        guard let userId = user?.userId else { return }
        try await UserManager.shared.updateUserName(userId: userId, newName: newName)
        self.user?.name = newName // Actualizamos el nombre en la vista también
    }
}


extension ProfileViewModel {
    func updateProfileImage(image: UIImage) async throws {
        guard let userId = user?.userId,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let storageRef = Storage.storage().reference()
        let profileImageRef = storageRef.child("profileImages/\(userId).jpg")

        // Subir imagen a Firebase Storage
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        try await profileImageRef.putDataAsync(imageData, metadata: metadata)

        // Obtener URL de descarga
        let downloadURL = try await profileImageRef.downloadURL()

        // Actualizar el perfil del usuario con la URL de la imagen
        try await UserManager.shared.updateProfileImageUrl(userId: userId, imageUrl: downloadURL.absoluteString)

        // Actualizar la vista
        self.user?.profileImageUrl = downloadURL.relativeString
    }
}
