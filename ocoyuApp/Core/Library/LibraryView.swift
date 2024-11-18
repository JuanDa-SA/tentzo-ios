//
//  LibraryView.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 05/11/24.
//

import SwiftUI

//@MainActor
//final class LibraryViewModel: ObservableObject {
//
//}

struct LibraryView: View {
    @State private var plants: [Plant] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText: String = ""
    @State private var filteredPlants: [Plant] = []

    var body: some View {
        NavigationView {
            VStack {
                Text("Biblioteca de plantas")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 5) // Espaciado debajo del título
                
                TextField("Buscar plantas...", text: $searchText)
                    .padding()
                    .background(Color.grisTextField)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6) // Borde
                            .stroke(Color.grisStroke) // Color y ancho del borde
                    )
                    .onChange(of: searchText) { _ in
                        updateFilteredPlants()
                    }
                
                Group {
                    if isLoading {
                        VStack {
                            ProgressView("Cargando plantas...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                            Text("Por favor espera mientras cargamos la información.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    } else if let errorMessage = errorMessage {
                        VStack(spacing: 16) {
                            Text("Error")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding()
                            Button(action: {
                                loadPlants()
                            }) {
                                Text("Reintentar")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                    } else {
                        List(filteredPlants, id: \.plantId) { plant in
                            NavigationLink(destination: PlantDetailView(plant: plant)) {
                                HStack(spacing: 12) {
                                    
                                    let fallbackUrl = URL(string: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.freepik.es%2Ffotos-vectores-gratis%2Fcoral-animado%2F2&psig=AOvVaw3ueSBnwXQbocm8GVrmJ0MT&ust=1731696441816000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCIjTj-jt3YkDFQAAAAAdAAAAABAE")!
                                    let imageUrl = URL(string: plant.imageUrl) ?? fallbackUrl
                    //                        Text("Image URL: \(plant.imageUrl)")
                                            AsyncImage(url: imageUrl) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 80, height: 80)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                                        .shadow(radius: 4)
                                                case .failure:
                                                    Image(systemName: "exclamationmark.triangle")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 80, height: 80)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(plant.name)
                                            .font(.headline)
                                        if let scientificName = plant.scientificName {
                                            Text(scientificName)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
            }
            .padding(.horizontal)
//            .navigationTitle("Biblioteca de Plantas")
//            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadPlants()
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    
    private func loadPlants() {
        Task {
            do {
                plants = try await PlantManager.shared.getAllPlants()
                if plants.isEmpty {
                    try await PlantManager.shared.addSamplePlants()
                    plants = try await PlantManager.shared.getAllPlants()
                }
                updateFilteredPlants() // Actualiza la lista filtrada
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    private func updateFilteredPlants() {
        if searchText.isEmpty {
            filteredPlants = plants
        } else {
            filteredPlants = plants.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

}

struct PlantDetailView: View {
    let plant: Plant

    var body: some View {
        ScrollView { // Para manejar contenido largo
            VStack(alignment: .leading, spacing: 16) { // Espaciado para un diseño más limpio
                // Imagen representativa de la planta
                
                
                let fallbackUrl = URL(string: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.freepik.es%2Ffotos-vectores-gratis%2Fcoral-animado%2F2&psig=AOvVaw3ueSBnwXQbocm8GVrmJ0MT&ust=1731696441816000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCIjTj-jt3YkDFQAAAAAdAAAAABAE")!
                let imageUrl = URL(string: plant.imageUrl) ?? fallbackUrl
//                        Text("Image URL: \(plant.imageUrl)")
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                                    .padding(.bottom, 8)
                            case .failure:
                                Image(systemName: "exclamationmark.triangle")
                                    .resizable()
                                    .scaledToFit()
                            @unknown default:
                                EmptyView()
                            }
                        }
//                        .frame(width: 200, height: 200)
                            
                

                // Nombre común
                Text(plant.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Nombre científico
                if let scientificName = plant.scientificName {
                    Text(scientificName)
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .italic()
                }

                // Descripción
                if let description = plant.description {
                    Text(description)
                        .font(.body)
                        .lineSpacing(4)
                        .padding(.top, 8)
                }
                // Fuente e Hipervínculo
                if let urlString = plant.url, let url = URL(string: urlString) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Para mas información:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Link("Link", destination: url)
                            .font(.body)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .padding(.top, 8)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(plant.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground)) // Fondo más agradable
    }
}

#Preview {
    LibraryView()
}
