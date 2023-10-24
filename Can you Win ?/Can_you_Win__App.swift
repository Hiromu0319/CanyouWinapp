import SwiftUI
import FirebaseCore

@main
struct Can_you_Win__App: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            TopView()
        }
    }
}
