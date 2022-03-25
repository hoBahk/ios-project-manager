import Foundation

class TaskHistoryManager {
    var taskHistory = [TaskHistory]()
    var undoManager = UndoManager()
    
    func appendHistory(_ taskActionType: TaskHistory.ActionType) {
        switch taskActionType {
        case .create(let title):
            let history = TaskHistory(handleType: .create(title: title))
            taskHistory.append(history)
        case .update(let title):
            let history = TaskHistory(handleType: .update(title: title))
            taskHistory.append(history)
        case .move(let title, let prevStatus, let nextStatus):
            let history = TaskHistory(handleType: .move(title: title, prevStatus: prevStatus, nextStatus: nextStatus))
            taskHistory.append(history)
        case .delete(let title, let status):
            let history = TaskHistory(handleType: .delete(title: title, status: status))
            taskHistory.append(history)
        }
    }
    
    func registerUndo(action: @escaping () -> Void) {
        undoManager.registerUndo(withTarget: self) { _ in
            action()
        }
    }
}
