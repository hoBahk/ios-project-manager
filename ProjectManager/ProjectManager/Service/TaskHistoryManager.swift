import Foundation

class TaskHistoryManager {
    var taskHistory = [TaskHistory]()
    var undoManager = UndoManager()
    
    func appendHistory(_ action: TaskHistory.Action) {
        switch action {
        case .create(let task):
            let history = TaskHistory(.create(task))
            taskHistory.append(history)
        case .update(let task, let newTask):
            let history = TaskHistory(.update(task, newTask: newTask))
            taskHistory.append(history)
        case .move(let id, let title, let prevStatus, let nextStatus):
            let history = TaskHistory(.move(id: id, title: title, prevStatus: prevStatus, nextStatus: nextStatus))
            taskHistory.append(history)
        case .delete(let task):
            let history = TaskHistory(.delete(task))
            taskHistory.append(history)
        }
    }
    
    func registerUndo(action: @escaping () -> Void) {
        undoManager.registerUndo(withTarget: self) { _ in
            action()
        }
    }
}
