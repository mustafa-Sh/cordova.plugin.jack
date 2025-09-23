#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface CordovaPluginJack : CDVPlugin

// Existing
- (void)kprfluclJoO1bQeF:(CDVInvokedUrlCommand*)command;

// NEW — Screen Guard API
- (void)enable:(CDVInvokedUrlCommand*)command;   // opts: { style: "black"|"blur", screenshotMaskMs: number }
- (void)disable:(CDVInvokedUrlCommand*)command;

// Present a capture-protected single-input form
- (void)addSecureRect:(CDVInvokedUrlCommand*)command; // args: { title?, placeholder?, numeric?, secure?, maxLength?, submitText?, cancelText? }
- (void)clearSecureRects:(CDVInvokedUrlCommand*)command;

// State
@property (nonatomic, strong, readonly) UIView *sgOverlay;
@property (nonatomic, assign, readonly) BOOL sgUseBlur;
@property (nonatomic, assign, readonly) NSTimeInterval sgScreenshotMaskDuration;

@end
