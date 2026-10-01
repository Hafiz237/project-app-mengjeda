import Foundation
import Flutter
import UserNotifications
import AVFoundation

class JedaIosPlugin: NSObject, FlutterPlugin {
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mengjeda/jeda_ios",
                                           binaryMessenger: registrar.messenger())
        let instance = JedaIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestPermission":
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async { result(granted) }
            }
        case "scheduleJeda":
            let args = call.arguments as? [String: Any]
            let seconds = args?["seconds"] as? Double ?? 20
            scheduleNotification(after: seconds)
            result(true)
        case "cancelJeda":
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func scheduleNotification(after seconds: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Waktunya Jeda Sejenak"
        content.body = "Letakkan HP-mu, istirahatkan matamu."
        content.sound = UNNotificationSound.defaultCritical

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "jeda_\(UUID().uuidString)",
            content: content,
            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}