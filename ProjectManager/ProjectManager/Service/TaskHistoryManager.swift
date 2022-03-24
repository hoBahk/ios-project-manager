import Foundation

class TaskHistoryManager {
    var taskHistory = [TaskHistory]()
    var undoManager = UndoManager()
    
    private enum Message {
        static let create = "Added `%@`."
        static let move = "Moved `%@` from %@ to %@."
        static let delete = "Removed `%@` from %@."
    }
    
    enum TaskHandleType {
        case create(title: String)
        case move(title: String, prevStatus: TaskStatus, nextStatus: TaskStatus)
        case delete(title: String, status: TaskStatus)
    }
    
    func appendHistory(taskHandleType: TaskHandleType) {
        switch taskHandleType {
        case .create(let title):
            let description = Message.create.localized(with: [title])
            let history = TaskHistory(description: description)
            taskHistory.append(history)
        case .move(let title, let prevStatus, let nextStatus):
            let description = Message.move.localized(with: [title, prevStatus.name, nextStatus.name])
            let history = TaskHistory(description: description)
            taskHistory.append(history)
        case .delete(let title, let status):
            let description = Message.delete.localized(with: [title, status.name])
            let history = TaskHistory(description: description)
            taskHistory.append(history)
        }
    }
}
