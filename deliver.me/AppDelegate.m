//
//  AppDelegate.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/4/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "AppDelegate.h"

#import "AIClientViewController.h"

#import "AIServerManager.h"
#import "AIUtils.h"

#import <Parse/Parse.h>
#import <LayerKit/LayerKit.h>
#import <Atlas/Atlas.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString* parseAppID = @"zQJzWyKs1XGJ7CHcGmWP1sxYZkYpjFzj5eClBVES";
static NSString* parseClKey = @"1IKHTcIFiGKsbLxFxpOMmM1f47274cEjI11zsZ0u";
static NSString* layerAppID = @"layer:///apps/staging/13cfaf18-3f57-11e5-8565-d6cf66002d2f";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self configureNavigationBar];
    [self connectToParseAndLayer];
    [self configureProgressHud];
    
    
    return YES;
}

- (void) connectToParseAndLayer {
    
    [Parse setApplicationId:parseAppID clientKey:parseClKey];
    [PFUser enableRevocableSessionInBackground];
    
    LYRClient* client = [LYRClient clientWithAppID:[NSURL URLWithString:layerAppID]];
    
    client.autodownloadMIMETypes = [NSSet setWithObjects:
                                    ATLMIMETypeImagePNG,    ATLMIMETypeLocation,
                                    ATLMIMETypeImageJPEG,   ATLMIMETypeImageJPEGPreview,
                                    ATLMIMETypeImageGIF,    ATLMIMETypeImageGIFPreview,
                                    nil];
        
    [AIServerManager sharedManager].client = client;
    
}

- (void) configureNavigationBar {
    
    [[UINavigationBar appearance] setBarTintColor:COLOR_GRAY];
    [[UINavigationBar appearance] setTintColor:COLOR_YELLOW];
    
    NSDictionary* textAttributes = @{NSForegroundColorAttributeName : COLOR_YELLOW};
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    
}

- (void) configureProgressHud {
    
    [SVProgressHUD setBackgroundColor:COLOR_GRAY];
    [SVProgressHUD setForegroundColor:COLOR_YELLOW];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
