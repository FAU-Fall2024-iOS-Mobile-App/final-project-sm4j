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
    let thumbnail: ImageInfo
}

struct ImageInfo: Codable {
    let path: String
    let `extension`: String
    
    var url: String {
        let securedPath = path.replacingOccurrences(of: "http://", with: "https://")
        return "\(securedPath).\(`extension`)"
    }
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
    @StateObject private var teamManager = TeamManager()

    var body: some View {
        Group {
            if isSplashActive {
                SplashScreen()
            } else if isLoggedIn {
                LandingView(isLoggedIn: $isLoggedIn)
                    .environmentObject(teamManager)
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
    @State private var showScrollToTop = false
    @EnvironmentObject var teamManager: TeamManager
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                VStack {
                    if viewModel.characters.isEmpty && viewModel.isLoading {
                        ProgressView()
                    } else {
                        List {
                            Text("")
                                .frame(height: 0)
                                .id("top")
                            
                            ForEach(viewModel.characters) { character in
                                NavigationLink(destination: CharacterDetailView(character: character)) {
                                    Text(character.name)
                                        .foregroundColor(.black)
                                }
                            }
                            
                            if viewModel.hasMoreCharacters {
                                ProgressView()
                                    .onAppear {
                                        viewModel.fetchCharacters(searchText: searchText)
                                        showScrollToTop = true
                                    }
                            }
                        }
                        .listStyle(PlainListStyle())
                        
                        if showScrollToTop {
                            Button(action: {
                                withAnimation {
                                    proxy.scrollTo("top", anchor: .top)
                                    showScrollToTop = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up")
                                    Text("Back to Top")
                                }
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                            }
                            .padding(.bottom)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search Characters")
                .onChange(of: searchText, initial: false) { _, newValue in
                    if newValue.isEmpty {
                        viewModel.resetSearch()
                    } else {
                        viewModel.fetchCharacters(searchText: newValue)
                    }
                    proxy.scrollTo("top", anchor: .top)
                    showScrollToTop = false
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
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: TeamListView()) {
                            Text("Teams")
                                .foregroundColor(.red)
                        }
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

struct CharacterDetailView: View {
    let character: MarvelCharacter
    @State private var showingTeamSelection = false
    @EnvironmentObject var teamManager: TeamManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(character.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                HStack {
                    Spacer()
                    AsyncImage(url: URL(string: character.thumbnail.url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.red, lineWidth: 4))
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 200, height: 200)
                    Spacer()
                }
                .padding(.horizontal)
                
                Text("Series")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Text(character.name)
                    .font(.headline)
                    .padding(.horizontal)
                
                Text("Description")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Text(character.description.isEmpty ? "No description available." : character.description)
                    .padding(.horizontal)
                
                Button(action: {
                    showingTeamSelection = true
                }) {
                    Text("Add to Team")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .actionSheet(isPresented: $showingTeamSelection) {
                    ActionSheet(
                        title: Text("Add to Team"),
                        message: Text("Select a team to add this character to"),
                        buttons: teamManager.teams.compactMap { team in
                            team.canAddMember ?
                                .default(Text(team.name)) {
                                    teamManager.addCharacterToTeam(character: character, teamId: team.id)
                                } : nil
                        } + [.cancel()]
                    )
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Team: Identifiable {
    let id = UUID()
    var parseObjectId: String?
    var name: String
    var members: [MarvelCharacter] = []
    
    static let maxMembers = 6
    
    var canAddMember: Bool {
        members.count < Team.maxMembers
    }
}

struct CharacterCircleView: View {
    let character: MarvelCharacter
    
    var body: some View {
        AsyncImage(url: URL(string: character.thumbnail.url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ProgressView()
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.red, lineWidth: 2))
    }
}

struct EmptyCharacterSlot: View {
    var body: some View {
        Circle()
            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            .frame(width: 80, height: 80)
    }
}

struct TeamListView: View {
    @EnvironmentObject var teamManager: TeamManager
    @State private var showCreateTeam = false
    @State private var searchText = ""
    
    var filteredTeams: [Team] {
        if searchText.isEmpty {
            return teamManager.teams
        }
        return teamManager.teams.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(filteredTeams) { team in
                    NavigationLink(destination: TeamDetailView(team: team)) {
                        Text(team.name)
                            .foregroundColor(.black)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .searchable(text: $searchText, prompt: "Search Teams")
        .navigationBarTitle("Dream Teams", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showCreateTeam = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showCreateTeam) {
            CreateTeamView()
        }
    }
}

struct CreateTeamView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var teamManager: TeamManager
    @State private var teamName = ""
    @State private var termsAccepted = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Team")
                .font(.largeTitle)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
            
            TextField("Give your team a name", text: $teamName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 10)
            
            Toggle(isOn: $termsAccepted) {
                Text("I agree to the Terms of Services and Privacy Policy.")
                    .font(.footnote)
            }
            .padding()
            
            Button(action: {
                if !teamName.isEmpty && termsAccepted {
                    teamManager.addTeam(Team(name: teamName))
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(teamName.isEmpty || !termsAccepted)
        }
        .padding(.top, 20)
        .padding(.bottom, 50)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct TeamDetailView: View {
    let team: Team
    @EnvironmentObject var teamManager: TeamManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(team.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                // Top row (first 3 characters)
                CharacterRowView(characters: Array(team.members.prefix(3)))
                
                Text("Squad Breakdown")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                // Bottom row (last 3 characters, if any)
                CharacterRowView(characters: team.members.count > 3 ? 
                    Array(team.members[3..<min(6, team.members.count)]) : [])
                
                Spacer()
                
                // Buttons
                VStack(spacing: 10) {
                    Button(action: {}) {
                        Text("Add Member")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(team.canAddMember ? Color.red : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!team.canAddMember)
                    
                    Button(action: {}) {
                        Text("Delete Team")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CharacterRowView: View {
    let characters: [MarvelCharacter]
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<3) { index in
                if index < characters.count {
                    CharacterCircleView(character: characters[index])
                } else {
                    EmptyCharacterSlot()
                }
            }
        }
        .padding()
    }
}

class TeamManager: ObservableObject {
    @Published var teams: [Team] = []
    
    init() {
        fetchTeams()
    }
    
    func fetchTeams() {
        let query = ParseTeam.query()
            .include("userId")
            .order([.ascending("name")])
        
        query.find { [weak self] result in
            switch result {
            case .success(let parseTeams):
                DispatchQueue.main.async {
                    self?.teams = parseTeams.compactMap { parseTeam in
                        guard let name = parseTeam.name else { return nil }
                        var team = Team(name: name)
                        team.parseObjectId = parseTeam.objectId
                        // Convert stored member IDs back to MarvelCharacters
                        if let memberIds = parseTeam.members {
                            team.members = memberIds.compactMap { id in
                                // You might want to fetch character details from your cached data
                                // or the Marvel API here
                                nil // For now, we'll handle this later
                            }
                        }
                        return team
                    }
                }
            case .failure(let error):
                print("Error fetching teams: \(error)")
            }
        }
    }
    
    func addTeam(_ team: Team) {
        var parseTeam = ParseTeam()
        parseTeam.name = team.name
        parseTeam.members = []
        parseTeam.userId = User.current?.objectId
        
        parseTeam.save { [weak self] result in
            switch result {
            case .success(let savedTeam):
                DispatchQueue.main.async {
                    var newTeam = team
                    newTeam.parseObjectId = savedTeam.objectId
                    self?.teams.append(newTeam)
                }
            case .failure(let error):
                print("Error saving team: \(error)")
            }
        }
    }
    
    func addCharacterToTeam(character: MarvelCharacter, teamId: UUID) {
        guard let teamIndex = teams.firstIndex(where: { $0.id == teamId }),
              let parseObjectId = teams[teamIndex].parseObjectId else { return }
        
        let query = ParseTeam.query("objectId" == parseObjectId)
        
        query.first { [weak self] result in
            switch result {
            case .success(var parseTeam):
                parseTeam.members = (parseTeam.members ?? []) + [String(character.id)]
                
                parseTeam.save { saveResult in
                    switch saveResult {
                    case .success:
                        DispatchQueue.main.async {
                            self?.teams[teamIndex].members.append(character)
                        }
                    case .failure(let error):
                        print("Error saving team member: \(error)")
                    }
                }
            case .failure(let error):
                print("Error finding team: \(error)")
            }
        }
    }
}

struct ParseTeam: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var name: String?
    var members: [String]? // Store character IDs
    var userId: String? // Link to user
}

#Preview {
    ContentView()
}
