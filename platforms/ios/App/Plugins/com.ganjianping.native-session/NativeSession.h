#import <Cordova/CDVPlugin.h>

@interface NativeSession : CDVPlugin

- (void)logout:(CDVInvokedUrlCommand *)command;

@end
