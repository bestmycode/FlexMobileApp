package flexnow.co

import android.util.Log
import androidx.annotation.NonNull
import com.meawallet.mcd.*

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {
    private val channel = "flexnow.co/card"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channel
        ).setMethodCallHandler { call, result ->
            if (call.method.equals("getCardData")) {
                val secret: String? = call.argument("secret")
                val cardId: String? = call.argument("cardId")
                if (secret.isNullOrEmpty() || cardId.isNullOrEmpty()) {
                    result.error("Values can't be null", "Card secret or cardID was null", null)
                }
                getCardData(cardId!!, secret!!, result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getCardData(cardId: String, secret: String, result: MethodChannel.Result) {
        MeaCardData.getCardData(cardId, secret, object : McdGetCardDataListener {
            override fun onSuccess(@NonNull mcdCardData: McdCardData) {
                result.success(hashMapOf("pan" to mcdCardData.pan,"cvv" to mcdCardData.cvv))
                return;
                // Use retrieved data.
            }

            override fun onFailure(@NonNull mcdError: McdError) {
                val errorCode = mcdError.code
                val errorMessage = mcdError.message
                result.error(errorCode.toString(), errorMessage, mcdError)
                return;
                // Handle error.
            }

        })

    }
}
