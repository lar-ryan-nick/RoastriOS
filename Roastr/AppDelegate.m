//
//  AppDelegate.m
//  Roastr
//
//  Created by Ryan Wiener on 1/29/16.
//  Copyright © 2016 Ryan Wiener. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
	NSURLSession *session;
	NSString *token;
}

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	NSLog(@"%@", launchOptions);
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	session = [NSURLSession sharedSession];
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	userID = [[[NSUserDefaults standardUserDefaults] stringForKey:@"userID"] intValue];
	[_window makeKeyAndVisible];
	[self setWindow:_window];
	[GADMobileAds configureWithApplicationID:@"ca-app-pub-9745963391546811~9209409684"];
	if (userID == 0)
	{
		[self logOut];
	}
	else
	{
		[self logUser];
		/*
		if (launchOptions != nil)
		{
			NSLog(@"%@", launchOptions);
			int postID = [[[launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] valueForKey:@"postID"] intValue];
			int sender = [[[launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] valueForKey:@"sender"] intValue];
			int user = [[[launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] valueForKey:@"userID"] intValue];
			if (postID > 0)
			{
				PostViewController *postViewController = [[PostViewController alloc] initWithPostID:postID];
				[self.window.rootViewController presentViewController:postViewController animated:YES completion:nil];
			}
			else if (sender > 0)
			{
				MessagesViewController *messageViewController = [[MessagesViewController alloc] initWithUser1:userID user2:sender];
				[self.window.rootViewController presentViewController:messageViewController animated:YES completion:nil];
				[AppDelegate hideTabBar];
			}
			else if (user > 0)
			{
				ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithUserID:user];
				[self.window.rootViewController presentViewController:profileViewController animated:YES completion:nil];
			}
		}
		 */
	}
	return YES;
}

- (void)logUser
{
	_loggedIn = [[PostsViewController alloc] init];
	_postScreen = [[PostingViewController alloc] init];
	_searchScreen = [[SearchViewController alloc] init];
	_settingsPage = [[SettingsViewController alloc] init];
	_conversationsPage = [[ConversationsViewController alloc] init];
	_postsPresentedViewControllers = [[NSMutableArray alloc] init];
	_searchPresentedViewControllers = [[NSMutableArray alloc] init];
	_settingsPresentedViewControllers = [[NSMutableArray alloc] init];
	_conversationsPresentedViewControllers = [[NSMutableArray alloc] init];
	if ([_window.rootViewController isEqual:_viewController])
	{
		NSString *urlString = [[NSString alloc] initWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getUserInfo.php?arg1='%@'", _viewController.username.text];
		NSURL *url = [[NSURL alloc] initWithString:urlString];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		NSURLSessionDataTask *task = [session dataTaskWithRequest:request
												completionHandler:
									  ^(NSData *data, NSURLResponse *response, NSError *error) {
										  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
										  NSLog(@"%@",text);
										  NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
										  if (error == nil)
										  {
											  [[NSUserDefaults standardUserDefaults] setValue:_viewController.username.text forKey:@"username"];
											  [[NSUserDefaults standardUserDefaults] setValue:_viewController.passwordText forKey:@"password"];
											  [[NSUserDefaults standardUserDefaults] setValue:[info valueForKey:@"id"] forKey:@"userID"];
											  [[NSUserDefaults standardUserDefaults] synchronize];
											  userID = [[info valueForKey:@"id"] intValue];
											  adsRemoved = [[info valueForKey:@"adsRemoved"] boolValue];
											  _loggedIn.sortingOptions.selectedSegmentIndex = 1;
											  [_loggedIn reload];
											  _loggedIn.sortingOptions.selectedSegmentIndex = 0;
											  _viewController = nil;
										  }
									  }];
		[task resume];
	}
	else
	{
		[self registerForRemoteNotifications];
		NSString *urlString = [[NSString alloc] initWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getRemovedAdsForUser.php?arg1='%d'", userID];
		NSURL *url = [[NSURL alloc] initWithString:urlString];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		NSURLSessionDataTask *task = [session dataTaskWithRequest:request
												completionHandler:
									  ^(NSData *data, NSURLResponse *response, NSError *error) {
										  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
										  NSLog(@"Ads Removed: %@",text);
										  if (![@"user doesn't exists" isEqualToString:text])
										  {
											  adsRemoved = [text boolValue];
											  _loggedIn.sortingOptions.selectedSegmentIndex = 1;
											  [_loggedIn reload];
											  _loggedIn.sortingOptions.selectedSegmentIndex = 0;
											  /*
											  [_loggedIn reload];
											   */
										  }
									  }];
		[task resume];
	}
	[_window setRootViewController:_loggedIn];
	tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, _window.bounds.size.height - 49, _window.bounds.size.width, 49)];
	[tabBar setBarTintColor:[UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1]];
	[tabBar setTintColor:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1]];
	UITabBarItem *homeButton = [[UITabBarItem alloc] initWithTitle:@"Main Page" image:[[UIImage imageNamed:@"home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] tag:0];
	[homeButton setSelectedImage:[UIImage imageNamed:@"home.png"]];
	UITabBarItem *postButton = [[UITabBarItem alloc] initWithTitle:@"Post" image:[[UIImage imageNamed:@"campfire.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] tag:1];
	[postButton setSelectedImage:[UIImage imageNamed:@"campfire.png"]];
	UITabBarItem *searchButton = [[UITabBarItem alloc] initWithTitle:@"Search" image:[[UIImage imageNamed:@"search.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] tag:2];
	[searchButton setSelectedImage:[[UIImage imageNamed:@"searchHighlighted.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
	UITabBarItem *messagesButton = [[UITabBarItem alloc] initWithTitle:@"Messages" image:[[UIImage imageNamed:@"heart.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] tag:3];
	[messagesButton setSelectedImage:[[UIImage imageNamed:@"heartHighlighted.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
	UITabBarItem *settingsButton = [[UITabBarItem alloc] initWithTitle:@"More" image:[[UIImage imageNamed:@"more.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] tag:4];
	[settingsButton setSelectedImage:[[UIImage imageNamed:@"moreHighlighted.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
	[tabBar setItems:@[homeButton, postButton, searchButton, messagesButton, settingsButton]];
	[[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Wide" size:12]}  forState:UIControlStateNormal];
	[[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Wide" size:12]} forState:UIControlStateSelected];
	tabBar.delegate = self;
	tabBar.selectedItem = homeButton;
	[_loggedIn.view addSubview:tabBar];
}

- (void)logOut
{
	_loggedIn = nil;
	_postScreen = nil;
	_searchScreen = nil;
	_settingsPage = nil;
	_conversationsPage = nil;
	_postsPresentedViewControllers = nil;
	_searchPresentedViewControllers = nil;
	_settingsPresentedViewControllers = nil;
	_conversationsPresentedViewControllers = nil;
	_viewController = [[ViewController alloc] init];
	[_window setRootViewController:_viewController];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	[tabBar removeFromSuperview];
	if ([_window.rootViewController isEqual:_loggedIn])
	{
		UIViewController *viewController = _loggedIn.presentedViewController;
		while (viewController != nil)
		{
			[_postsPresentedViewControllers addObject:viewController];
			viewController = viewController.presentedViewController;
		}
		[_loggedIn dismissViewControllerAnimated:NO completion:nil];
	}
	else if ([_window.rootViewController isEqual:_searchScreen])
	{
		UIViewController *viewController = _searchScreen.presentedViewController;
		while (viewController != nil)
		{
			[_searchPresentedViewControllers addObject:viewController];
			viewController = viewController.presentedViewController;
		}
		[_searchScreen dismissViewControllerAnimated:NO completion:nil];
	}
	else if ([_window.rootViewController isEqual:_conversationsPage])
	{
		UIViewController *viewController = _conversationsPage.presentedViewController;
		while (viewController != nil)
		{
			[_conversationsPresentedViewControllers addObject:viewController];
			viewController = viewController.presentedViewController;
		}
		[_conversationsPage dismissViewControllerAnimated:NO completion:nil];
	}
	else if ([_window.rootViewController isEqual:_settingsPage])
	{
		UIViewController *viewController = _settingsPage.presentedViewController;
		while (viewController != nil)
		{
			[_settingsPresentedViewControllers addObject:viewController];
			viewController = viewController.presentedViewController;
		}
		[_settingsPage dismissViewControllerAnimated:NO completion:nil];
	}
	if (item.tag == 0)
	{
		if (![_window.rootViewController isEqual:_loggedIn])
		{
			[_window setRootViewController:_loggedIn];
			if ([_postsPresentedViewControllers count] > 0)
			{
				[_loggedIn presentViewController:[_postsPresentedViewControllers objectAtIndex:0] animated:NO completion:nil];
				for (int i = 1; i < [_postsPresentedViewControllers count]; i++)
				{
					[[_postsPresentedViewControllers objectAtIndex:i - 1] presentViewController:[_postsPresentedViewControllers objectAtIndex:i] animated:NO completion:nil];
				}
				[[_postsPresentedViewControllers lastObject].view addSubview:tabBar];
			}
			else
			{
				[_loggedIn.view addSubview:tabBar];
			}
			_postsPresentedViewControllers = [[NSMutableArray alloc] init];
		}
		else
		{
			_postsPresentedViewControllers = [[NSMutableArray alloc] init];
			[_loggedIn dismissViewControllerAnimated:YES completion:nil];
			[_loggedIn.view addSubview:tabBar];
		}
	}
	else if (item.tag == 1)
	{
		if (![_window.rootViewController isEqual:_postScreen])
		{
			[_window setRootViewController:_postScreen];
		}
		[_window addSubview:tabBar];
	}
	else if (item.tag == 2)
	{
		if (_searchScreen == nil)
		{
			_searchScreen = [[SearchViewController alloc] init];
		}
		if (![_window.rootViewController isEqual:_searchScreen])
		{
			[_window setRootViewController:_searchScreen];
			if ([_searchPresentedViewControllers count] > 0)
			{
				[_searchScreen presentViewController:[_searchPresentedViewControllers objectAtIndex:0] animated:NO completion:nil];
				for (int i = 1; i < [_searchPresentedViewControllers count]; i++)
				{
					[[_searchPresentedViewControllers objectAtIndex:i - 1] presentViewController:[_searchPresentedViewControllers objectAtIndex:i] animated:NO completion:nil];
				}
				[[_searchPresentedViewControllers lastObject].view addSubview:tabBar];
			}
			else
			{
				[_searchScreen.view addSubview:tabBar];
			}
			_searchPresentedViewControllers = [[NSMutableArray alloc] init];
		}
		else
		{
			_searchPresentedViewControllers = [[NSMutableArray alloc] init];
			[_searchScreen dismissViewControllerAnimated:YES completion:nil];
			[_searchScreen.view addSubview:tabBar];
		}
	}
	else if (item.tag == 3)
	{
		if (![_window.rootViewController isEqual:_conversationsPage])
		{
			[_window setRootViewController:_conversationsPage];
			if ([_conversationsPresentedViewControllers count] > 0)
			{
				[_conversationsPage presentViewController:[_conversationsPresentedViewControllers objectAtIndex:0] animated:NO completion:nil];
				for (int i = 1; i < [_conversationsPresentedViewControllers count]; i++)
				{
					[[_conversationsPresentedViewControllers objectAtIndex:i - 1] presentViewController:[_conversationsPresentedViewControllers objectAtIndex:i] animated:NO completion:nil];
				}
				[[_conversationsPresentedViewControllers lastObject].view addSubview:tabBar];
			}
			else
			{
				[_conversationsPage.view addSubview:tabBar];
			}
			_conversationsPresentedViewControllers = [[NSMutableArray alloc] init];
		}
		else
		{
			_conversationsPresentedViewControllers = [[NSMutableArray alloc] init];
			[_conversationsPage dismissViewControllerAnimated:YES completion:nil];
			[_conversationsPage.view addSubview:tabBar];
		}
	}
	else if (item.tag == 4)
	{
		if (![_window.rootViewController isEqual:_settingsPage])
		{
			[_window setRootViewController:_settingsPage];
			if ([_settingsPresentedViewControllers count] > 0)
			{
				[_settingsPage presentViewController:[_settingsPresentedViewControllers objectAtIndex:0] animated:NO completion:nil];
				for (int i = 1; i < [_settingsPresentedViewControllers count]; i++)
				{
					[[_settingsPresentedViewControllers objectAtIndex:i - 1] presentViewController:[_settingsPresentedViewControllers objectAtIndex:i] animated:NO completion:nil];
				}
				[[_settingsPresentedViewControllers lastObject].view addSubview:tabBar];
			}
			else
			{
				[_settingsPage.view addSubview:tabBar];
			}
			_settingsPresentedViewControllers = [[NSMutableArray alloc] init];
		}
		else
		{
			_settingsPresentedViewControllers = [[NSMutableArray alloc] init];
			[_settingsPage dismissViewControllerAnimated:YES completion:nil];
			[_settingsPage.view addSubview:tabBar];
		}
	}
	tabBar.userInteractionEnabled = YES;
}

+ (UITabBar*)getTabBar
{
	return tabBar;
}

+ (void)hideTabBar
{
	[tabBar setHidden:YES];
}

+ (void)showTabBar
{
	[tabBar setHidden:NO];
}

+ (int)getUserID
{
	return userID;
}

+ (BOOL)getAdsRemoved;
{
	return adsRemoved;
}

+ (void)setAdsRemoved:(BOOL)removedAds;
{
	adsRemoved = removedAds;
}

- (IBAction)closeProfile:(id)sender
{
	[self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)registerForRemoteNotifications
{
	if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0"))
	{
		UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
		center.delegate = self;
		[center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
		 {
			 if( !error )
			 {
				 [[UIApplication sharedApplication] registerForRemoteNotifications];
			 }
		 }];
	}
	else
	{
		[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
		[[UIApplication sharedApplication] registerForRemoteNotifications];
		NSLog(@"current notifications : %@", [[UIApplication sharedApplication] currentUserNotificationSettings]);
	}
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSString *device = [deviceToken description];
	device = [device stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	device = [device stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSLog(@"My device is: %@", device);
	token = device;
	[self updateDeviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error
{
	NSLog(@"%@", error);
}

//Called when a notification is delivered to a foreground app.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
	NSDictionary *userInfo = notification.request.content.userInfo;
	NSLog(@"User Info : %@", userInfo);
	UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController].presentedViewController;
	int i;
	for (i = 0; viewController != nil; i++)
	{
		viewController = viewController.presentedViewController;
	}
	viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
	for (int j = 0; j < i; j++)
	{
		viewController = viewController.presentedViewController;
	}
	if ([viewController isKindOfClass:[MessagesViewController class]])
	{
		MessagesViewController *messageViewController = (MessagesViewController*)viewController;
		if (messageViewController.user1ID == [[userInfo valueForKey:@"sender"] intValue] || messageViewController.user2ID == [[userInfo valueForKey:@"sender"] intValue])
		{
			[messageViewController refreshMessages];
			return;
		}
	}
	completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

//Called to let your app know which action was selected by the user for a given notification.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler
{
	NSDictionary *userInfo = response.notification.request.content.userInfo;
	NSLog(@"User Info : %@", userInfo);
	int postID = [[userInfo valueForKey:@"postID"] intValue];
	int sender = [[userInfo valueForKey:@"sender"] intValue];
	int user = [[userInfo valueForKey:@"userID"] intValue];
	//NSLog(@"%d", postID);
	if (postID > 0)
	{
		PostViewController *postViewController = [[PostViewController alloc] initWithPostID:postID];
		UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController].presentedViewController;
		int i;
		for (i = 0; viewController != nil; i++)
		{
			viewController = viewController.presentedViewController;
		}
		viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
		for (int j = 0; j < i; j++)
		{
			viewController = viewController.presentedViewController;
		}
		[viewController presentViewController:postViewController animated:YES completion:nil];
	}
	else if (sender > 0)
	{
		MessagesViewController *messageViewController = [[MessagesViewController alloc] initWithUser1:userID user2:sender];
		UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController].presentedViewController;
		int i;
		for (i = 0; viewController != nil; i++)
		{
			viewController = viewController.presentedViewController;
		}
		viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
		for (int j = 0; j < i; j++)
		{
			viewController = viewController.presentedViewController;
		}
		[viewController presentViewController:messageViewController animated:YES completion:nil];
		[AppDelegate hideTabBar];
	}
	else if (user > 0)
	{
		ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithUserID:user];
		[self.window.rootViewController presentViewController:profileViewController animated:YES completion:nil];
	}
	completionHandler();
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController].presentedViewController;
	int i;
	for (i = 0; viewController != nil; i++)
	{
		viewController = viewController.presentedViewController;
	}
	viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
	for (int j = 0; j < i; j++)
	{
		viewController = viewController.presentedViewController;
	}
	if ([viewController isKindOfClass:[MessagesViewController class]])
	{
		MessagesViewController *messageViewController = (MessagesViewController*)viewController;
		if (messageViewController.user1ID == [[userInfo valueForKey:@"sender"] intValue] || messageViewController.user2ID == [[userInfo valueForKey:@"sender"] intValue])
		{
			[messageViewController refreshMessages];
		}
	}
	/*
	 if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
	 {
		NSLog(@"User Info : %@", userInfo);
		int postID = [[userInfo valueForKey:@"postID"] intValue];
		NSLog(@"%d", postID);
		if (postID > 0)
		{
	 PostViewController *postViewController = [[PostViewController alloc] initWithPostID:postID];
	 [self.window.rootViewController presentViewController:postViewController animated:YES completion:nil];
		}
	 }
	 */
}

- (void)updateDeviceToken
{
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/setDeviceTokenForUser.php?arg1='%@'&arg2=%d", token, userID];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  NSLog(@"%@",text);
								  }];
	[task resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	
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
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
