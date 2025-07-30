import SwiftUI
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    func requestPermission() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        } catch {
            print("No permission")
        }
    }

    func setScheduled(enabled: Bool) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard enabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Ping"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: "timer", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}

struct ContentView: View {
    @State private var isOn = false
    @StateObject private var nm = NotificationManager()

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            Toggle(isOn: $isOn) {
                Text(isOn ? "Notifications ON" : "Notifications OFF")
                    .font(.title2)
            }
            .padding(40)
            .onChange(of: isOn) { oldValue, newValue in
                nm.setScheduled(enabled: newValue)
            }
        }
        .task {
            await nm.requestPermission()
        }
    }
}



