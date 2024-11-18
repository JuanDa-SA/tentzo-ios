//
//  RootView.swift
//  ocoyuApp
//
//  Created by Sergio P on 02/10/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignUpView: Bool = false
    @State private var showSignInView: Bool = false
    var body: some View {
        ZStack{
            NavigationStack{
                MainView(showSignUpView: $showSignUpView)
            }
        }
        .onAppear{
            let authUser = try? AuthManager.shared.getAuthUser()
            self.showSignUpView = authUser == nil ? true : false
    
        }
        .fullScreenCover(isPresented: $showSignUpView){
            NavigationStack{
                AuthView(showSignUpView: $showSignUpView, showSignInView: $showSignInView)
            }
           
        }
    }
}

#Preview {
    RootView()
}
