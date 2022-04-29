#import "OpeninstallFlutterPlugin.h"

#import "InvitationSDK.h"

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, OpenInstallSDKPluginMethod) {
    OpenInstallSDKMethodInit,
    OpenInstallSDKMethodGetInstallParams,
    OpenInstallSDKMethodReportRegister,
    OpenInstallSDKMethodReportEffectPoint
};

@interface OpeninstallFlutterPlugin () <InvitationDelegate>
@property (strong, nonatomic, readonly) NSDictionary *methodDict;
@property (strong, nonatomic) FlutterMethodChannel * flutterMethodChannel;
@property (assign, nonatomic) BOOL isOnWakeup;
@property (strong, nonatomic)NSDictionary *cacheDic;
@end

static FlutterMethodChannel * FLUTTER_METHOD_CHANNEL;
static NSDictionary *cacheDic_;
@implementation OpeninstallFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel * channel = [FlutterMethodChannel methodChannelWithName:@"openinstall_flutter_plugin" binaryMessenger:[registrar messenger]];
    OpeninstallFlutterPlugin* instance = [[OpeninstallFlutterPlugin alloc] init];

    [InvitationSDK initWithDelegate:instance];

    instance.flutterMethodChannel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];

    [registrar addApplicationDelegate:instance];

}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData {
    _methodDict = @{
                    @"registerWakeup"         :      @(OpenInstallSDKMethodInit),
                    @"getInstall"             :      @(OpenInstallSDKMethodGetInstallParams),
                    @"reportRegister"         :      @(OpenInstallSDKMethodReportRegister),
                    @"reportEffectPoint"      :      @(OpenInstallSDKMethodReportEffectPoint)
                    };
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSNumber *methodType = self.methodDict[call.method];
    if (methodType) {
        switch (methodType.intValue) {
            case OpenInstallSDKMethodInit:
            {
                self.isOnWakeup = YES;
                NSDictionary *dict = [[NSDictionary alloc]init];
                if (cacheDic_.count != 0) {
                    dict = [cacheDic_ copy];
                }else{
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"openinstall_flutter_wakeupCache"]) {
                        dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"openinstall_flutter_wakeupCache"];
                    }
                }
//                NSLog(@"---openinstall--OpenInstallSDKMethodInit--%@",dict);
                if (dict.count != 0) {
                    [self.flutterMethodChannel invokeMethod:@"onWakeupNotification" arguments:dict];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"openinstall_flutter_wakeupCache"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                break;
            }
            case OpenInstallSDKMethodGetInstallParams:
            {
                int time = (int) call.arguments[@"timeout"];
                if (time <= 0) {
                    time = 8;
                }
                [[InvitationSDK defaultManager] getInstallParmsWithTimeoutInterval:time completed:^(InvitationData * _Nullable appData) {
                    [self installParamsResponse:appData];
                }];
                break;
            }
            case OpenInstallSDKMethodReportRegister:
            {
                [InvitationSDK reportRegister];
                break;
            }
            case OpenInstallSDKMethodReportEffectPoint:
            {
                NSDictionary * args = call.arguments;
                NSNumber * pointValue = (NSNumber *) args[@"pointValue"];
                [[InvitationSDK defaultManager] reportEffectPoint:(NSString *)args[@"pointId"] effectValue:[pointValue longValue]];
                break;
            }
            default:
            {
                break;
            }
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Openinstall Notify Flutter Mehtod
- (void)installParamsResponse:(InvitationData *) appData {
    NSDictionary *args = [self convertInstallArguments:appData];
    [self.flutterMethodChannel invokeMethod:@"onInstallNotification" arguments:args];
}

- (void)wakeUpParamsResponse:(InvitationData *) appData {
    NSDictionary *args = [self convertInstallArguments:appData];
    if (self.isOnWakeup == YES) {
        [self.flutterMethodChannel invokeMethod:@"onWakeupNotification" arguments:args];
    }else{
        cacheDic_ = [[NSDictionary alloc]init];
        cacheDic_ = args;
        [[NSUserDefaults standardUserDefaults] setObject:args forKey:@"openinstall_flutter_wakeupCache"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
//    NSLog(@"---openinstall--wakeUpParamsResponse--%@",args);
}

- (NSDictionary *)convertInstallArguments:(InvitationData *) appData {
    NSString *channelCode = @"";
    NSString *bindData = @"";
    if (appData.channelCode != nil) {
        channelCode = appData.channelCode;
    }
    if (appData.data != nil) {
        bindData = [self jsonStringWithObject:appData.data];
    }
    NSDictionary * dict = @{@"channelCode":channelCode, @"bindData":bindData};
    return dict;
}

- (NSString *)jsonStringWithObject:(id)jsonObject {
    id arguments = (jsonObject == nil ? [NSNull null] : jsonObject);
    NSArray* argumentsWrappedInArr = [NSArray arrayWithObject:arguments];
    NSString* argumentsJSON = [self cp_JSONString:argumentsWrappedInArr];
    if (argumentsJSON.length>2) {argumentsJSON = [argumentsJSON substringWithRange:NSMakeRange(1, [argumentsJSON length] - 2)];}
    return argumentsJSON;
}

- (NSString *)cp_JSONString:(NSArray *)array {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if ([jsonString length] > 0 && error == nil){
        return jsonString;
    } else {
        return @"";
    }
}

#pragma mark - Openinstall API
//通过OpenInstall获取已经安装App被唤醒时的参数（如果是通过渠道页面唤醒App时，会返回渠道编号）
-(void)getWakeUpParams:(InvitationData *) appData{
    [self wakeUpParamsResponse:appData];
}

+ (BOOL)handLinkURL:(NSURL *) url {
    return [InvitationSDK handLinkURL:url];
}

+ (BOOL)continueUserActivity:(NSUserActivity *) userActivity {
    return [InvitationSDK continueUserActivity:userActivity];
}


#pragma mark - Application Delegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [InvitationSDK initWithDelegate:self];
    [OpeninstallFlutterPlugin setUserActivityAndScheme:launchOptions];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [OpeninstallFlutterPlugin handLinkURL:url];
    return NO;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [OpeninstallFlutterPlugin handLinkURL:url];
    return NO;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
#if defined(__IPHONE_12_0)
    restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring> > * _Nullable restorableObjects))restorationHandler
#else
    restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
#endif
{
    [OpeninstallFlutterPlugin continueUserActivity:userActivity];
    return NO;
}

+ (void)setUserActivityAndScheme:(NSDictionary *)launchOptions{
    if (launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey]) {
        NSDictionary *activityDic = [NSDictionary dictionaryWithDictionary:launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey]];

        if ([activityDic[UIApplicationLaunchOptionsUserActivityTypeKey] isEqual: NSUserActivityTypeBrowsingWeb]&&activityDic[@"UIApplicationLaunchOptionsUserActivityKey"]) {
            NSUserActivity *activity = [[NSUserActivity alloc]initWithActivityType:NSUserActivityTypeBrowsingWeb];
            activity = (NSUserActivity *)activityDic[@"UIApplicationLaunchOptionsUserActivityKey"];
            [OpeninstallFlutterPlugin continueUserActivity:activity];
        }
    }else if (launchOptions[UIApplicationLaunchOptionsURLKey]){
        NSURL *url = [[NSURL alloc]init];
        if ([launchOptions[UIApplicationLaunchOptionsURLKey] isKindOfClass:[NSURL class]]) {
            url = launchOptions[UIApplicationLaunchOptionsURLKey];
        }else if ([launchOptions[UIApplicationLaunchOptionsURLKey] isKindOfClass:[NSString class]]){
            url = [NSURL URLWithString:launchOptions[UIApplicationLaunchOptionsURLKey]];
        }
        [OpeninstallFlutterPlugin handLinkURL:url];
    }
}


@end
