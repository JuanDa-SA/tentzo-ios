import SwiftUI



struct MainView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignUpView: Bool
    @State private var selectedTab: Int = 3 // Cambia a 3 para que inicie en ProfileView
    
    @State private var isEditingName = false
    @State private var newName = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            Group{
                    LibraryView()
                
             
                    .tabItem {
                        Label("Biblioteca", systemImage: "book.closed")
                    }
                    .tag(0)
                MapView2()
                    .tabItem {
                        Label("Mapa", systemImage: "map")
//                        VStack {
//                            Image(systemName: "map")
//                                .font(.system(size: 24))
//                            Text("Mapa")
//                                .font(.caption)
//                        }
                    }
                    .tag(1)
                
                PlantIdentificationView3()
                
                    .tabItem {
                        Label("Identificar flora", systemImage: "camera")
//                        VStack {
//                            Image(systemName: "camera")
//                                .font(.system(size: 24))
//                            Text("Identificar flora")
//                                .font(.caption)
//                        }
                    }
                    .tag(2)

                // Encierra ProfileView en un NavigationView
                NavigationView {
                    ProfileView(showSignUpView: $showSignUpView)
//                    LibraryView()
                
                        
                }
//                MapView2()
                    .tabItem {
                        Label("Perfil", systemImage: "person.fill")
                    }
                .tag(3)
            }// Asegúrate de usar la propiedad `selectedTab`
            .toolbarBackground(Color(red: 233 / 255, green: 244 / 255, blue: 202 / 255).opacity(1), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.light, for: .tabBar)
           
        }
//        .tint(Color(UIColor(red: 0x24 / 255, green: 0x7E / 255, blue: 0x3D / 255, alpha: 1.0)))
//        .onAppear(perform: {
//            UITabBar.appearance().unselectedItemTintColor = UIColor(red: 72/255, green: 76/255, blue: 82/255, alpha: 1.0)
//            UITabBarItem.appearance().badgeColor = UIColor(red: 0x24 / 255, green: 0x7E / 255, blue: 0x3D / 255, alpha: 1.0)
//            UITabBar.appearance().backgroundColor = UIColor(red: 233/255, green: 244/255, blue: 202/255, alpha: 1.0)
//            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(red: 0x24 / 255, green: 0x7E / 255, blue: 0x3D / 255, alpha: 1.0)]
//        })
        
    }
}

struct HomeView: View {
    var body: some View {
        Text("Bienvenido a la pantalla de inicio")
            .font(.title)
            .padding()
    }
}



#Preview {
    MainView(showSignUpView: .constant(false))
}

