import Foundation

class OpenRouterService {
    static let shared = OpenRouterService()
    /// Now reads your key from Config → Info.plist’s OPENROUTER_KEY
    private let apiKey: String = Config.openRouterKey

    // MARK: – Generate initial outreach email body
    func generateEmailBody(
        for researchAreas: [String],
        professorLastName: String = "",
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let userName   = UserDefaults.standard.string(forKey: "userName") ?? ""
        let userMajor  = UserDefaults.standard.string(forKey: "userMajor") ?? ""
        let userYear   = UserDefaults.standard.string(forKey: "userYear")  ?? ""
        var resumeText = UserDefaults.standard.string(forKey: "resumeText") ?? ""
        let maxLength = 2000
        if resumeText.count > maxLength {
            resumeText = String(resumeText.prefix(maxLength)) + "..."
        }
        let interests = researchAreas.joined(separator: ", ")
        let profLast  = professorLastName.isEmpty ? "XXX" : professorLastName
        let prompt = """
        Using the following student information and professor's research areas, create a short, personalized email (max 200 words):

        STUDENT INFO:
        Name: \(userName)
        Year and Major: \(userYear) in \(userMajor)

        RESUME DETAILS:
        \(resumeText)

        PROFESSOR'S RESEARCH AREAS: \(interests)
        PROFESSOR'S LAST NAME: \(profLast)

        Use this exact format (do NOT include a subject line):

        Dear Professor \(profLast),

        I hope that you are doing well. I am a [YEAR] studying [MAJOR] and am interested in your research on [RESEARCH AREA]. [1-2 SENTENCES CONNECTING STUDENT'S RESUME EXPERIENCE TO PROFESSOR'S RESEARCH].

        [1 SENTENCE HIGHLIGHTING A SPECIFIC SKILL FROM RESUME RELEVANT TO THE LAB]. I would love to be a part of your research.

        Do you have time to briefly meet sometime this week or next? I'd be happy to provide my resume and transcript.

        Sincerely,
        \(userName)
        """
        sendRequest(prompt: prompt, completion: completion)
    }

    // MARK: – Generate follow‑up email
    func generateFollowUpEmail(
        prompt: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        sendRequest(prompt: prompt, completion: completion)
    }

    func generateFollowUpEmail(
        for professorLastName: String,
        originalEmail: String,
        daysSinceContact: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let profLast = professorLastName
        let prompt = """
        Generate a brief follow-up email for a professor I contacted about research opportunities.

        ORIGINAL EMAIL I SENT:
        \(originalEmail)

        DAYS SINCE SENT: \(daysSinceContact)

        PROFESSOR'S LAST NAME: \(profLast)

        Guidelines:
        - Keep it very brief and polite (3-5 sentences maximum)
        - DO NOT include a subject line in the body text
        - Start with "Dear Professor \(profLast),"
        - Remind them of my initial email about research opportunities
        - Ask if they've had a chance to review my email
        - Offer to provide additional information if needed
        - Thank them for their time
        """
        sendRequest(prompt: prompt, completion: completion)
    }

    // MARK: – Generate top‑K recommendations
    func generateRecommendations(
        resume: String,
        professors: [Professor],
        topK: Int = 5,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        let profList = professors.enumerated().map { idx, prof in
            "\(idx + 1). ID: \(prof.id), Name: \(prof.name), ResearchAreas: \(prof.researchAreas.joined(separator: ", "))"
        }.joined(separator: "\n")
        let prompt = """
        You are a recommendation engine. Here is a student resume:
        \(resume)

        Here are \(professors.count) professors:
        \(profList)

        Please rank the top \(topK) professors best matched to this resume by their ID.
        Return _only_ a JSON array of the professor IDs in order, like ["id1","id2",...], with no extra text.
        """
        sendRequest(prompt: prompt) { result in
            switch result {
            case .success(let text):
                print("🔍 Raw recommendation response:", text)
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                let jsonArrayString: String
                if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
                    jsonArrayString = trimmed
                } else if
                    let start = trimmed.firstIndex(of: "["),
                    let end   = trimmed.lastIndex(of: "]")
                {
                    jsonArrayString = String(trimmed[start...end])
                } else {
                    jsonArrayString = trimmed
                }
                if let data = jsonArrayString.data(using: .utf8),
                   let ids  = try? JSONDecoder().decode([String].self, from: data)
                {
                    completion(.success(ids))
                } else {
                    print("❌ Failed to parse recommendation IDs from: \(jsonArrayString)")
                    completion(.failure(NSError(
                        domain: "OpenRouterService",
                        code: -3,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to parse recommendation IDs"]
                    )))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: – Shared request helper
    private func sendRequest(
        prompt: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let messages: [[String:String]] = [
            ["role": "system", "content": "You are a professional email writer and recommendation engine."],
            ["role": "user",   "content": prompt]
        ]
        let body: [String:Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 500,
            "temperature": 0.7
        ]
        guard
            let url      = URL(string: "https://openrouter.ai/api/v1/chat/completions"),
            let httpBody = try? JSONSerialization.data(withJSONObject: body)
        else {
            return completion(.failure(NSError(domain: "OpenRouter", code: -1)))
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
                let data    = data,
                let json    = try? JSONSerialization.jsonObject(with: data) as? [String:Any],
                let choices = json["choices"] as? [[String:Any]],
                let msg     = choices.first?["message"] as? [String:Any],
                let content = msg["content"] as? String
            else {
                return completion(.failure(NSError(domain: "OpenRouter", code: -2)))
            }
            completion(.success(content.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        .resume()
    }
}
