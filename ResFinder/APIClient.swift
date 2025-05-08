import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
}

class APIClient {
    /// Base URL of your Elastic Beanstalk API
    static let baseURL = "http://facultyfinder-api-env.eba-isypts53.us-east-2.elasticbeanstalk.com/api"

    /// Fetch the list of professors wrapped in a ProfessorsResponse
    static func fetchProfessors(completion: @escaping (Result<ProfessorsResponse, APIError>) -> Void) {
        // 1. Build URL
        guard let url = URL(string: "\(baseURL)/professors") else {
            completion(.failure(.invalidURL))
            return
        }

        // 2. Create data task
        URLSession.shared.dataTask(with: url) { data, response, error in
            // 2a. Network‐level errors
            if let err = error {
                print("📡 Network error:", err)
                completion(.failure(.requestFailed(err)))
                return
            }

            // 2b. HTTP status code for debugging
            if let http = response as? HTTPURLResponse {
                print("📋 HTTP status code:", http.statusCode)
            }

            // 2c. Ensure we got data back
            guard let d = data else {
                print("⚠️ No data returned from server")
                completion(.failure(.invalidURL))
                return
            }

            // 3. Decode JSON into our wrapper struct
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

