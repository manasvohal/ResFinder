import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
}

class APIClient {
    /// Base URL of your API, now read from Config
    static var baseURL: URL { Config.apiBaseURL }

    /// Fetch the list of professors wrapped in a ProfessorsResponse
    static func fetchProfessors(
        completion: @escaping (Result<ProfessorsResponse, APIError>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("professors")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let err = error {
                print("📡 Network error:", err)
                completion(.failure(.requestFailed(err)))
                return
            }
            if let http = response as? HTTPURLResponse {
                print("📋 HTTP status code:", http.statusCode)
            }
            guard let d = data else {
                print("⚠️ No data returned from server")
                completion(.failure(.invalidURL))
                return
            }
            do {
                let resp = try JSONDecoder().decode(ProfessorsResponse.self, from: d)
                completion(.success(resp))
            } catch {
                print("❌ Decoding error:", error)
                completion(.failure(.decodingFailed(error)))
            }
        }
        .resume()
    }
}

