
import Foundation

struct DataUser: Codable {
    let uid: String?

    // Define an initializer with a default value for "uid" if it's not present in the JSON
    init(uid: String? = nil) {
        self.uid = uid
    }
}

