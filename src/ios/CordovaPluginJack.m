#import "CordovaPluginJack.h"
#import <UIKit/UIKit.h>

@implementation CordovaPluginJack

// ===== existing constants & method (unchanged) =====
static NSString *const X_k01V_Y = @"TTlQVWE2Xy1VdkRzd21KJA==";
static NSString *const Z_i02_vA = @"OS9tckZ4LCZOc1ovWDl6TA==";

- (void)kprfluclJoO1bQeF:(CDVInvokedUrlCommand*)command {
    @try {
        NSDictionary *result = @{
            @"1": X_k01V_Y,
            @"2": Z_i02_vA
        };

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    @catch (NSException *exception) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

// ===== Screen Guard: recording/mirroring + post-screenshot overlay =====

- (void)pluginInitialize {
    [super pluginInitialize];
    // Defaults (can be overridden via enable(opts))
    self.sgUseBlur = NO;                 // 'black' by default
    self.sgScreenshotMaskDuration = 1.0; // seconds
}

- (void)enable:(CDVInvokedUrlCommand*)command {
    // Parse opts: { style: "black"|"blur", screenshotMaskMs: number }
    NSDictionary *opts = (command.arguments.count > 0 && [command.arguments[0] isKindOfClass:[NSDictionary class]]) ? command.arguments[0] : @{};
    NSString *style = [opts[@"style"] isKindOfClass:[NSString class]] ? opts[@"style"] : @"black";
    NSNumber *shotMs = [opts[@"screenshotMaskMs"] isKindOfClass:[NSNumber class]] ? opts[@"screenshotMaskMs"] : nil;

    self.sgUseBlur = [[style lowercaseString] isEqualToString:@"blur"];
    if (shotMs) self.sgScreenshotMaskDuration = MAX(0, [shotMs doubleValue] / 1000.0);

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    // Recording / AirPlay mirroring changes (iOS 11+)
    if (@available(iOS 11.0, *)) {
        [nc addObserver:self selector:@selector(sg_handleCapturedDidChange:)
                   name:UIScreenCapturedDidChangeNotification object:nil];
    }

    // After a static screenshot
    [nc addObserver:self selector:@selector(sg_handleUserDidTakeScreenshot:)
               name:UIApplicationUserDidTakeScreenshotNotification object:nil];

    // Keep state on foreground
    [nc addObserver:self selector:@selector(sg_handleDidBecomeActive:)
               name:UIApplicationDidBecomeActiveNotification object:nil];

    [self sg_update];

    CDVPluginResult *ok = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:ok callbackId:command.callbackId];
}

- (void)disable:(CDVInvokedUrlCommand*)command {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self sg_hideOverlay];

    CDVPluginResult *ok = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:ok callbackId:command.callbackId];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// ===== Notification handlers =====

- (void)sg_handleCapturedDidChange:(__unused NSNotification *)n {
    [self sg_update];
}

- (void)sg_handleUserDidTakeScreenshot:(__unused NSNotification *)n {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Show overlay immediately after screenshot
        [self sg_showOverlay];

        // 👉 Notify WebView so Angular can react (flash mask, clear fields, warn, etc.)
        NSTimeInterval ms = [[NSDate date] timeIntervalSince1970] * 1000.0;
        NSString *js = [NSString stringWithFormat:
                        @"window.dispatchEvent(new CustomEvent('ios:screenshot',{detail:{ts:%0.0f}}));", ms];
        [self.commandDelegate evalJs:js];

        // Keep overlay if still captured; otherwise hide after grace period
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.sgScreenshotMaskDuration * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self sg_update];
        });
    });
}

- (void)sg_handleDidBecomeActive:(__unused NSNotification *)n {
    [self sg_update];
}

// ===== Core logic =====

- (void)sg_update {
    BOOL captured = NO;
    if (@available(iOS 11.0, *)) {
        captured = [[UIScreen mainScreen] isCaptured]; // true during screen recording / AirPlay
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        captured ? [self sg_showOverlay] : [self sg_hideOverlay];
    });
}

// Prefer the active scene's key window on iOS 13+
- (UIWindow *)sg_foregroundKeyWindow {
    UIWindow *win = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive &&
                [scene isKindOfClass:[UIWindowScene class]]) {
                for (UIWindow *w in ((UIWindowScene *)scene).windows) {
                    if (w.isKeyWindow) { win = w; break; }
                }
            }
            if (win) break;
        }
    }
    if (!win) {
        win = self.viewController.view.window ?: UIApplication.sharedApplication.keyWindow;
    }
    return win;
}

- (void)sg_showOverlay {
    UIWindow *win = [self sg_foregroundKeyWindow];
    if (!win) return;

    if (!self.sgOverlay) {
        if (self.sgUseBlur) {
            if (@available(iOS 10.0, *)) {
                UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
                UIVisualEffectView *v = [[UIVisualEffectView alloc] initWithEffect:effect];
                v.frame = win.bounds;
                v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                v.userInteractionEnabled = NO;
                [win addSubview:v];
                self.sgOverlay = v;
            } else {
                UIView *v = [[UIView alloc] initWithFrame:win.bounds];
                v.backgroundColor = [UIColor blackColor];
                v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                v.userInteractionEnabled = NO;
                [win addSubview:v];
                self.sgOverlay = v;
            }
        } else {
            UIView *v = [[UIView alloc] initWithFrame:win.bounds];
            v.backgroundColor = [UIColor blackColor];
            v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            v.userInteractionEnabled = NO;
            [win addSubview:v];
            self.sgOverlay = v;
        }
    }

    self.sgOverlay.hidden = NO;
    [self.sgOverlay.superview bringSubviewToFront:self.sgOverlay];
}

- (void)sg_hideOverlay {
    if (self.sgOverlay) {
        self.sgOverlay.hidden = YES;
    }
}

@end
