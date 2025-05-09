import Foundation

// MARK: – The top‑level JSON wrapper
struct ProfessorsResponse: Codable {
    let count: Int
    let professors: [Professor]
}

// MARK: – Each professor entry
struct Professor: Identifiable, Codable {
    // map the Mongo _id field to id
    let _id: String
    var id: String { _id }

    let name: String
    let university: String
    let department: String
    let profileUrl: URL
    let researchAreas: [String]
}
