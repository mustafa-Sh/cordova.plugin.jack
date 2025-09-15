#import "CordovaPluginJack.h"

@implementation CordovaPluginJack

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

@end