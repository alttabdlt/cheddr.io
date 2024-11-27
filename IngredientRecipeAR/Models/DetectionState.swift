import Foundation

enum DetectionState: Equatable {
    case initializing
    case ready
    case scanning
    case failed(Error)
    
    static func == (lhs: DetectionState, rhs: DetectionState) -> Bool {
        switch (lhs, rhs) {
        case (.initializing, .initializing),
             (.ready, .ready),
             (.scanning, .scanning):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
} 