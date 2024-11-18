import SwiftUI
import PhotosUI
import AVFoundation
import Foundation

struct PhotoUploadView: View {
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var image: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showPermissionAlert: Bool = false
    @State private var plantIdentificationResult: String? = nil // Para mostrar los resultados

    let apiKey = "2b10qnIipXcNrH0cJCw7da4h7"

    var body: some View {
        VStack(spacing: 20) {
            Text("Sube una Fotografía")
                .font(.title)
                .fontWeight(.bold)

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .overlay(Text("Sin Foto").foregroundColor(.gray))
            }

            if let result = plantIdentificationResult {
                Text("Identificación: \(result)")
                    .font(.headline)
                    .padding()
            }

            HStack(spacing: 20) {
                Button(action: {
                    checkCameraAuthorizationStatus { granted in
                        if granted {
                            sourceType = .camera
                            showImagePicker = true
                        } else {
                            showPermissionAlert = true
                        }
                    }
                }) {
                    Text("Cámara")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }) {
                    Text("Galería")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $image) {
                // Llamar a la API cuando se selecciona una imagen
                if let imageData = $0?.jpegData(compressionQuality: 0.8) {
                    identifyPlant(imageData: imageData, apiKey: "2b10vWs3hsXEuSErvdxAoTese")
                }
            }
        }
        .alert("Permiso Requerido", isPresented: $showPermissionAlert) {
            Button("Abrir Configuración") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Por favor, habilita el acceso a la cámara en Configuración para tomar fotos.")
        }
    }

    func identifyPlant(imageData: Data, apiKey: String) {
        let url = URL(string: "https://my-api.plantnet.org/v2/identify/all")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let base64Image = imageData.base64EncodedString()
        let body: [String: Any] = [
            "api-key": apiKey,
            "images": [base64Image],
            "organs": ["leaf"]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error al serializar el cuerpo: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la solicitud: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                print("Error 401: Verifica tu clave de API")
                return
            }

            guard let data = data else {
                print("No se recibió data")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("Respuesta: \(json)")
            } catch {
                print("Error al parsear la respuesta: \(error)")
            }
        }

        task.resume()
    }

    private func checkCameraAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    var onImagePicked: ((UIImage?) -> Void)?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            parent.selectedImage = image
            parent.onImagePicked?(image)
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct PhotoUploadView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoUploadView()
    }
}
