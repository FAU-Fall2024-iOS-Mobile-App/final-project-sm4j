// Jordan Small
// Final Project
import SwiftUI
import ParseSwift
import CryptoKit

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
    var password: String?
    var authData: [String: [String: String]?]?
}

struct MarvelAPI {
    static let baseURL = "https://gateway.marvel.com/v1/public"
    static let publicKey = "d45e65b60effbd19874838d5f7ee50ca"
    static let privateKey = "09521cf884e5b25c440b4f3743c205931509b7f5"
    
    static func generateHash(timestamp: String) -> String {
        let combined = timestamp + privateKey + publicKey
        let inputData = Data(combined.utf8)
        let hashed = Insecure.MD5.hash(data: inputData)
        return hashed.map { String(format: "%02hhx", $0) }.joined()
    }
}

struct MarvelResponse: Codable {
    let data: MarvelData
}

struct MarvelData: Codable {
    let offset: Int
    let limit: Int
    let total: Int
    let count: Int
    let results: [MarvelCharacter]
}

struct MarvelCharacter: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
}

class CharacterViewModel: ObservableObject {
    @Published var characters: [MarvelCharacter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMoreCharacters = true
    
    private var offset = 0
    private let limit = 20
    
    func fetchCharacters(searchText: String = "") {
        guard !isLoading, hasMoreCharacters else { return }
        isLoading = true
        
        let timestamp = String(Date().timeIntervalSince1970)
        let hash = MarvelAPI.generateHash(timestamp: timestamp)
        
        var urlString = "\(MarvelAPI.baseURL)/characters?ts=\(timestamp)&apikey=\(MarvelAPI.publicKey)&hash=\(hash)&limit=\(limit)&offset=\(offset)"
        
        if !searchText.isEmpty {
            urlString += "&nameStartsWith=\(searchText)"
            offset = 0 // Reset offset when searching
            characters = [] // Clear existing results when searching
        }
        
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(MarvelResponse.self, from: data)
                    if searchText.isEmpty {
                        self?.characters.append(contentsOf: response.data.results)
                        self?.offset += self?.limit ?? 0
                    } else {
                        self?.characters = response.data.results
                    }
                    // Check if we've reached the end of available characters
                    self?.hasMoreCharacters = (self?.characters.count ?? 0) < response.data.total
                } catch {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
    
    func resetSearch() {
        characters = []
        offset = 0
        hasMoreCharacters = true
        fetchCharacters()
    }
}

struct ContentView: View {
    @State private var isSplashActive = true
    @State private var showSignUp = false
    @State private var isLoggedIn = false

    var body: some View {
        Group {
            if isSplashActive {
                SplashScreen()
            } else if isLoggedIn {
                LandingView(isLoggedIn: $isLoggedIn)
            } else {
                LoginScreen(showSignUp: $showSignUp, isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
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

struct LoginScreen: View {
    @Binding var showSignUp: Bool
    @Binding var isLoggedIn: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginError: String?

    var body: some View {
        VStack(spacing: 20) {
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

            if let error = loginError {
                Text(error)
                    .foregroundColor(.red)
            }

            Button(action: {
                showSignUp = true
            }) {
                Text("Sign Up")
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showSignUp, content: {
                SignUpScreen(showSignUp: $showSignUp, isLoggedIn: $isLoggedIn)
            })
        }
        .padding(.top, 20)
        .padding(.bottom, 50)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }

    private func login() {
        User.login(username: email, password: password) { result in
            switch result {
            case .success:
                isLoggedIn = true
                print("Login successful")
            case .failure(let error):
                loginError = error.localizedDescription
            }
        }
    }
}

struct SignUpScreen: View {
    @Binding var showSignUp: Bool
    @Binding var isLoggedIn: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var termsAccepted: Bool = false
    @State private var signUpError: String?

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
                    showSignUp = false
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

struct LandingView: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel = CharacterViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.characters.isEmpty && viewModel.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(viewModel.characters) { character in
                            Text(character.name)
                                .foregroundColor(.black)
                        }
                        
                        if viewModel.hasMoreCharacters {
                            ProgressView()
                                .onAppear {
                                    viewModel.fetchCharacters(searchText: searchText)
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .searchable(text: $searchText, prompt: "Search Characters")
            .onChange(of: searchText, initial: false) { _, newValue in
                if newValue.isEmpty {
                    viewModel.resetSearch()
                } else {
                    viewModel.fetchCharacters(searchText: newValue)
                }
            }
            .navigationBarTitle("Characters", displayMode: .inline)
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
        .onAppear {
            if viewModel.characters.isEmpty {
                viewModel.fetchCharacters()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private func logout() {
        User.logout { result in
            switch result {
            case .success:
                isLoggedIn = false
                print("Logout successful")
            case .failure(let error):
                print("Logout failed: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
