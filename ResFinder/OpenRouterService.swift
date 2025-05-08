import Foundation

class OpenRouterService {
  static let shared = OpenRouterService()
  private let apiKey = Bundle.main
    .object(forInfoDictionaryKey: "OPENROUTER_API_KEY") as? String ?? ""

  /// Generates an email body via OpenRouter
  func generateEmailBody(for researchAreas: [String],
                         completion: @escaping (Result<String, Error>) -> Void) {
    // 1) Build chat payload
    let messages: [[String:String]] = [
      ["role":"system","content":"You are a helpful assistant that writes professional emails."],
      ["role":"user","content":
        "Compose a concise, polite email to a university professor about their research in " +
        researchAreas.joined(separator: ", ") +
        ". Introduce yourself, express genuine interest, and ask for next steps."
      ]
    ]

    let bodyJson: [String:Any] = [
      "model": "gpt-3.5-turbo",        // or "gpt-4o-mini" if your key allows
      "messages": messages,
      "max_tokens": 300
    ]

    guard
      let url = URL(string: "https://openrouter.ai/api/v1/chat/completions"),
      let httpBody = try? JSONSerialization.data(withJSONObject: bodyJson)
    else {
      completion(.failure(NSError(domain: "OpenRouter", code: -1)))
      return
    }

    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.addValue("application/json", forHTTPHeaderField: "Content-Type")
    req.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    req.httpBody = httpBody

    URLSession.shared.dataTask(with: req) { data, _, error in
      if let err = error {
        return completion(.failure(err))
      }
      guard
        let data = data,
        let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any],
        let choices = json["choices"] as? [[String:Any]],
        let message = choices.first?["message"] as? [String:Any],
        let text = message["content"] as? String
      else {
        return completion(.failure(NSError(domain: "OpenRouter", code: -2)))
      }
      completion(.success(text.trimmingCharacters(in: .whitespacesAndNewlines)))
    }
    .resume()
  }
}

