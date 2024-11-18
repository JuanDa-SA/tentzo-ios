import SwiftUI
import PhotosUI


struct PlantIdentificationView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var organ: String = "flower" // Tipo de órgano seleccionado por defecto
    @State private var identificationResult: String = ""
    @State private var isLoading: Bool = false
    @State private var showCamera: Bool = false // Estado para mostrar la cámara
    @State private var capturedImage: UIImage? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Identificar Planta")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.top)

                // Imagen seleccionada o capturada
                Group {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    } else if let capturedImage {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Text("Sin imagen seleccionada")
                                    .foregroundColor(.gray)
                                    .font(.headline)
                            )
                    }
                }
                .padding(.horizontal)

                // Botones para selección o captura de imagen
                HStack(spacing: 20) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Seleccionar Imagen", systemImage: "photo")
                            .padding()
                            .background(Color.verde)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }

                    Button(action: {
                        showCamera = true
                    }) {
                        Label("Tomar Fotografía", systemImage: "camera")
                            .padding()
                            .background(Color.verde)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                // Botón para identificar planta
                if isLoading {
                    ProgressView("Identificando...")
                        .padding()
                } else {
                    Button(action: {
                        if let imageData = selectedImageData {
                            identifyPlant(imageData: imageData, organ: organ)
                        } else if let capturedImageData = capturedImage?.jpegData(compressionQuality: 0.8) {
                            identifyPlant(imageData: capturedImageData, organ: organ)
                        } else {
                            identificationResult = "Error: No se ha seleccionado ninguna imagen."
                        }
                    }) {
                        Text("Identificar Planta")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.verde)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }

                // Resultados de la identificación
                ScrollView {
                    Text(identificationResult)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 4)
                }
                .frame(maxHeight: 200)
                .padding(.horizontal)
            }
            .padding()
//            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showCamera) {
                ImagePicker2(image: $capturedImage)
            }
        }
    }
    
    
    func parseIdentificationResults(data: Data) -> String {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let results = json["results"] as? [[String: Any]] {
                
                let topResults = results.prefix(10) // Obtener los 10 primeros resultados
                
                var resultString = "Top 10 Identification Results:\n\n"
                
                for (index, result) in topResults.enumerated() {
                    if let score = result["score"] as? Double,
                       let species = result["species"] as? [String: Any],
                       let scientificName = species["scientificNameWithoutAuthor"] as? String,
                       let commonNames = species["commonNames"] as? [String] {
                        let commonNamesString = commonNames.joined(separator: ", ")
                        resultString += """
                        \(index + 1). \(scientificName)
                        - Common Names: \(commonNamesString)
                        - Score: \(String(format: "%.2f", score))
                        
                        """
                    }
                }
                return resultString
            } else {
                return "Error: Unable to parse results."
            }
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }


    func identifyPlant(imageData: Data, organ: String) {
        isLoading = true

        let apiKey = "2b10vWs3hsXEuSErvdxAoTese"
        let url = URL(string: "https://my-api.plantnet.org/v2/identify/all?api-key=\(apiKey)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Agregar el órgano
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"organs\"\r\n\r\n")
        body.append("\(organ)\r\n")

        // Agregar la imagen
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image.jpeg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    identificationResult = "Error: \(error.localizedDescription)"
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    identificationResult = "Error: Invalid response."
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    identificationResult = "Error: No data received."
                }
                return
            }

            DispatchQueue.main.async {
                identificationResult = parseIdentificationResults(data: data)
            }
        }.resume()
    }
}
//
//extension Data {
//    mutating func append(_ string: String) {
//        if let data = string.data(using: .utf8) {
//            append(data)
//        }
//    }
//}


// Componente ImagePicker para capturar fotos
struct ImagePicker2: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker2

        init(parent: ImagePicker2) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct PlantIdentificationView_Previews: PreviewProvider {
    static var previews: some View {
        PlantIdentificationView()
    }
}


