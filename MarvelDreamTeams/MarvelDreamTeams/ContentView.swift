//
//  ContentView.swift
//  MarvelDreamTeams
//
//  Created by Jordan Small on 12/2/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isSplashActive = true // State variable to manage splash screen
    @State private var showSignUp = false // State variable for navigation

    var body: some View {
        Group {
            if isSplashActive {
                SplashScreen()
            } else {
                LoginScreen(showSignUp: $showSignUp) // Pass binding to LoginScreen
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
    @Binding var showSignUp: Bool // Binding to control navigation
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
                showSignUp = true // Navigate to Sign Up screen
            }) {
                Text("Sign Up")
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showSignUp) {
                SignUpScreen(showSignUp: $showSignUp) // Present Sign Up screen with binding
            }
        }
        .padding(.top, 20) // Move everything up a little bit
        .padding(.bottom, 50) // Adjust bottom padding
        .background(Color.white) // Set background color
        .edgesIgnoringSafeArea(.all) // Ignore safe area for full screen
    }
}

struct SignUpScreen: View {
    @Binding var showSignUp: Bool // Binding to control navigation
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var termsAccepted: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.largeTitle)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 10)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 10)

            Toggle(isOn: $termsAccepted) {
                Text("I agree to the Terms of Services and Privacy Policy.")
                    .font(.footnote)
            }
            .padding()

            Button(action: {
                // Action for continue button
            }) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red) // Button color
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            HStack {
                Text("Have an Account?")
                Button(action: {
                    showSignUp = false // Dismiss Sign Up screen to go back to Sign In
                }) {
                    Text("Sign In")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 50)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
