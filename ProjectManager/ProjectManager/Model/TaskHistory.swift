import Foundation

struct TaskHistory: Identifiable {
    let action: Action
    let date: TimeInterval
    
    var id: UUID { UUID() }
    
    init(_ action: Action, date: TimeInterval = Date().timeIntervalSince1970) {
        self.action = action
        self.date = date
    }
    
    private enum Message {
        static let create = "Added `%@`."
        static let update = "Updated `%@`"
        static let move = "Moved `%@` from %@ to %@."
        static let delete = "Removed `%@` from %@."
    }
    
    enum Action {
        case create(_ task: Task)
        case update(_ task: Task, newTask: Task)
        case move(id: String, title: String, prevStatus: TaskStatus, nextStatus: TaskStatus)
        case delete(_ task: Task)
        
        var description: String {
            switch self {
            case .create(let task):
                return Message.create.localized(with: [task.title])
            case .update(_, let newTask):
                return Message.update.localized(with: [newTask.title])
            case .move(_, let title, let prevStatus, let nextStatus):
                return Message.move.localized(with: [title, prevStatus.name, nextStatus.name])
            case .delete(let task):
                return Message.delete.localized(with: [task.title, task.progressStatus.name])
            }
        }
    }
}
