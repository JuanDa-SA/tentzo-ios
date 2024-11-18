import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignUpView: Bool
    @State private var isEditingName = false
    @State private var newName = ""
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Imagen de portada
            Image("cover")
                .resizable()
                .frame(height: 200)
                .ignoresSafeArea()

            VStack(alignment: .center, spacing: 4) {
                // Imagen de perfil
                HStack {
                    Spacer()
                    ZStack {
                        if let selectedImage = selectedImage {
                            // Mostrar la imagen seleccionada por el usuario
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .clipShape(Circle())
                                .padding(4)
                                .background(Circle().foregroundStyle(.background))
                        } else if let profileImageUrl = viewModel.user?.profileImageUrl,
                                  let url = URL(string: profileImageUrl) {
                            // Mostrar la imagen descargada desde Firebase Storage
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                            }
                        }

                        // Botón para editar imagen
                        if isEditingName {
                            Button(action: {
                                isShowingImagePicker = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .background(Circle().foregroundColor(.white))
                                    .offset(x: 50, y: 50)
                            }
                        }
                    }
                    Spacer()
                }.padding(.bottom, 30) // Agregar más espacio debajo de la imagen de perfil

                // Nombre del usuario
                HStack {
                    Spacer()
                    if let user = viewModel.user {
                        if isEditingName {
                            TextField("Escribe tu nombre aquí...", text: $newName)
                                .font(.system(size: 32, weight: .semibold))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(user.name ?? "Sin nombre")
                                .font(.system(size: 30, weight: .bold))
                                .offset(y: -20)
                        }
                    }
                    Spacer()
                }

                // Sección de logros
                HStack {
                    Spacer()
                    Text("Logros")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(12)
                .background(Color(red: 0x24 / 255, green: 0x7E / 255, blue: 0x3D / 255))
                .padding(.horizontal, 20)
                .padding(.bottom, 15)

                // Lista de logros
                if viewModel.achievements.isEmpty {
                    Text("Aún no tienes logros")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.achievements, id: \.title) { achievement in
                        HStack {
                            Image("logo_logros")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text(achievement.title)
                                    .font(.headline)
                                Text(achievement.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 8)
                        }
                        .padding(.vertical, 15)
                        Divider()
                            .background(Color.gray)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 35)
                    }
                }

                Spacer()
            }
        }
        .toolbar {
            // Botón para guardar o editar
            ToolbarItem(placement: .navigationBarLeading) {
                if isEditingName {
                    Button("Guardar") {
                        Task {
                            if let image = selectedImage {
                                try? await viewModel.updateProfileImage(image: image)
                            }
                            try? await viewModel.updateUserName(newName: newName)
                            isEditingName = false
                        }
                    }.foregroundColor(.white)
                } else {
                    if let user = viewModel.user {
                        Button("Editar") {
                            newName = user.name ?? ""
                            isEditingName = true
//                            isShowingImagePicker = true // Abre el selector de imágenes
                        }.foregroundColor(.white)
                    }
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Usuario")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
            }

            // Botón para cerrar sesión
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cerrar sesión") {
                    Task {
                        try? viewModel.singOut()
                        showSignUpView = true
                    }
                }
                .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker3( selectedImage: $selectedImage) {
                if selectedImage != nil {
                    print("Imagen seleccionada: Lista para subir")
                }
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
    }
}




struct ImagePicker3: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onDismiss: (() -> Void)?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker3

        init(_ parent: ImagePicker3) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true) {
                self.parent.onDismiss?()
            }

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { object, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = object as? UIImage
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignUpView: .constant(false))
    }
}

