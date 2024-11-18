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


struct MapView3: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(LocationManager.self) var locationManager
    @State private var cameraPos: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isTracking = false // Estado del botón de seguimiento
    @State private var startTime: Date? = nil // Tiempo de inicio
    @State private var elapsedTime: TimeInterval = 0 // Tiempo transcurrido en segundos
    @State private var distanceTraveled: Double = 0 // Distancia recorrida en kilómetros
    @State private var timer: Timer? = nil
    @State var showSheet: Bool = false
    ////                let tec = CLLocationCoordinate2D(latitude: 4.622888, longitude: -74.081667)
    ////                let tecSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ////                let tecRegion = MKCoordinateRegion(center: tec, span: tecSpan)
    ////                cameraPos = .region(tecRegion)
    //                manager.requestWhenInUseAuthorization()
    //    @State private var visibleRegion : MKCoordinateRegion?
    var body: some View {
        ZStack {
            Map(position: $cameraPos) {
                if isTracking && !locationManager.userLocations.isEmpty {
                    MapPolyline(coordinates: locationManager.userLocations)
                        .stroke(Color.verde, lineWidth: 3)
                }
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
            }
            .onAppear {
                updateCameraPos()
            }
            .navigationBarHidden(true)
            
            VStack {
                Spacer()
                Text("Tiempo: \(formatElapsedTime(elapsedTime))")
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.bottom, 5)
                
                Text("Distancia: \(String(format: "%.2f", distanceTraveled)) km")
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.bottom, 20)
                
                HStack {
                    Button(action: startTracking) {
                        Text("Iniciar Ruta")
                            .padding()
                            .background(isTracking ? Color.gray : Color.verde)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(isTracking)
                    
                    Button(action: stopTracking) {
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
                            .background(isTracking ? Color.gray : Color.verde)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    })
                    .sheet(isPresented: $showSheet, content: {
                        RutasView()
                    })
                }
                .padding()
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
    }
    func startTracking() {
        isTracking = true
        locationManager.isTracking = true
        startTime = Date()
        distanceTraveled = 0 // Reiniciar la distancia

        // Inicia un temporizador para actualizar la distancia periódicamente
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            distanceTraveled = calculateDistanceTraveled()
        }
    }
    
    func stopTracking() {
        isTracking = false
        locationManager.isTracking = false
        
        if let startTime = startTime {
            elapsedTime = Date().timeIntervalSince(startTime)
        }
        
        let routeCoordinates = locationManager.userLocations.map {
            GeoPoint(latitude: $0.latitude, longitude: $0.longitude)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES")
        dateFormatter.dateFormat = "EEEE d MMMM"
        let formattedDate = dateFormatter.string(from: Date())
        let routeName = "Ruta \(formattedDate)"
        
        let route = Route(
            id: UUID().uuidString,
            name: routeName,
            coordinates: routeCoordinates,
            dateCreated: Date(),
            distance: distanceTraveled
        )
        
        if let user = viewModel.user {
            Task {
                do {
                    try await UserManager.shared.addRoute(userId: user.userId, route: route)
                    print("Ruta guardada exitosamente")
                } catch {
                    print("Error al guardar la ruta: \(error)")
                }
            }
        }
        
        locationManager.userLocations.removeAll()
    }
    
    func updateCameraPos() {
        if let userLocation = locationManager.userLocation {
            let userRegion = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            withAnimation {
                cameraPos = .region(userRegion)
            }
        }
    }
    
    func formatElapsedTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func calculateDistanceTraveled() -> Double {
        guard locationManager.userLocations.count > 1 else { return 0.0 }
        
        var totalDistance = 0.0
        
        for i in 1..<locationManager.userLocations.count {
            let start = CLLocation(latitude: locationManager.userLocations[i - 1].latitude,
                                   longitude: locationManager.userLocations[i - 1].longitude)
            let end = CLLocation(latitude: locationManager.userLocations[i].latitude,
                                 longitude: locationManager.userLocations[i].longitude)
            totalDistance += start.distance(from: end)
        }
        
        return totalDistance / 1000.0 // Convertir a kilómetros
    }
    
    
}

#Preview {
    MapView2()
        .environment(LocationManager())
}

