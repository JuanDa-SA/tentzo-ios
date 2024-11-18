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


struct MapView34: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(LocationManager.self) var locationManager
    @State private var cameraPos: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isTracking = false // Estado del botón de seguimiento
    
    
    @State var showSheet: Bool = false
    ////                let tec = CLLocationCoordinate2D(latitude: 4.622888, longitude: -74.081667)
    ////                let tecSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ////                let tecRegion = MKCoordinateRegion(center: tec, span: tecSpan)
    ////                cameraPos = .region(tecRegion)
    //                manager.requestWhenInUseAuthorization()
//    @State private var visibleRegion : MKCoordinateRegion?
    var body: some View {
        ZStack {
            Map(position: $cameraPos){
                // Dibuja la ruta con MapPolyline si el seguimiento está activado
                if isTracking && !locationManager.userLocations.isEmpty {
                    MapPolyline(coordinates: locationManager.userLocations)
                        .stroke(Color.verde, lineWidth: 3)
                }
                UserAnnotation()
            }
            .mapControls{
                MapUserLocationButton()
            }
            .onAppear {
               
                updateCameraPos()
            }
            .navigationBarHidden(true)
            // Oculta la barra de navegación (toolbar)
            VStack{
                Spacer()
                HStack {
                    
                   
                   // Botón "Iniciar Seguimiento"
                   Button(action: startTracking) {
                       Text("Iniciar Ruta")
                           .padding()
                           .background(isTracking ? Color.gray : Color.verde)
                           .foregroundColor(.white)
                           .cornerRadius(8)
                   }
                   .disabled(isTracking) // Desactivado si ya está en seguimiento
                   
                   // Botón "Detener Seguimiento"
                    Button(action: {
                        stopTracking() },
                           label: {
                       Text("Detener Ruta")
                           .padding()
                           .background(isTracking ? Color.red : Color.gray)
                           .foregroundColor(.white)
                           .cornerRadius(8)
                   })
                   .disabled(!isTracking) // Desactivado si no está en seguimiento
                    
                    Button(action: {
                        showSheet.toggle()
                    }, label: {
                        Text("Ver rutas anteriores")
                            .padding()
                            .background(isTracking ? Color.gray : Color.verde)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    })
//                    .disabled(isTracking)
                    .sheet(isPresented: $showSheet ,content: {
                        RutasView()
                    })

                   
               }
                .padding()
                
            }
            
        }
        .task {
            do{
                try? await viewModel.loadCurrentUser()
//                try? await viewModel.addTestAchievement() // Agregar el logro de prueba
            }
        }
        
            
        
    }
    func startTracking() {
            isTracking = true
            locationManager.isTracking = true
        }
    
    
    func calculateDistance(from start: GeoPoint, to end: GeoPoint) -> Double {
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
        
        return startLocation.distance(from: endLocation) / 1000.0 // Convertir a kilómetros
    }
    func calculateTotalDistance(for coordinates: [GeoPoint]) -> Double {
        guard coordinates.count > 1 else { return 0.0 }
        
        var totalDistance = 0.0
        
        for i in 1..<coordinates.count {
            let previousPoint = coordinates[i - 1]
            let currentPoint = coordinates[i]
            totalDistance += calculateDistance(from: previousPoint, to: currentPoint)
        }
        
        return totalDistance
    }
    
    func stopTracking() {
        isTracking = false
        locationManager.isTracking = false

        let routeCoordinates = locationManager.userLocations.map {
            GeoPoint(latitude: $0.latitude, longitude: $0.longitude)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES") // Establece la localización en español
        dateFormatter.dateFormat = "EEEE d MMMM" // Día de la semana, número de día y mes (ejemplo: "lunes 12 noviembre")
        let formattedDate = dateFormatter.string(from: Date())

        let routeName = "Ruta \(formattedDate)"
        let route = Route(
            id: UUID().uuidString,
            name: routeName, // Puedes personalizar el nombre
            coordinates: routeCoordinates,
            dateCreated: Date()
            , distance: calculateTotalDistance(for: routeCoordinates)
        )
        
        // Guarda la ruta en Firestore
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
        
        locationManager.userLocations.removeAll() // Borra la ruta actual al detener el seguimiento
    }
        
    
    func updateCameraPos(){
        if let userLocation = locationManager.userLocation{
            let userRegion = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            withAnimation{
                cameraPos = .region(userRegion)
            }
        }
    }
}




#Preview {
    MapView2()
        .environment(LocationManager())
}

