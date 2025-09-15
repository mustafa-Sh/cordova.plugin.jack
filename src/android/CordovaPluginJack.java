package cordova.plugin.jack;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaInterface;

import android.os.Bundle;
import android.os.Build;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import static android.view.MotionEvent.FLAG_WINDOW_IS_OBSCURED;
import static android.view.MotionEvent.FLAG_WINDOW_IS_PARTIALLY_OBSCURED;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebSettings;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class CordovaPluginJack extends CordovaPlugin {

    private WebView webView;
    private static final String X_k01V_Y = "TTlQVWE2Xy1VdkRzd21KJA==";
    private static final String Z_i02_vA = "OS9tckZ4LCZOc1ovWDl6TA==";
    

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("pl5zyyMtbzNpFsQ0")) {
            this.pl5zyyMtbzNpFsQ0(callbackContext);
            return true;
        }
        if (action.equals("ciNHTYHuzuwTN65D")) {
            this.ciNHTYHuzuwTN65D(callbackContext);
            return true;
        }
        if (action.equals("kprfluclJoO1bQeF")) {
            this.kprfluclJoO1bQeF(callbackContext);
            return true;
        }
        return false;
    }

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        webView.getView().setFilterTouchesWhenObscured(true);
        super.initialize(cordova, webView);
    }

    private void pl5zyyMtbzNpFsQ0(CallbackContext callbackContext) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        cordova.getActivity().getWindow().setHideOverlayWindows(true); // For Android API Level 31+
                        callbackContext.success("true");
                    } catch (Exception e) {
                        callbackContext.error("Error enabling protection: " + e.getMessage());
                    }
                }
            });
        } else {
            callbackContext.success("false"); // Not applicable for lower APIs
        }
    }

    private void ciNHTYHuzuwTN65D(CallbackContext callbackContext) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        View mainView = cordova.getActivity().findViewById(android.R.id.content);
                        if (mainView == null) {
                            callbackContext.error("Main view is null.");
                            return;
                        } else {
                            mainView.setOnTouchListener(new View.OnTouchListener() {
                                @Override
                                public boolean onTouch(View v, MotionEvent event) {
                                    int flags = event.getFlags();
                                    // Checking FLAG_WINDOW_IS_PARTIALLY_OBSCURED for Android API 29+
                                    // Checking FLAG_WINDOW_IS_OBSCURED for Android API 9+ till 28
                                    boolean isObscured = (flags & MotionEvent.FLAG_WINDOW_IS_OBSCURED) != 0;

                                    // Handle partial obscuring for API 29 and 30
                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
                                            && Build.VERSION.SDK_INT <= Build.VERSION_CODES.R) {
                                        isObscured = isObscured
                                                || (flags & MotionEvent.FLAG_WINDOW_IS_PARTIALLY_OBSCURED) != 0;
                                    }

                                    if (isObscured) {
                                        callbackContext.success("true");
                                        return true; // Consume the touch event
                                    }
                                    return false; // Allow normal touch behavior
                                }
                            });
                        }
                    } catch (Exception e) {
                        callbackContext.error("Error enabling obscured touch detection: " + e.getMessage());
                    }
                }
            });
        } else {
            callbackContext.success("false");
        }
    }

    private void kprfluclJoO1bQeF(CallbackContext callbackContext) { 

        try {
            JSONObject result = new JSONObject();
            result.put("1", X_k01V_Y);
            result.put("2", Z_i02_vA);
            callbackContext.success(result);
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }
}