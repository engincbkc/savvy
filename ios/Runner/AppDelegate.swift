import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var secureTextField: UITextField?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Setup screenshot protection channel
    if let controller = window?.rootViewController as? FlutterViewController {
      let screenshotChannel = FlutterMethodChannel(
        name: "com.savvy.savvy/screenshot",
        binaryMessenger: controller.binaryMessenger
      )

      screenshotChannel.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "enableProtection":
          self?.enableScreenshotProtection()
          result(nil)
        case "disableProtection":
          self?.disableScreenshotProtection()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // MARK: - Screenshot Protection

  private func enableScreenshotProtection() {
    guard let window = self.window else { return }

    // Create a secure text field that blocks screenshots
    if secureTextField == nil {
      let field = UITextField()
      field.isSecureTextEntry = true
      field.isUserInteractionEnabled = false
      window.addSubview(field)
      field.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
      field.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
      secureTextField = field

      // Make the secure layer cover the whole window
      window.layer.superlayer?.addSublayer(field.layer)
      field.layer.sublayers?.first?.addSublayer(window.layer)
    }
  }

  private func disableScreenshotProtection() {
    secureTextField?.removeFromSuperview()
    secureTextField = nil
  }
}
