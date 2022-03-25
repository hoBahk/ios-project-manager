import Foundation

struct TaskHistory: Identifiable {
    let actionType: ActionType
    let date: TimeInterval
    
    var id: UUID { UUID() }
    
    init(handleType: ActionType, date: TimeInterval = Date().timeIntervalSince1970) {
        self.actionType = handleType
        self.date = date
    }
    
    private enum Message {
        static let create = "Added `%@`."
        static let update = "Updated `%@`"
        static let move = "Moved `%@` from %@ to %@."
        static let delete = "Removed `%@` from %@."
    }
    
    enum ActionType {
        case create(title: String)
        case update(title: String)
        case move(title: String, prevStatus: TaskStatus, nextStatus: TaskStatus)
        case delete(title: String, status: TaskStatus)
        
        var description: String {
            switch self {
            case .create(let title):
                return Message.create.localized(with: [title])
            case .update(title: let title):
                return Message.update.localized(with: [title])
            case .move(let title, let prevStatus, let nextStatus):
                return Message.move.localized(with: [title, prevStatus.name, nextStatus.name])
            case .delete(let title, let status):
                return Message.delete.localized(with: [title, status.name])
            }
        }
    }
}
