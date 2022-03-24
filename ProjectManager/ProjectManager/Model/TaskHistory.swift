import Foundation

struct TaskHistory: Identifiable {
    var description: String
    var date: TimeInterval
    
    var id: UUID { UUID() }
    
    init(description: String, date: TimeInterval = Date().timeIntervalSince1970) {
        self.description = description
        self.date = date
    }
}
