//
//  RecommendationViewModel.swift
//  ResFinder
//
//  Created by Manas Vohal on 5/13/25.
//

import SwiftUI
import Combine

/// ViewModel that uses OpenRouter AI to rank professors by fit to the user's resume
class RecommendationViewModel: ObservableObject {
    @Published var recommendations: [Professor] = []
    @Published var isLoading = false

    /// Fetches all professors for `school`, then asks OpenRouter to rank them against `resumeText`
    /// and returns the top `topK` professor IDs, which we then map back to Professor objects.
    func loadRecommendations(for school: String, resumeText: String, topK: Int = 5) {
        isLoading = true

        // 1) Load all professors
        APIClient.fetchProfessors { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let resp):
                    // filter to selected school
                    let profs = resp.professors.filter {
                        $0.university.caseInsensitiveCompare(school) == .orderedSame
                    }

                    // 2) Ask the LLM to rank them
                    OpenRouterService.shared.generateRecommendations(
                        resume: resumeText,
                        professors: profs,
                        topK: topK
                    ) { recResult in
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            switch recResult {
                            case .success(let ids):
                                // map returned IDs back to Professor objects
                                self?.recommendations = ids.compactMap { id in
                                    profs.first(where: { $0.id == id })
                                }
                            case .failure(let err):
                                print("❌ Recommendation error:", err)
                                // fallback: first `topK`
                                self?.recommendations = Array(profs.prefix(topK))
                            }
                        }
                    }

                case .failure(let err):
                    print("❌ Failed to load professors:", err)
                    self?.isLoading = false
                }
            }
        }
    }
}
