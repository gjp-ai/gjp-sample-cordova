#import "NativeSession.h"

static NSString * const NativeSessionDidRequestLogoutNotification = @"NativeSessionDidRequestLogout";

@implementation NativeSession

- (void)logout:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
            postNotificationName:NativeSessionDidRequestLogoutNotification
            object:nil];
    });
}

@end
