#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface CordovaPluginJack : CDVPlugin

// Existing
- (void)kprfluclJoO1bQeF:(CDVInvokedUrlCommand*)command;

// NEW — Screen Guard API
- (void)enable:(CDVInvokedUrlCommand*)command;   // opts: { style: "black"|"blur", screenshotMaskMs: number }
- (void)disable:(CDVInvokedUrlCommand*)command;

// State
@property (nonatomic, strong) UIView *sgOverlay;
@property (nonatomic, assign) BOOL sgUseBlur;
@property (nonatomic, assign) NSTimeInterval sgScreenshotMaskDuration;

@end
