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
            Color.gray.opacity(0.2).edgesIgnoringSafeArea(.all) // Darken the background slightly
            VStack(spacing: 16) {
                Text("Notifications")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 8)

                Toggle("", isOn: $isOn)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .scaleEffect(1.5) // Make the switch bigger and easier to tap
                    .padding(.vertical, 8)
                    .onChange(of: isOn) { newValue in
                        nm.setScheduled(enabled: newValue)
                    }

                Text(isOn ? "ON" : "OFF")
                    .font(.title2)
                    .foregroundColor(isOn ? .green : .gray)
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        .onAppear {
            Task {
                await nm.requestPermission()
            }
        }
    }
}
