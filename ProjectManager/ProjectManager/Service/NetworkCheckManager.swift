import Foundation
import Network

class NetworkCheckManager: ObservableObject {
    @Published var isConnected: Bool = true
    @Published var isNotConnected: Bool = false
    
    let monitor: NWPathMonitor
    let queue = DispatchQueue(label: "monitor")
    
    init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.isNotConnected = !(self?.isConnected ?? true)
                
                if self?.isConnected == true {
                    print("연결됨")
                } else {
                    print("연결안됨")
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
