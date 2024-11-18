//
//  RutasView.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on 11/11/24.
//
import UIKit
import SwiftUI
import MapKit
import FirebaseFirestore

extension Route {
    var mapCoordinates: [CLLocationCoordinate2D] {
        return coordinates.map { $0.toCLLocationCoordinate2D }
    }
}
extension GeoPoint {
    var toCLLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}



//struct RutasView: View {
//    @StateObject private var viewModel = ProfileViewModel()
//    @Environment(\.dismiss) var dismiss
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if viewModel.routes.isEmpty {
//                    Text("Aún no tienes rutas")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                        .padding()
//                } else {
//                    ScrollView {
//                        VStack(spacing: 0) { // `spacing` para evitar espacios extra
//                            ForEach(viewModel.routes, id: \.id) { route in
//                                VStack() { // Imagen y texto alineados horizontalmente
//                                    
//                                    VStack(alignment: .leading) {
//                                        Text(route.name)
//                                            .font(.headline)
//                                        Text("Fecha: \(route.dateCreated.formatted())")
//                                            .font(.subheadline)
//                                            .foregroundColor(.secondary)
//                                        Text("Distancia: \(route.distance) km")
//                                            .font(.subheadline)
//                                            .foregroundColor(.secondary)
//                                    }
//                                    .padding(.leading, 8)
//                                    RouteMapView(route: route)
//                                        .frame(height: 200)
//                                        .cornerRadius(10)
//
//                                }
//                                .padding(.vertical, 15) // Espaciado entre filas
//                                
//                                Divider()
//                                    .background(Color.gray)
//                                    .padding(.horizontal, 35)
//                            }
//                        }
//                        .padding(.top) // Espacio superior para evitar colisión con la barra
//                        .frame(maxWidth: .infinity) // Centra el contenido
//                        .padding(.horizontal, 16) // Agrega margen lateral
//                    }
//                }
//            }
//            .navigationTitle("Mis Rutas")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    XMarkButton(dismiss: _dismiss)
//                }
//            }
//            .task {
//                try? await viewModel.loadCurrentUser()
//            }
//        }
//    }
//}

struct RutasView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedRoute: Route?
    @State private var isSharing = false

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.routes.isEmpty {
                    Text("Aún no tienes rutas")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.routes, id: \.id) { route in
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(route.name)
                                                .font(.headline)
                                            Text("Fecha: \(route.dateCreated.formatted())")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Text("Distancia: \(String(format: "%.2f", route.distance)) km")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.leading, 8)
                                        
                                        Spacer()
                                        
                                        // Botón para compartir
                                        Button(action: {
                                            selectedRoute = route
                                            isSharing = true
                                        }) {
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.headline)
                                                .padding()
                                        }
                                    }
                                    
                                    RouteMapView(route: route)
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                }
                                .padding(.vertical, 15)
                                
                                Divider()
                                    .background(Color.gray)
                                    .padding(.horizontal, 35)
                            }
                        }
                        .padding(.top)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle("Mis Rutas")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    XMarkButton(dismiss: _dismiss)
                }
            }
            .task {
                try? await viewModel.loadCurrentUser()
            }
            .sheet(isPresented: $isSharing) {
                if let route = selectedRoute {
                    ShareRouteView(route: route)
                }
            }
        }
    }
}
struct ShareRouteView: UIViewControllerRepresentable {
    let route: Route
    @Environment(\.dismiss) var dismiss // Permite cerrar la vista automáticamente

    func makeUIViewController(context: Context) -> UIViewController {
        let snapshotOptions = MKMapSnapshotter.Options()
        snapshotOptions.mapType = .standard
        snapshotOptions.size = CGSize(width: 800, height: 600)
        snapshotOptions.region = regionForRoute(route)
        
        let snapshotter = MKMapSnapshotter(options: snapshotOptions)
        let viewController = UIViewController()
        
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Error al generar el snapshot: \(error?.localizedDescription ?? "Desconocido")")
                return
            }
            
            let image = drawRouteOnSnapshot(snapshot: snapshot, route: route)
            
            // Mensaje personalizado
            let message = """
            🗺️ Recorrido: \(route.name)
            📅 Fecha: \(route.dateCreated.formatted())
            📏 Distancia: \(String(format: "%.2f", route.distance)) km
            """
            
            // Crear el UIActivityViewController con la imagen y el mensaje
            let activityVC = UIActivityViewController(activityItems: [message, image], applicationActivities: nil)
            
            // Detectar cuando se cierra el UIActivityViewController
            activityVC.completionWithItemsHandler = { _, _, _, _ in
                dismiss() // Cierra automáticamente la vista de compartir
            }
            
            DispatchQueue.main.async {
                viewController.present(activityVC, animated: true, completion: nil)
            }
        }
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func regionForRoute(_ route: Route) -> MKCoordinateRegion {
        guard let firstCoordinate = route.mapCoordinates.first else {
            return MKCoordinateRegion()
        }
        
        return MKCoordinateRegion(
            center: firstCoordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
    }

    func drawRouteOnSnapshot(snapshot: MKMapSnapshotter.Snapshot, route: Route) -> UIImage {
        let image = snapshot.image
        
        // Crear un contexto para dibujar
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0)
        image.draw(at: .zero)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(4.0)
        context?.setStrokeColor(UIColor.blue.cgColor)
        
        // Dibujar la ruta en el snapshot
        let points = route.mapCoordinates.map { snapshot.point(for: $0) }
        context?.beginPath()
        for (index, point) in points.enumerated() {
            if index == 0 {
                context?.move(to: point)
            } else {
                context?.addLine(to: point)
            }
        }
        context?.strokePath()
        
        // Agregar texto (mensaje)
        let text = """
        🗺️ Recorrido: \(route.name)
        📅 Fecha: \(route.dateCreated.formatted())
        📏 Distancia: \(String(format: "%.2f", route.distance)) km
        """
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24),
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.black.withAlphaComponent(0.7)
        ]
        let textRect = CGRect(x: 10, y: image.size.height - 120, width: image.size.width - 20, height: 110)
        text.draw(in: textRect, withAttributes: textAttributes)
        
        // Obtener la imagen final
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage ?? image
    }
}

struct XMarkButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
        }
    }
}



struct RouteMapView: UIViewRepresentable {
    let route: Route

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays) // Limpia las rutas anteriores

        // Configura la polyline
        let polyline = MKPolyline(coordinates: route.mapCoordinates, count: route.mapCoordinates.count)
        mapView.addOverlay(polyline)

        // Ajusta la región para que muestre toda la ruta
        if let firstCoordinate = route.mapCoordinates.first {
            let region = MKCoordinateRegion(
                center: firstCoordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            mapView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteMapView

        init(_ parent: RouteMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}


#Preview {
    RutasView()
}
