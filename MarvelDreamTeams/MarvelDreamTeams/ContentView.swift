import SwiftUI
import ParseSwift

// Define User Model Conforming to ParseUser
struct User: ParseUser {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String? // This is not stored in Parse, but needed for login
    var authData: [String: [String: String]?]?
}

struct ContentView: View {
    @State private var isSplashActive = true // State variable for splash screen
    @State private var showSignUp = false // State variable to control navigation
    @State private var isLoggedIn = false // State variable for login status

    var body: some View {
        Group {
            if isSplashActive {
                SplashScreen()
            } else if isLoggedIn {
                LandingView(isLoggedIn: $isLoggedIn) // Pass the binding here
            } else {
                LoginScreen(showSignUp: $showSignUp, isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            // Delay for 3 seconds before transitioning to the login screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isSplashActive = false // Hide splash screen after delay
                }
            }
        }
    }
}

// SplashScreen.swift
struct SplashScreen: View {
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 250)
                .padding(.top, 0)
            
            Text("Marvel Dream Teams")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .padding(.top, 0)
            
            Text("Your dream— your team.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 0)
        }
        .padding(.bottom, 100)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

// LoginScreen.swift
struct LoginScreen: View {
    @Binding var showSignUp: Bool // Binding to control navigation to sign-up screen
    @Binding var isLoggedIn: Bool // Binding to control login status
    @State private var email: String = "" // State variable for email input
    @State private var password: String = "" // State variable for password input
    @State private var loginError: String? // State variable for storing login error message

    var body: some View {
        VStack(spacing: 20) {
            // Logo image
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 250)
            
            Text("Sign In")
                .font(.largeTitle)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Hi there! Nice to see you again.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .padding(.horizontal, 10)
                .padding(.top, 5)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 10)
                .padding(.top, 5)
            
            Button(action: {
                login()
            }) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // Show login error message if any
            if let error = loginError {
                Text(error)
                    .foregroundColor(.red)
            }

            // Button to navigate to sign-up screen
            Button(action: {
                showSignUp = true // Navigate to Sign-Up screen
            }) {
                Text("Sign Up")
                    .foregroundColor(.blue)
            }
            // Correct usage of sheet
            .sheet(isPresented: $showSignUp, content: {
                SignUpScreen(showSignUp: $showSignUp, isLoggedIn: $isLoggedIn) // Present SignUp screen
            })
        }
        .padding(.top, 20)
        .padding(.bottom, 50)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }

    private func login() {
        // Use the login method from the ParseUser protocol
        User.login(username: email, password: password) { result in
            switch result {
            case .success:
                isLoggedIn = true // Set login status to true
                print("Login successful")
            case .failure(let error):
                loginError = error.localizedDescription // Display error message if login fails
            }
        }
    }
}

// SignUpScreen.swift
struct SignUpScreen: View {
    @Binding var showSignUp: Bool // Binding to control navigation to sign-up screen
    @Binding var isLoggedIn: Bool // Binding to control login status
    @State private var email: String = "" // State variable for email input
    @State private var password: String = "" // State variable for password input
    @State private var termsAccepted: Bool = false // State variable for terms acceptance
    @State private var signUpError: String? // State variable for storing sign-up error message

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.largeTitle)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
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
                signUp()
            }) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            if let error = signUpError {
                Text(error)
                    .foregroundColor(.red)
            }

            HStack {
                Text("Have an Account?")
                Button(action: {
                    showSignUp = false // Navigate back to sign-in screen
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

    private func signUp() {
        var newUser = User()
        newUser.username = email
        newUser.password = password
        newUser.email = email

        newUser.signup { result in
            switch result {
            case .success(let user):
                isLoggedIn = true
                print("Sign up successful for user: \(user)")
            case .failure(let error):
                signUpError = error.localizedDescription
            }
        }
    }
}

// LandingView.swift
struct LandingView: View {
    @Binding var isLoggedIn: Bool // Add a binding to control login status

    var body: some View {
        NavigationView {
            VStack {
                Text("Hello World")
                    .font(.largeTitle)
                    .padding()
            }
            .navigationBarTitle("Landing Page", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        logout()
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }

    private func logout() {
        User.logout { result in
            switch result {
            case .success:
                isLoggedIn = false // Set login status to false
                print("Logout successful")
            case .failure(let error):
                print("Logout failed: \(error.localizedDescription)")
            }
        }
    }
}

// Preview.swift
#Preview {
    ContentView()
}
