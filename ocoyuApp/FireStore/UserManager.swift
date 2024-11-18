//
//  UserManager.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 20/10/24.
//

import Foundation
import FirebaseFirestore

struct Route: Codable {
    let id: String
    let name: String
    let coordinates: [GeoPoint]
    let dateCreated: Date
    var distance: Double // Distancia recorrida en kilómetros

}

struct Achievement: Codable {
    let title: String
    let description: String
    let dateAchieved: Date
}

struct DBUser: Codable{
    let userId: String
    let email: String?
    var profileImageUrl: String?
    let dateCreated: Date?
    var name: String?  // Agregar el campo de nombre
}

final class UserManager {

    
    static let shared = UserManager()
    private init() { }
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference{
        userCollection.document(userId)
    }
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }

    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
    }
    func updateUserName(userId: String, newName: String) async throws {
        try await userDocument(userId: userId).updateData(["name": newName])
    }
    func addAchievement(userId: String, achievement: Achievement) async throws {
        let achievementRef = userDocument(userId: userId).collection("achievements").document()
        try achievementRef.setData(from: achievement, encoder: encoder)
    }
    func getAchievements(userId: String) async throws -> [Achievement] {
        let snapshot = try await userDocument(userId: userId).collection("achievements").getDocuments()
        return try snapshot.documents.map { try $0.data(as: Achievement.self, decoder: decoder) }
    }
    func addRoute(userId: String, route: Route) async throws {
        let routeRef = userDocument(userId: userId).collection("routes").document()
        try routeRef.setData(from: route, encoder: encoder)
    }

    func getRoutes(userId: String) async throws -> [Route] {
        let snapshot = try await userDocument(userId: userId).collection("routes").getDocuments()
        return try snapshot.documents.map { try $0.data(as: Route.self, decoder: decoder) }
    }
    
   


}
extension UserManager {
    func updateProfileImageUrl(userId: String, imageUrl: String) async throws {
        try await userDocument(userId: userId).updateData(["profileImageUrl": imageUrl])
    }
}
