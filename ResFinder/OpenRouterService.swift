import Foundation

class OpenRouterService {
    static let shared = OpenRouterService()
    private let apiKey = Bundle.main
        .object(forInfoDictionaryKey: "OPENROUTER_API_KEY") as? String ?? ""
    
    /// Generates an email body via OpenRouter
    func generateEmailBody(for researchAreas: [String],
                          professorLastName: String = "",
                          completion: @escaping (Result<String, Error>) -> Void) {
        // Get user information from UserDefaults
        let userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        let userMajor = UserDefaults.standard.string(forKey: "userMajor") ?? ""
        let userYear = UserDefaults.standard.string(forKey: "userYear") ?? ""
        var userResume = UserDefaults.standard.string(forKey: "resumeText") ?? ""
        
        // Limit resume text length for the API request
        let maxResumeLength = 2000
        if userResume.count > maxResumeLength {
            userResume = String(userResume.prefix(maxResumeLength)) + "..."
        }
        
        let researchInterests = researchAreas.joined(separator: ", ")
        
        // Create the prompt with the structured format
        let prompt = """
        Using the following student information and professor's research areas, create a short, personalized email (max 200 words):
        
        STUDENT INFO:
        Name: \(userName)
        Year and Major: \(userYear) in \(userMajor)
        
        RESUME DETAILS:
        \(userResume)
        
        PROFESSOR'S RESEARCH AREAS: \(researchInterests)
        PROFESSOR'S LAST NAME: \(professorLastName)
        
        Use this exact format (do NOT include a subject line):
        
        Dear Professor \(professorLastName.isEmpty ? "XXX" : professorLastName),
        
        I hope that you are doing well. I am a [YEAR] studying [MAJOR] and am interested in your research on [RESEARCH AREA]. [1-2 SENTENCES CONNECTING STUDENT'S RESUME EXPERIENCE TO PROFESSOR'S RESEARCH].
        
        [1 SENTENCE HIGHLIGHTING A SPECIFIC SKILL FROM RESUME RELEVANT TO THE LAB]. I would love to be a part of your research.
        
        Do you have time to briefly meet sometime this week or next? I'd be happy to provide my resume and transcript.
        
        Sincerely,
        \(userName)
        """
        
        sendRequest(prompt: prompt, completion: completion)
    }
    
    /// Generates a follow-up email via OpenRouter
    func generateFollowUpEmail(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        sendRequest(prompt: prompt, completion: completion)
    }
    
    /// Generates a follow-up email with professor's last name
    func generateFollowUpEmail(for professorLastName: String, originalEmail: String, daysSinceContact: Int, completion: @escaping (Result<String, Error>) -> Void) {
        // Create prompt for follow-up email with professor's last name
        let followUpPrompt = """
        Generate a brief follow-up email for a professor I contacted about research opportunities.
        
        ORIGINAL EMAIL I SENT:
        \(originalEmail)
        
        DAYS SINCE SENT: \(daysSinceContact)
        
        PROFESSOR'S LAST NAME: \(professorLastName)
        
        Guidelines:
        - Keep it very brief and polite (3-5 sentences maximum)
        - DO NOT include a subject line in the body text
        - Start with "Dear Professor \(professorLastName),"
        - Remind them of my initial email about research opportunities
        - Ask if they've had a chance to review my email
        - Offer to provide additional information if needed
        - Thank them for their time
        """
        
        sendRequest(prompt: followUpPrompt, completion: completion)
    }
    
    // Helper method to send request to OpenRouter API
    private func sendRequest(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        // 1) Build chat payload
        let messages: [[String:String]] = [
            ["role":"system","content":"You are a professional email writer who creates concise, effective emails."],
            ["role":"user","content": prompt]
        ]
        
        let bodyJson: [String:Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 350,
            "temperature": 0.7
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
