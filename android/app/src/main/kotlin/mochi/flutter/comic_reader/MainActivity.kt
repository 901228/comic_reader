package mochi.flutter.comic_reader

import android.os.Build
import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.view.WindowManager
import android.content.Context
// import android.provider.Settings
import androidx.annotation.NonNull
// import com.uchuhimo.collections.biMapOf
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.kotlin.subscribeBy
import io.reactivex.rxjava3.subjects.PublishSubject


class MainActivity : FlutterActivity() {
    private var interceptKeyDownEnable = false
    private val keyDownSubject = PublishSubject.create<String>()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor, "mochi.flutter/interceptVolumeKey").setMethodCallHandler {
            call, result ->
            when (call.method) {
                "interceptKeyDown" -> {
                    interceptKeyDownEnable = true
                    result.success(true)
                }
                "uninterceptKeyDown" -> {
                    interceptKeyDownEnable = false
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        EventChannel(flutterEngine.dartExecutor, "mochi.flutter/volumeKeyEvent").setStreamHandler(object: StreamHandler {
            var dispose: Disposable? = null

            override fun onListen(argument: Any?, events: EventChannel.EventSink?) {
                dispose = keyDownSubject.subscribeBy (
                    onNext = { events?.success(it) },
                    onError = { events?.error("KEY_DOWN_EVENT", it.message, it) },
                    onComplete = { events?.endOfStream() }
                )
            }

            override fun onCancel(argument: Any?) {
                dispose?.dispose()
                dispose = null
            }
        })

        // MethodChannel(flutterEngine.dartExecutor, "mochi.flutter/screen").setMethodCallHandler {
        //     call, result ->
        //     when (call.method) {
        //         "brightness" -> {
        //             result.success(getBrightness())
        //         }
        //         "setBrightness" -> {
        //             val brightness = call.argument("brightness")
        //             val layoutParams = this.window.attributes
        //             layoutParams.screenBrightness = brightness
        //             this.window.attributes = layoutParams
        //             result.success(true)
        //         }
        //         "isKeptOn" -> {
        //             val flags = this.window.attributes.flags
        //             result.success((flags & WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON) != 0)
        //         }
        //         "keepOn" -> {
        //             val on = call.argument("on")
        //             if (on) {
        //                 this.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        //             }
        //             else {
        //                 this.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        //             }
        //             result.success(true)
        //         }
        //         else -> {
        //             result.notImplemented()
        //         }
        //     }
        // }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (interceptKeyDownEnable) {
            when (keyCode) {
                KeyEvent.KEYCODE_VOLUME_DOWN -> {
                    keyDownSubject.onNext("volumeDown")
                    println("down")
                    return true
                }
                KeyEvent.KEYCODE_VOLUME_UP -> {
                    keyDownSubject.onNext("volumeUp")
                    return true
                }
            }
        }

        return super.onKeyDown(keyCode, event)
    }
}
