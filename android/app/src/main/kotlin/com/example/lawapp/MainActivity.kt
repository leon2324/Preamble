package com.example.lawapp

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val nativeShareChannelName = "lawapp/native_share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 台灣繁體中文教學註解：
        // Android 的原生分享入口使用 ACTION_SEND，讓分享抽屜的「系統分享」按鈕
        // 真的跳出系統分享器，而不是只顯示 SnackBar 或複製文字。
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            nativeShareChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "shareText" -> {
                    val text = call.argument<String>("text")
                    val title = call.argument<String>("title") ?: "LawApp"
                    if (text.isNullOrBlank()) {
                        result.error(
                            "invalid_share_text_payload",
                            "Native share payload must contain text.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    val sendIntent = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_SUBJECT, title)
                        putExtra(Intent.EXTRA_TEXT, text)
                    }
                    startActivity(Intent.createChooser(sendIntent, title))
                    result.success(null)
                }

                "shareTipCard" -> {
                    val title = call.argument<String>("title") ?: "LawApp 生活避坑筆記"
                    val summary = call.argument<String>("summary") ?: ""
                    val source = call.argument<String>("source") ?: "LawApp"
                    val sendIntent = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_SUBJECT, title)
                        putExtra(Intent.EXTRA_TEXT, "$title\n$summary\n$source")
                    }
                    startActivity(Intent.createChooser(sendIntent, title))
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
}
