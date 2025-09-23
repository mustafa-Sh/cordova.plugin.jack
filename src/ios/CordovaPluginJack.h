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
@property (nonatomic, strong) UIView *sgOverlay;
@property (nonatomic, assign) BOOL sgUseBlur;
@property (nonatomic, assign) NSTimeInterval sgScreenshotMaskDuration;

@end
