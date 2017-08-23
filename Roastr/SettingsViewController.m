//
//  SettingsViewController.m
//  Roastr
//
//  Created by Ryan Wiener on 12/7/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

@implementation SettingsViewController
{
	NSURLSession *session;
}

- (void)viewDidLoad
{
	session = [NSURLSession sharedSession];
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:topView];
	_options = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 69)];
	_options.contentSize = CGSizeMake(self.view.bounds.size.width, 6 * self.view.bounds.size.height / 4);
	_showUserProfile = [UIButton buttonWithType:UIButtonTypeSystem];
	_showUserProfile.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 4);
	[_showUserProfile addTarget:self action:@selector(loadProfile:) forControlEvents:UIControlEventTouchUpInside];
	[_showUserProfile setAttributedTitle:[[NSAttributedString alloc] initWithString:@"View your profile" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:40]}] forState:UIControlStateNormal];
	_showUserProfile.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[_options addSubview:_showUserProfile];
	_showLeaderboard = [UIButton buttonWithType:UIButtonTypeSystem];
	_showLeaderboard.frame = CGRectMake(0, _showUserProfile.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height / 4);
	[_showLeaderboard addTarget:self action:@selector(loadLeaderboard:) forControlEvents:UIControlEventTouchUpInside];
	[_showLeaderboard setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Leaderboards" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:40]}] forState:UIControlStateNormal];
	_showLeaderboard.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[_options addSubview:_showLeaderboard];
	_friendRequests = [UIButton buttonWithType:UIButtonTypeSystem];
	_friendRequests.frame = CGRectMake(0, 2 * _showUserProfile.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height / 4);
	[_friendRequests addTarget:self action:@selector(loadFriendRequestsViewController:) forControlEvents:UIControlEventTouchUpInside];
	[_friendRequests setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Enemy Requests" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:40]}] forState:UIControlStateNormal];
	_friendRequests.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[_options addSubview:_friendRequests];
	_logOut = [UIButton buttonWithType:UIButtonTypeSystem];
	_logOut.frame = CGRectMake(0, 3 * _showUserProfile.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height / 4);
	[_logOut addTarget:self action:@selector(logOut:) forControlEvents:UIControlEventTouchUpInside];
	[_logOut setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Log Out" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:40]}] forState:UIControlStateNormal];
	_logOut.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[_options addSubview:_logOut];
	_logOut = [UIButton buttonWithType:UIButtonTypeSystem];
	_logOut.frame = CGRectMake(0, 3 * _showUserProfile.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height / 4);
	[_logOut addTarget:self action:@selector(logOut:) forControlEvents:UIControlEventTouchUpInside];
	[_logOut setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Log Out" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:40]}] forState:UIControlStateNormal];
	_logOut.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[_options addSubview:_logOut];
	_removeAds = [UIButton buttonWithType:UIButtonTypeSystem];
	_removeAds.frame = CGRectMake(0, 4 * _showUserProfile.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height / 4);
	[_removeAds addTarget:self action:@selector(tapsRemoveAds:) forControlEvents:UIControlEventTouchUpInside];
	[_removeAds setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Remove Ads" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:40]}] forState:UIControlStateNormal];
	_removeAds.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[_options addSubview:_removeAds];
	_restorePurchases = [UIButton buttonWithType:UIButtonTypeSystem];
	_restorePurchases.frame = CGRectMake(0, 5 * _showUserProfile.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height / 4);
	[_restorePurchases addTarget:self action:@selector(restore:) forControlEvents:UIControlEventTouchUpInside];
	[_restorePurchases setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Restore Purchases" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:40]}] forState:UIControlStateNormal];
	_restorePurchases.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[_options addSubview:_restorePurchases];
	[self.view addSubview:_options];
}

- (void)loadProfile:(id)sender
{
	ProfileViewController *profilePage = [[ProfileViewController alloc] initWithUserID:[AppDelegate getUserID]];
	[self presentViewController:profilePage animated:YES completion:nil];
}

- (void)loadLeaderboard:(id)sender
{
	LeaderboardViewController *leaderboardPage = [[LeaderboardViewController alloc] init];
	[self presentViewController:leaderboardPage animated:YES completion:nil];
}

- (void)loadFriendRequestsViewController:(id)sender
{
	FriendRequestsViewController *profilePage = [[FriendRequestsViewController alloc] initWithUserID:[AppDelegate getUserID]];
	[self presentViewController:profilePage animated:YES completion:nil];
}

- (void)logOut:(id)sender
{
	AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate logOut];
}

#define removeAdsProductIdentifier @"Roastr.RemoveAds"

- (IBAction)tapsRemoveAds:(id)sender
{
	NSLog(@"User requests to remove ads");
	
	if([SKPaymentQueue canMakePayments]){
		NSLog(@"User can make payments");
		
		//If you have more than one in-app purchase, and would like
		//to have the user purchase a different product, simply define
		//another function and replace kRemoveAdsProductIdentifier with
		//the identifier for the other product
		
		SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:removeAdsProductIdentifier]];
		productsRequest.delegate = self;
		[productsRequest start];
	}
	else{
		NSLog(@"User cannot make payments due to parental controls");
		//this is called the user cannot make payments, most likely due to parental controls
	}
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
	SKProduct *validProduct = nil;
	int count = (int)[response.products count];
	if(count > 0){
		validProduct = [response.products objectAtIndex:0];
		NSLog(@"Products Available!");
		[self purchase:validProduct];
	}
	else if(!validProduct){
		NSLog(@"No products available");
		//this is called if your product id is not valid, this shouldn't be called unless that happens.
	}
}

- (void)purchase:(SKProduct *)product{
	SKPayment *payment = [SKPayment paymentWithProduct:product];
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (IBAction)restore:(id)sender
{
	//this is called when the user restores purchases, you should hook this up to a button
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
	for(SKPaymentTransaction *transaction in queue.transactions){
		if(transaction.transactionState == SKPaymentTransactionStateRestored){
			//called when the user successfully restores a purchase
			NSLog(@"Transaction state -> Restored");
			
			//if you have more than one in-app purchase product,
			//you restore the correct product for the identifier.
			//For example, you could use
			//if(productID == removeAdsProductIdentifier)
			//to get the product identifier for the
			//restored purchases, you can use
			//
			//NSString *productID = transaction.payment.productIdentifier;
			[self doRemoveAds];
			[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
			break;
		}
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
	for(SKPaymentTransaction *transaction in transactions){
		switch(transaction.transactionState){
			case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
				//called when the user is in the process of purchasing, do not add any of your own code here.
				break;
			case SKPaymentTransactionStateDeferred:
				NSLog(@"TRansaction state -> Deffered");
				break;
			case SKPaymentTransactionStatePurchased:
				//this is called when the user has successfully purchased the package (Cha-Ching!)
				[self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				NSLog(@"Transaction state -> Purchased");
				break;
			case SKPaymentTransactionStateRestored:
				NSLog(@"Transaction state -> Restored");
				//add the same code as you did from SKPaymentTransactionStatePurchased here
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				//called when the transaction does not finish
				if(transaction.error.code == SKErrorPaymentCancelled){
					NSLog(@"Transaction state -> Cancelled");
					//the user cancelled the payment ;(
				}
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
		}
	}
}

- (void)doRemoveAds
{
	[AppDelegate setAdsRemoved:YES];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/removeAds.php?arg1=%d", [AppDelegate getUserID]]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  NSLog(@"%@", text);
									  dispatch_async(dispatch_get_main_queue(), ^{
										  
									  });
								  }];
	[task resume];
}

@end
