import UIKit
import Flutter
import MeaCardData

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let cardDataMethodChannel = FlutterMethodChannel(name: "flexnow.co/card", binaryMessenger: controller.binaryMessenger)

        cardDataMethodChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            guard call.method == "getCardData" else {
                result(FlutterMethodNotImplemented)
                return
            }

            if let args = call.arguments as? Dictionary<String, Any>,
               let secret = args["secret"] as? String,
               let cardId=args["cardId"] as? String{
               self?.getCardData(result:result,secret:secret,cardId:cardId)
            } else {
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }

            return
        })

        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func getCardData(result:@escaping FlutterResult,secret:String,cardId:String) {
        MeaCardData.getCardData(cardId, secret: secret) {(cardData, error)  in
            guard error==nil else{
                result(FlutterError(code: "error", message:error?.localizedDescription, details: nil))
                return
            }

            var cardResult = [String: String]()
            cardResult["pan"]=cardData!.pan
            cardResult["cvv"]=cardData!.cvv
            result(cardResult)
        }
    }
}
