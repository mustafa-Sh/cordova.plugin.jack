#import "CordovaPluginJack.h"
#import <UIKit/UIKit.h>

// --- Move the class extension BEFORE the implementation ---
@interface CordovaPluginJack ()
@property (nonatomic, strong, readwrite) UIView *sgOverlay;
@property (nonatomic, assign, readwrite) BOOL sgUseBlur;
@property (nonatomic, assign, readwrite) NSTimeInterval sgScreenshotMaskDuration;
@property (nonatomic, strong, readwrite) NSMutableArray<UITextField*> *jackSecureRects;
@end

@implementation CordovaPluginJack

// ===== existing constants & method (unchanged) =====
static NSString *const X_k01V_Y = @"TTlQVWE2Xy1VdkRzd21KJA==";
static NSString *const Z_i02_vA = @"OS9tckZ4LCZOc1ovWDl6TA==";

- (void)kprfluclJoO1bQeF:(CDVInvokedUrlCommand*)command {
    @try {
        NSDictionary *result = @{ @"1": X_k01V_Y, @"2": Z_i02_vA };
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsDictionary:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    @catch (NSException *exception) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                         messageAsString:exception.reason];
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
    NSDictionary *opts = (command.arguments.count > 0 &&
                          [command.arguments[0] isKindOfClass:[NSDictionary class]])
                         ? command.arguments[0] : @{};
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
    [self jr_clearSecureRects]; // also clear any secure rects

    CDVPluginResult *ok = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:ok callbackId:command.callbackId];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self jr_clearSecureRects];
}

// ===== Notification handlers =====

- (void)sg_handleCapturedDidChange:(__unused NSNotification *)n {
    [self sg_update];
}

- (void)sg_handleUserDidTakeScreenshot:(__unused NSNotification *)n {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sg_showOverlay];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(self.sgScreenshotMaskDuration * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self sg_update];
        });
    });
}

- (void)sg_handleDidBecomeActive:(__unused NSNotification *)n {
    [self sg_update];
}

// ===== Core logic (screen recording / mirroring) =====

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
- (UIWindow *)jr_foregroundKeyWindow {
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
    UIWindow *win = [self jr_foregroundKeyWindow];
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

#pragma mark - Secure rectangle overlays (black only in captures)

// Convert CSS viewport rect (CSS px) to window coordinates (points)
- (CGRect)jr_convertCSSRectToWindowPoints:(NSDictionary *)opts {
    CGFloat dpr = [opts[@"dpr"] respondsToSelector:@selector(doubleValue)]
                  ? [opts[@"dpr"] doubleValue]
                  : UIScreen.mainScreen.scale;

    CGFloat x = [opts[@"x"] doubleValue] / dpr;
    CGFloat y = [opts[@"y"] doubleValue] / dpr;
    CGFloat w = [opts[@"width"] doubleValue] / dpr;
    CGFloat h = [opts[@"height"] doubleValue] / dpr;

    UIView *wv = (UIView *)self.webView;
    UIWindow *win = [self jr_foregroundKeyWindow];
    if (!wv || !win) return CGRectZero;

    // WebView frame in window coords (points)
    CGRect webFrameInWindow = [wv.superview convertRect:wv.frame toView:win];

    return CGRectMake(webFrameInWindow.origin.x + x,
                      webFrameInWindow.origin.y + y,
                      w, h);
}

// args: { x, y, width, height, dpr, radius? }
- (void)addSecureRect:(CDVInvokedUrlCommand*)command {
    NSDictionary *opts = (command.arguments.count &&
                          [command.arguments[0] isKindOfClass:[NSDictionary class]])
                         ? command.arguments[0] : @{};
    CGRect r = [self jr_convertCSSRectToWindowPoints:opts];
    CGFloat radius = [opts[@"radius"] respondsToSelector:@selector(doubleValue)]
                     ? [opts[@"radius"] doubleValue] : 8.0;

    if (CGRectIsEmpty(r) || r.size.width <= 0 || r.size.height <= 0) {
        CDVPluginResult *err = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                messageAsString:@"bad rect"];
        [self.commandDelegate sendPluginResult:err callbackId:command.callbackId];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.jackSecureRects) self.jackSecureRects = [NSMutableArray array];

        // Secure overlay: UITextField with secureTextEntry = YES
        UITextField *secureOverlay = [[UITextField alloc] initWithFrame:r];
        secureOverlay.secureTextEntry = YES;       // 🔒 excluded from screenshots/recordings
        secureOverlay.text = @" ";                 // keep secure path engaged
        secureOverlay.userInteractionEnabled = NO; // let touches pass through to HTML input
        secureOverlay.backgroundColor = [UIColor clearColor];
        secureOverlay.layer.cornerRadius = radius;
        secureOverlay.clipsToBounds = YES;

        // If reliability issues on a device/iOS, you can force a tiny alpha:
        // secureOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.01];

        UIWindow *win = [self jr_foregroundKeyWindow];
        [win addSubview:secureOverlay];
        [self.jackSecureRects addObject:secureOverlay];

        CDVPluginResult *ok = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:ok callbackId:command.callbackId];
    });
}

- (void)clearSecureRects:(CDVInvokedUrlCommand*)command {
    [self jr_clearSecureRects];
    CDVPluginResult *ok = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:ok callbackId:command.callbackId];
}

// Internal helper (no plugin result)
- (void)jr_clearSecureRects {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UITextField *v in self.jackSecureRects) { [v removeFromSuperview]; }
        [self.jackSecureRects removeAllObjects];
    });
}

@end
