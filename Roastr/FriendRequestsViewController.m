//
//  FriendRequestsViewController.m
//  Roastr
//
//  Created by Ryan Wiener on 12/21/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#import "AppDelegate.h"
#import "FriendsViewController.h"

@implementation FriendRequestsViewController
{
	NSURLSession *session;
	UIActivityIndicatorView *activityIndicator;
}

- (instancetype)initWithUserID:(int)userID
{
	self = [super init];
	_userID = userID;
	return self;
}

- (void)viewDidLoad
{
	if (session == nil)
		session = [NSURLSession sharedSession];
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:topView];
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
	title.text = @"  Enemy Requests";
	title.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1];
	title.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
	title.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:30];
	title.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:title];
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
	backButton.frame = CGRectMake(10, 20, self.view.bounds.size.width / 7, 40);
	[backButton setTintColor:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1]];
	[backButton setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	_numFriends = 0;
	_friendsLoaded = 0;
	_friends = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width , self.view.bounds.size.height - 109) style:UITableViewStylePlain];
	_friends.delegate = self;
	_friends.dataSource = self;
	_friends.separatorStyle = UITableViewCellSeparatorStyleNone;
	_friends.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[self.view addSubview:_friends];
	_friendData = [[NSMutableArray alloc] init];
	_loading = YES;
	[self getFriendCountWithCompletionHandler:^(BOOL completed){
		//NSLog(@"%d", _numFriends);
		[self loadFriends:5];
	}];
	[self.view addSubview:[AppDelegate getTabBar]];
	if (activityIndicator == nil)
	{
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityIndicator.frame = CGRectMake(0, self.view.bounds.size.height - 89, self.view.bounds.size.width, 40);
	}
	[self.view addSubview:activityIndicator];
	[activityIndicator startAnimating];
}

- (void)loadFriends:(int)friends
{
	int i = _friendsLoaded;
	if (friends + _friendsLoaded > _numFriends)
	{
		_friendsLoaded = _numFriends;
	}
	else
	{
		_friendsLoaded += friends;
	}
	while (i < _friendsLoaded)
	{
		[self getFriendWithIndex:i];
		i++;
	}
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
	_loading = NO;
}

- (void)getFriendWithIndex:(int)index
{
	NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getFriendRequestData.php?arg1=%d&arg2=%d", _userID, _numFriends - index]];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
									  {
										  if (error != nil)
										  {
											  NSLog(@"Error: %@", [error localizedDescription]);
										  }
										  else
										  {
											  NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
											  if (object != nil)
											  {
												  [_friendData addObject:object];
												  //NSLog(@"%@", object);
												  //[self sortFriendData];
												  dispatch_async(dispatch_get_main_queue(), ^{
													  [_friends reloadData];
												  });
											  }
											  else
											  {
												  NSLog(@"Error: %@", [error localizedDescription]);
											  }
										  }
									  }];
	[dataTask resume];
}
/*
 - (void)sortFriendData
 {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
	formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	for (int i = 0; i < [_friendData count]; i++)
	{
 NSDictionary *data1 = [_friendData objectAtIndex:i];
 NSDate *date1 = [formatter dateFromString:[data1 valueForKey:@"lastSent"]];
 int latest = i;
 for (int j = i + 1; j < [_friendData count]; j++)
 {
 NSDictionary *data2 = [_friendData objectAtIndex:j];
 NSDate *date2 = [formatter dateFromString:[data2 valueForKey:@"lastSent"]];
 if ([date1 compare:date2] == NSOrderedDescending)
 {
 }
 else if ([date1 compare:date2] == NSOrderedAscending)
 {
 latest = j;
 date1 = date2;
 }
 else
 {
 NSLog(@"dates are the same");
 }
 }
 [_friendData exchangeObjectAtIndex:i withObjectAtIndex:latest];
	}
 }
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_numFriends > _friendsLoaded && _friendsLoaded != 0)
	{
		return [_friendData count] + 1;
	}
	return [_friendData count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *simpleTableIdentifier = @"SimpleTableItem";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
	}
	if (_numFriends > _friendsLoaded && indexPath.row == [_friendData count])
	{
		cell.textLabel.text = @"Scroll down to load more Enemies";
		cell.textLabel.textColor = [UIColor grayColor];
		cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
	}
	else
	{
		//long row = _numLikes > _likesLoaded ? indexPath.row -1 : indexPath.row;
		NSDictionary *data = [_friendData objectAtIndex:indexPath.row];
		cell.textLabel.text = [data valueForKey:@"username"];
		cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
		cell.textLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
		cell.textLabel.tag = [[data valueForKey:@"user"] intValue];
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		NSData *imageData = [Base64 decode:[data valueForKey:@"profilePicture"]];
		UIImage  *profilePicture = [UIImage imageWithData:imageData];
		if (profilePicture == nil)
		{
			cell.imageView.image = nil;
		}
		else
		{
			profilePicture = [self roundedRectImageFromImage:profilePicture size:CGSizeMake(40, 40) withCornerRadius:20];
			cell.imageView.image = profilePicture;
		}
		UIButton *decline = [UIButton buttonWithType:UIButtonTypeSystem];
		decline.tag = indexPath.row;
		decline.frame = CGRectMake(cell.contentView.bounds.size.width - 70, 15, 30, 30);
		[decline setImage:[UIImage imageNamed:@"x.png"] forState:UIControlStateNormal];
		[decline setTintColor:[UIColor redColor]];
		[decline addTarget:self action:@selector(removeFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview:decline];
		UIButton *checkmark = [UIButton buttonWithType:UIButtonTypeSystem];
		checkmark.tag = indexPath.row;
		checkmark.frame = CGRectMake(cell.contentView.bounds.size.width - 30, 15, 30, 30);
		[checkmark setImage:[UIImage imageNamed:@"checkmark.png"] forState:UIControlStateNormal];
		[checkmark setTintColor:[UIColor greenColor]];
		[checkmark addTarget:self action:@selector(acceptFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview:checkmark];
		/*
		 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		 formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
		 formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		 NSDate *date = [formatter dateFromString:[data valueForKey:@"lastSent"]];
		 NSLog(@"Date: %@", [formatter stringFromDate:date]);
		 NSLog(@"Time Since: %f minutes", [date timeIntervalSinceNow] / 60);
		 int time = -(int)[date timeIntervalSinceNow];
		 NSString *units = @"seconds";
		 if (time == 1)
		 {
			units = @"second";
		 }
		 else if (time >= 86400)
		 {
			time /= 86400;
			if (time == 1)
			{
		 units = @"day";
			}
			else
			{
		 units = @"days";
			}
		 }
		 else if (time >= 3600)
		 {
			time /= 3600;
			if (time == 1)
			{
		 units = @"hour";
			}
			else
			{
		 units = @"hours";
			}
		 }
		 else if (time >= 60)
		 {
			time /= 60;
			if (time == 1)
			{
		 units = @"minute";
			}
			else
			{
		 units = @"minutes";
			}
		 }
		 cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@ ago", time, units];
		 cell.detailTextLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:15];
		 cell.detailTextLabel.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
		 cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
		 cell.detailTextLabel.numberOfLines = 0;
		 */
	}
	cell.contentView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	return cell;
}
/*
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
	if ([tableView cellForRowAtIndexPath:indexPath].textLabel.tag == [AppDelegate getUserID])
	{
 return YES;
	}
	return NO;
 }
 
 -(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
 {
	UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
 int row = _numComments > _commentsLoaded ? (int)indexPath.row - 1 : (int)indexPath.row;
 [self deleteComment:[[_keys objectAtIndex:row] intValue]];
	}];
	deleteAction.backgroundColor = [UIColor redColor];
	return @[deleteAction];
 }
 
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
 {
	
 }
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}
/*
 - (IBAction)closeProfile:(id)sender
 {
	[self dismissViewControllerAnimated:YES completion:nil];
	[AppDelegate showTabBar];
 }
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	ProfileViewController *profilePage = [[ProfileViewController alloc] initWithUserID:(int)cell.textLabel.tag];
	[self presentViewController:profilePage animated:YES completion:nil];
}

- (void)getFriendCountWithCompletionHandler:(void (^)(BOOL completed))completionHandler
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getNumFriendRequests.php?arg1=%d", [AppDelegate getUserID]]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  _numFriends = [text intValue];
									  dispatch_async(dispatch_get_main_queue(), ^{
										  completionHandler(YES);
									  });
								  }];
	[task resume];
}

- (void)acceptFriendRequest:(UIButton*)sender
{
	[sender removeFromSuperview];
	int row = (int)sender.tag;
	int user = [[[_friendData objectAtIndex:row] valueForKey:@"user"] intValue];
	[_friendData removeObjectAtIndex:row];
	[_friends reloadData];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/acceptFriendRequestBetweenUsers.php?user1=%d&user2=%d", user, [AppDelegate getUserID]]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  NSLog(@"%@", text);
								  }];
	[task resume];
}

- (void)removeFriendRequest:(UIButton*)sender
{
	[sender removeFromSuperview];
	int row = (int)sender.tag;
	int user = [[[_friendData objectAtIndex:row] valueForKey:@"user"] intValue];
	[_friendData removeObjectAtIndex:row];
	[_friends reloadData];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/removeFriendRequestBetweenUsers.php?user1=%d&user2=%d", user, [AppDelegate getUserID]]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  NSLog(@"%@", text);
								  }];
	[task resume];
}

- (IBAction)dismissSelf:(id)sender
{
	[self.presentingViewController.view addSubview:[AppDelegate getTabBar]];
	[self dismissViewControllerAnimated:YES completion:nil];
	[AppDelegate showTabBar];
}

- (UIImage*)roundedRectImageFromImage:(UIImage *)image size:(CGSize)imageSize withCornerRadius:(float)cornerRadius
{
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
	CGRect bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
	[[UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:cornerRadius] addClip];
	[image drawInRect:bounds];
	UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return finalImage;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.size.height)
	{
		if (!_loading)
		{
			if (_friendsLoaded < _numFriends)
			{
				activityIndicator.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
				[self.view addSubview:activityIndicator];
				[activityIndicator startAnimating];
				_loading = YES;
				[self getFriendCountWithCompletionHandler:^(BOOL completed){
					[self loadFriends:5];
				}];
			}
		}
	}
}

@end
