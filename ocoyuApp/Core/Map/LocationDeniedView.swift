//
// Created for MyTrips
// by  Stewart Lynch on 2024-01-14
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import SwiftUI

struct LocationDeniedView: View {
    var body: some View {
        ContentUnavailableView(label: {
            Label("Permisos de localizacion", image: "launchScreen")
        },
                               description: {
            Text("""
1. Toca el botón de abajo y ve a "Privacidad y Seguridad"
2. Toca en "Servicios de Localización"
3. Localiza la aplicación "OcoNemi" y toca sobre ella
4. Cambia la configuración a "Mientras usas la app""
""")
            .multilineTextAlignment(.leading)
        },
                               actions: {
            Button(action: {
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!,
                    options: [:],
                    completionHandler: nil
                )
            }) {
                Text("Abrir ajustes")
            }
            .buttonStyle(.borderedProminent)
            .tint(.verde)
        })
    }
}

#Preview {
    LocationDeniedView()
}
