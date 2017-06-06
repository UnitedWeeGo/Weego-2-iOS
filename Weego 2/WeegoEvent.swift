import UIKit
import Firebase
import FirebaseDatabase

typealias TimestampInt = Int

public struct WeegoEvent {
    
    var authorUID: String
    var authorDisplayName: String
    var title: String
    var created: TimestampInt
    
    init(authorUID: String, authorDisplayName: String, title: String) {
        self.authorUID = authorUID
        self.authorDisplayName = authorDisplayName
        self.title = title
        self.created = 0
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        guard let authorUID  = dict["authorUID"] as? String else { return nil }
        guard let authorDisplayName = dict["authorDisplayName"] as? String else { return nil }
        guard let title = dict["title"] as? String else { return nil }
        guard let created = dict["created"] as? TimestampInt else { return nil }
        
        self.authorUID = authorUID
        self.authorDisplayName = authorDisplayName
        self.title = title
        self.created = created
    }
    
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]
        json["authorUID"] = authorUID
        json["authorDisplayName"] = authorDisplayName
        json["title"] = title
        json["created"] = created == 0 ? ServerValue.timestamp() : created
        return json
    }
}

extension TimestampInt {
    public func toDate() -> Date {
        let x = self / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(x))
        return date
    }
    public func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter.string(from: self.toDate())
    }
}

// Mark: - Equatable
extension WeegoEvent: Equatable {}

public func == (lhs: WeegoEvent, rhs: WeegoEvent) -> Bool {
    return lhs.authorUID == rhs.authorUID &&
        lhs.authorDisplayName == rhs.authorDisplayName &&
        lhs.title == rhs.title &&
        String(describing: lhs.created) == String(describing: rhs.created)
}

// Mark: - Hashable
extension WeegoEvent: Hashable {
    public var hashValue: Int {
        return "\(authorUID)\(authorDisplayName)\(title)\(String(describing: created))".hashValue
    }
}

// Mark: - Comparable
extension WeegoEvent: Comparable {}

public func <(lhs: WeegoEvent, rhs: WeegoEvent) -> Bool {
    return lhs < rhs
}
