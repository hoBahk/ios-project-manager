import Foundation

enum FirebaseError: LocalizedError {
    case fetchFailed
    case createFailed
    case updateFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "RemoteDB Fetch Failed"
        case .createFailed:
            return "RemoteDB Create Failed"
        case .updateFailed:
            return "RemoteDB Update Failed"
        case .deleteFailed:
            return "RemoteDB Delete Failed"
        }
    }
}
