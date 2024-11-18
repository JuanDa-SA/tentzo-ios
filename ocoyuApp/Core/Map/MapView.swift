//
//  MapView.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 06/11/24.
//
import SwiftUI
import MapKit
import SwiftData
import FirebaseFirestore


struct MapView2: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(LocationManager.self) var locationManager
    @State private var cameraPos: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isTracking = false
    @State var showSheet: Bool = false
    @State private var showConfirmationAlert = false // Estado para controlar la alerta

    var body: some View {
        ZStack {
            Map(position: $cameraPos) {
                if isTracking && !locationManager.userLocations.isEmpty {
                    MapPolyline(coordinates: locationManager.userLocations)
                        .stroke(Color.white, lineWidth: 6)
                }
                UserAnnotation()
            }
            .mapStyle(.imagery)
            .mapControls {
                MapUserLocationButton()
            }
            .onAppear {
                updateCameraPos()
            }
            .navigationBarHidden(true)
            
            VStack {
                Spacer()
                
                // Muestra la distancia en tiempo real
                Text("Distancia: \(String(format: "%.2f", locationManager.totalDistance / 1000)) km")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(8)
                    
                HStack {
                    Button(action: startTracking) {
                        Text("Iniciar Ruta")
                            .padding()
                            .background(isTracking ? Color.gray : Color.white)
                            .foregroundColor(.verde)
                            .cornerRadius(8)
                    }
                    .disabled(isTracking)
                    
                    Button(action: {
                        showConfirmationAlert = true // Muestra la alerta al intentar detener
                    }) {
                        Text("Detener Ruta")
                            .padding()
                            .background(isTracking ? Color.red : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isTracking)
                    
                    Button(action: {
                        showSheet.toggle()
                    }, label: {
                        Text("Ver rutas anteriores")
                            .padding()
                            .background(isTracking ? Color.gray : Color.white)
                            .foregroundColor(.verde)
                            .cornerRadius(8)
                    })
                    .sheet(isPresented: $showSheet) {
                        RutasView()
                    }
                }
                .padding()
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .alert("¿Deseas terminar la ruta?", isPresented: $showConfirmationAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Terminar", role: .destructive, action: confirmStopTracking)
        }
    }

    func startTracking() {
        isTracking = true
        locationManager.startTracking()
    }

    func confirmStopTracking() {
        isTracking = false
        locationManager.stopTracking()
        
        // Almacenar ruta en Firestore
        let routeCoordinates = locationManager.userLocations.map {
            GeoPoint(latitude: $0.latitude, longitude: $0.longitude)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES")
        dateFormatter.dateFormat = "EEEE d MMMM"
        let formattedDate = dateFormatter.string(from: Date())
        let routeName = "Ruta \(formattedDate)"
        let distanceT = locationManager.totalDistance
        let distanceT2 = distanceT / 1000
        print(locationManager.totalDistance)
        let route = Route(
            id: UUID().uuidString,
            name: routeName,
            coordinates: routeCoordinates,
            dateCreated: Date(),
            distance: distanceT2
        )
        
        if let user = viewModel.user {
            Task {
                try? await UserManager.shared.addRoute(userId: user.userId, route: route)
            }
        }
        locationManager.totalDistance = 0
    }

    func updateCameraPos() {
        if let userLocation = locationManager.userLocation {
            let userRegion = MKCoordinateRegion(center: userLocation.coordinate,
                                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            withAnimation {
                cameraPos = .region(userRegion)
            }
        }
    }
}

#Preview {
    MapView2()
        .environment(LocationManager())
}


#Preview {
    MapView2()
        .environment(LocationManager())
}

