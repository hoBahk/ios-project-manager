import Foundation
import Combine

class TaskListViewModel: ObservableObject {
    @Published var todoTaskList = [Task]()
    @Published var doingTaskList = [Task]()
    @Published var doneTaskList = [Task]()
    @Published var taskHistory = [TaskHistory]()
    @Published var errorAlert: ErrorModel?

    let taskListManager = TaskManager()
    let historyManager = TaskHistoryManager()
    let networkManager = NetworkCheckManager()
 
    var cancellables = Set<AnyCancellable>()
    
    init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        networkManager.startMonitoring { isConnected in
            if isConnected {
                self.synchronizeFirebaseWithRealm()
            } else {
                self.errorAlert = ErrorModel(message: "Network is Not Connected".localized())
            }
        }
    }
    
    private func synchronizeFirebaseWithRealm() {
        synchronizeRealmToFirebase()
        synchronizeFirebaseToRealm()
    }
    
    private func reload() {
        todoTaskList = taskListManager.taskList(at: .todo)
        doingTaskList = taskListManager.taskList(at: .doing)
        doneTaskList = taskListManager.taskList(at: .done)
        taskHistory = historyManager.taskHistory
    }
    
    func changeableStatusList(from status: TaskStatus) -> [TaskStatus] {
        return TaskStatus.allCases.filter { $0 != status }
    }
}

// MARK: - Method used by View
extension TaskListViewModel {
    func createTask(_ task: Task) {
        if networkManager.isConnected {
            createTaskOnFirebase(task)
        }
        createTaskOnRealm(task)
        appendHistory(.create(task))
    }

    func updateTask(from task: Task, to newTask: Task) {
        if networkManager.isConnected {
            updateTaskOnFirebase(
                id: task.id,
                title: newTask.title,
                description: newTask.description,
                deadline: newTask.deadline.dateFormat
            )
        }
        updateTaskOnRealm(
            id: task.id,
            title: newTask.title,
            description: newTask.description,
            deadline: newTask.deadline.dateFormat
        )
        appendHistory(.update(task, newTask: newTask))
    }
    
    func updateTaskStatus(id: String, title: String, prevStatus: TaskStatus, nextStatus: TaskStatus) {
        if networkManager.isConnected {
            updateStatusOnFirebase(id: id, status: nextStatus)
        }
        updateStatusOnRealm(id: id, nextStatus: nextStatus)
        appendHistory(.move(id: id, title: title, prevStatus: prevStatus, nextStatus: nextStatus))
    }
    
    func deleteTask(_ task: Task) {
        if networkManager.isConnected {
            deleteTaskOnFirebase(id: task.id)
        }
        deleteTaskOnRealm(id: task.id, taskStatus: task.progressStatus)
        appendHistory(.delete(task))
    }
}

extension TaskListViewModel {
    private func synchronizeRealmToFirebase() {
        do {
            try taskListManager.synchronizeRealmToFirebase()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func synchronizeFirebaseToRealm() {
        taskListManager.synchronizeFirebaseToRealm()
            .sink { complition in
                switch complition {
                case .failure(let error):
                    self.errorAlert = ErrorModel(message: error.localizedDescription)
                    print(error.localizedDescription)
                case .finished:
                    return
                }
            } receiveValue: {
                self.fetchRealm()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Firebase CRUD Method
extension TaskListViewModel {
    private func createTaskOnFirebase(_ task: Task) {
        taskListManager.createFirebaseTask(task)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.errorAlert = ErrorModel(message: error.localizedDescription)
                    print(error.localizedDescription)
                case .finished:
                    return
                }
            } receiveValue: { _ in
                self.reload()
            }
            .store(in: &cancellables)
    }
    
    private func updateTaskOnFirebase(id: String, title: String, description: String, deadline: Date) {
        taskListManager.updateFirebaseTask(id: id, title: title, description: description, deadline: deadline)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.errorAlert = ErrorModel(message: error.localizedDescription)
                    print(error.localizedDescription)
                case .finished:
                    return
                }
            } receiveValue: { _ in
                self.reload()
            }
            .store(in: &cancellables)
    }
    
    private func updateStatusOnFirebase(id: String, status: TaskStatus) {
        taskListManager.updateFirebaseTaskStatus(id: id, taskStatus: status)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.errorAlert = ErrorModel(message: error.localizedDescription)
                    print(error.localizedDescription)
                case .finished:
                    return
                }
            } receiveValue: { _ in
                self.reload()
            }
            .store(in: &cancellables)
    }
    
    private func deleteTaskOnFirebase(id: String) {
        taskListManager.deleteFirebaseTask(id)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.errorAlert = ErrorModel(message: error.localizedDescription)
                    print(error.localizedDescription)
                case .finished:
                    return
                }
            } receiveValue: { _ in
                self.reload()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Realm CRUD Method
extension TaskListViewModel {
    private func fetchRealm() {
        do {
            try taskListManager.fetchRealmTaskList()
            reload()
        } catch {
            errorAlert = ErrorModel(message: error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    private func createTaskOnRealm(_ task: Task) {
        do {
            try taskListManager.createRealmTask(task)
            fetchRealm()
        } catch {
            errorAlert = ErrorModel(message: error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    private func updateTaskOnRealm(id: String, title: String, description: String, deadline: Date) {
        do {
            try  taskListManager.updateRealmTask(id: id, title: title, description: description, deadline: deadline)
            fetchRealm()
        } catch {
            errorAlert = ErrorModel(message: error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    private func updateStatusOnRealm(id: String, nextStatus: TaskStatus) {
        do {
            try taskListManager.updateRealmTaskStatus(id: id, taskStatus: nextStatus)
            fetchRealm()
        } catch {
            errorAlert = ErrorModel(message: error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    private func deleteTaskOnRealm(id: String, taskStatus: TaskStatus) {
        do {
            try  taskListManager.deleteRealmTask(id)
            fetchRealm()
        } catch {
            errorAlert = ErrorModel(message: error.localizedDescription)
            print(error.localizedDescription)
        }
    }
}

// MARK: - History Method
extension TaskListViewModel {
    private func appendHistory(_ action: TaskHistory.Action) {
        switch action {
        case .create(let task):
            historyManager.appendHistory(.create(task))
            historyManager.registerUndo {
                self.deleteTask(task)
            }
        case .update(let task, let newTask):
            historyManager.appendHistory(.update(task, newTask: newTask))
            historyManager.registerUndo {
                self.updateTask(from: newTask, to: task)
            }
        case .move(let id, let title, let prevStatus, let nextStatus):
            historyManager.appendHistory(.move(id: id, title: title, prevStatus: prevStatus, nextStatus: nextStatus))
            historyManager.registerUndo {
                self.updateTaskStatus(id: id, title: title, prevStatus: nextStatus, nextStatus: prevStatus)
            }
        case .delete(let task):
            historyManager.appendHistory(.delete(task))
            historyManager.registerUndo {
                self.createTask(task)
            }
        }
    }
}
