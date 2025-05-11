import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var authError: String?
    @Published var isLoading = false
    
    private var authStateSubscription: AnyCancellable?
    
    init() {
        // Print debug message
        print("AuthViewModel: Initializing")
        
        // Listen for auth state changes
        setupAuthStateListener()
        
        // Check if user is already signed in
        checkCurrentUser()
    }
    
    private func setupAuthStateListener() {
        // Use Firebase's built-in auth state listener
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
                print("AuthViewModel: Auth state changed - User: \(user?.uid ?? "nil"), isAuthenticated: \(user != nil)")
                
                // Force UI refresh
                self?.objectWillChange.send()
            }
        }
    }
    
    private func checkCurrentUser() {
        if let user = Auth.auth().currentUser {
            self.user = user
            self.isAuthenticated = true
            print("AuthViewModel: Current user found - \(user.uid)")
        } else {
            self.user = nil
            self.isAuthenticated = false
            print("AuthViewModel: No current user")
        }
    }
    
    func signIn(email: String, password: String) {
        self.isLoading = true
        self.authError = nil
        
        print("AuthViewModel: Attempting to sign in - \(email)")
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.authError = error.localizedDescription
                    print("AuthViewModel: Sign in error - \(error.localizedDescription)")
                    return
                }
                
                guard let user = result?.user else {
                    self?.authError = "Failed to get user information"
                    print("AuthViewModel: Sign in error - Failed to get user information")
                    return
                }
                
                // Explicitly set the user and authentication state
                self?.user = user
                self?.isAuthenticated = true
                print("AuthViewModel: Sign in successful - \(user.uid)")
                
                // Force UI refresh
                self?.objectWillChange.send()
            }
        }
    }
    
    func signUp(email: String, password: String) {
        self.isLoading = true
        self.authError = nil
        
        print("AuthViewModel: Attempting to sign up - \(email)")
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.authError = error.localizedDescription
                    print("AuthViewModel: Sign up error - \(error.localizedDescription)")
                    return
                }
                
                guard let user = result?.user else {
                    self?.authError = "Failed to create user"
                    print("AuthViewModel: Sign up error - Failed to create user")
                    return
                }
                
                // Create user document in Firestore
                self?.createUserDocument(userId: user.uid, email: email)
                
                // Explicitly set the user and authentication state
                self?.user = user
                self?.isAuthenticated = true
                print("AuthViewModel: Sign up successful - \(user.uid)")
                
                // Force UI refresh
                self?.objectWillChange.send()
            }
        }
    }
    
    private func createUserDocument(userId: String, email: String) {
        let userData: [String: Any] = [
            "email": email,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        Firestore.firestore().collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("AuthViewModel: Error creating user document - \(error.localizedDescription)")
            } else {
                print("AuthViewModel: User document created successfully")
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isAuthenticated = false
            print("AuthViewModel: Sign out successful")
            
            // Force UI refresh
            self.objectWillChange.send()
        } catch {
            self.authError = error.localizedDescription
            print("AuthViewModel: Sign out error - \(error.localizedDescription)")
        }
    }
    
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
}

// MARK: - For convenience
extension User {
    var displayName: String {
        return email ?? "User"
    }
}
