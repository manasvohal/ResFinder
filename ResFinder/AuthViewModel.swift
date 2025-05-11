import SwiftUI
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var authError: String?
    @Published var isLoading = false
    
    private var authStateSubscription: AnyCancellable?
    
    init() {
        authStateSubscription = NotificationCenter.default
            .publisher(for: .authStateDidChange)
            .compactMap { _ in Auth.auth().currentUser }
            .assign(to: \.user, on: self)
        
        // Check if user is already signed in
        self.user = Auth.auth().currentUser
        self.isAuthenticated = self.user != nil
    }
    
    func signIn(email: String, password: String) {
        self.isLoading = true
        self.authError = nil
        
        FirebaseService.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.authError = error.localizedDescription
                }
            }
        }
    }
    
    func signUp(email: String, password: String) {
        self.isLoading = true
        self.authError = nil
        
        FirebaseService.shared.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.authError = error.localizedDescription
                }
            }
        }
    }
    
    func signOut() {
        do {
            try FirebaseService.shared.signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            self.authError = error.localizedDescription
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let authStateDidChange = Notification.Name("AuthStateDidChange")
}
