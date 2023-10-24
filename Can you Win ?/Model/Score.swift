import Foundation

struct Score: Codable, Identifiable {
    var id: String
    var uid: String
    var time: Double
    var createdAt: Date
    var updatedAt: Date
    
    init(time: Double) {
        self.id = UUID().uuidString
        self.uid = ""
        self.time = time
        self.createdAt = .init()
        self.updatedAt = .init()
    }
}
