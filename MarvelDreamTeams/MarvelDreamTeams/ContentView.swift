//
//  ContentView.swift
//  MarvelDreamTeams
//
//  Created by Jordan Small on 12/2/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isSplashActive = true // State variable to manage splash screen

    var body: some View {
        Group {
            if isSplashActive {
                SplashScreen()
            } else {
                LoginScreen()
            }
        }
        .onAppear {
            // Delay for 3 seconds before transitioning to the login screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isSplashActive = false
                }
            }
        }
    }
}

struct SplashScreen: View {
    var body: some View {
        VStack {
            Image("logo") // Use the logo from assets
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 250) // Logo size
                .padding(.top, 0) // Set top padding to 0
            
            Text("Marvel Dream Teams")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.gray) // Text color
                .padding(.top, 0) // Set top padding to 0
            
            Text("Your dream— your team.")
                .font(.subheadline)
                .foregroundColor(.gray) // Text color
                .padding(.top, 0) // Set top padding to 0
        }
        .padding(.bottom, 100) // Bottom padding
        .background(Color.white) // Set background color
        .edgesIgnoringSafeArea(.all) // Ignore safe area for full screen
    }
}

struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Image("logo") // Use the logo from assets
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 250) // Increased logo size to 2.5x
            
            Text("Sign In")
                .font(.largeTitle)
                .foregroundColor(.black) // Unbolded "Sign In"
                .frame(maxWidth: .infinity, alignment: .center) // Centered text
            
            Text("Hi there! Nice to see you again.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center) // Centered text
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 10) // Align with text
                .padding(.top, 5) // Add some top padding
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 10) // Align with text
                .padding(.top, 5) // Add some top padding
            
            Button(action: {
                // Action for sign in button
            }) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red) // Button color
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: {
                // Action for sign up button
            }) {
                Text("Sign Up")
                    .foregroundColor(.blue)
            }
        }
        .padding(.top, 20) // Move everything up a little bit
        .padding(.bottom, 50) // Adjust bottom padding
        .background(Color.white) // Set background color
        .edgesIgnoringSafeArea(.all) // Ignore safe area for full screen
    }
}

#Preview {
    ContentView()
}
