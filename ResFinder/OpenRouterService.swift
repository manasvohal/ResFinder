import Foundation

class OpenRouterService {
    static let shared = OpenRouterService()
    private let apiKey = Bundle.main
        .object(forInfoDictionaryKey: "OPENROUTER_API_KEY") as? String ?? ""
    
    /// Generates an email body via OpenRouter
    func generateEmailBody(for researchAreas: [String],
                          completion: @escaping (Result<String, Error>) -> Void) {
        // Get user information from UserDefaults
        let userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        let userMajor = UserDefaults.standard.string(forKey: "userMajor") ?? ""
        let userYear = UserDefaults.standard.string(forKey: "userYear") ?? ""
        let userResume = UserDefaults.standard.string(forKey: "resumeText") ?? ""
        
        let researchInterests = researchAreas.joined(separator: ", ")
        
        // Create the prompt with the structured format
        let prompt = """
        Using the following information, generate a professional, personalized email to a professor:
        
        STUDENT INFO:
        Name: \(userName)
        Year and Major: \(userYear) in \(userMajor)
        
        PROFESSOR'S RESEARCH AREAS: \(researchInterests)
        
        STUDENT'S RESUME SUMMARY: \(userResume)
        
        The email should follow this structure:
        
        "Dear Professor XXX,
        
        I hope that you are doing well. I am a [COLLEGE YEAR AND MAJOR/HONORS PROGRAM] and am very much interested in your [WHAT THEY ARE RESEARCHING]. [EXPLAIN BRIEFLY WHY YOU WANT TO WORK IN THE LAB BASED ON STUDENT'S EXPERIENCE FROM RESUME]. 
        
        Overall, I am a hard-working individual who can communicate well and produce thorough work. In particular, [PROVIDE SPECIFIC EXAMPLE FROM STUDENT'S RESUME THAT RELATES TO THE RESEARCH AREA]. I would love to be a part of the work you are doing.
        
        Do you have time to briefly meet sometime this week or next, either in person or by zoom? I'd be happy to provide you with my resume and unofficial transcript.
        
        I hope to hear back from you soon. In the meantime, have a great day!
        
        Sincerely,
        \(userName)"
        
        Keep the email concise, professional, and personalized based on the student's background and the professor's research interests. Make the connections between the student's experience and the professor's work clear and specific.
        """
        
        // 1) Build chat payload
        let messages: [[String:String]] = [
            ["role":"system","content":"You are a helpful assistant that writes professional emails."],
            ["role":"user","content": prompt]
        ]
        
        let bodyJson: [String:Any] = [
            "model": "gpt-3.5-turbo",        // or "gpt-4o-mini" if your key allows
            "messages": messages,
            "max_tokens": 500
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
