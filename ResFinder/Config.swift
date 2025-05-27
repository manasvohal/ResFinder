//  Config.swift
//  ResFinder

import Foundation

/// Reads our key values out of Info.plist so we don’t hard‑code secrets in code.
enum Config {
    /// Your API’s base URL, set under “API_BASE_URL” in Info.plist
    static var apiBaseURL: URL {
        guard let urlString = Bundle.main
                .object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              let url = URL(string: urlString)
        else {
            fatalError("API_BASE_URL is not configured in Info.plist")
        }
        return url
    }

    /// Your OpenRouter API key, set under “OPENROUTER_KEY” in Info.plist
    static var openRouterKey: String {
        guard let key = Bundle.main
                .object(forInfoDictionaryKey: "OPENROUTER_KEY") as? String,
              !key.isEmpty
        else {
            fatalError("OPENROUTER_KEY is not configured in Info.plist")
        }
        return key
    }
}
