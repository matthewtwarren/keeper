import SwiftUI

@main
struct KeeperApp: App {
    var body: some Scene {
        Window("Keeper", id: "main") {
            ContentView()
                .frame(minWidth: 900, minHeight: 600)
                .preferredColorScheme(.dark)
        }
    }
}
