//
//  LeaderboardViewController.m
//  Roastr
//
//  Created by Ryan Wiener on 12/31/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#import "AppDelegate.h"
#import "LeaderboardViewController.h"

@implementation LeaderboardViewController
{
	NSURLSession *session;
	UIActivityIndicatorView *activityIndicator;
}

- (void)viewDidLoad
{
	if (session == nil)
		session = [NSURLSession sharedSession];
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:topView];
	UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
	bottomView.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1];
	[self.view addSubview:bottomView];
	CGSize size = [@"Roastr" sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Wide" size:30]}];
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - size.width + 40) / 2, 20, size.width, 40)];
	title.text = @"Roastr";
	title.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:30];
	title.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
	[self.view addSubview:title];
	UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - size.width + 40) / 2 - 40, 20, 40, 40)];
	logo.image = [UIImage imageNamed:@"roastrtransparent.png"];
	[self.view addSubview:logo];
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
	backButton.frame = CGRectMake(10, 20, self.view.bounds.size.width / 7, 40);
	[backButton setTintColor:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1]];
	[backButton setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	_numUsers = 0;
	_enemyLeadersLoaded = 0;
	_hateLeadersLoaded = 0;
	_enemyLeaders = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width , self.view.bounds.size.height - 149) style:UITableViewStylePlain];
	_enemyLeaders.delegate = self;
	_enemyLeaders.dataSource = self;
	_enemyLeaders.separatorStyle = UITableViewCellSeparatorStyleNone;
	_enemyLeaders.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[self.view addSubview:_enemyLeaders];
	_hateLeaders = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width , self.view.bounds.size.height - 149) style:UITableViewStylePlain];
	_hateLeaders.delegate = self;
	_hateLeaders.dataSource = self;
	_hateLeaders.separatorStyle = UITableViewCellSeparatorStyleNone;
	_hateLeaders.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	//[self.view addSubview:_hateLeaders];
	_enemyLeadersData = [[NSMutableArray alloc] init];
	_hateLeadersData = [[NSMutableArray alloc] init];
	_loading = YES;
	_leaderType = [[UISegmentedControl alloc] initWithItems:@[@"Most Enemies", @"Most Hates"]];
	_leaderType.frame = CGRectMake(0, 60, self.view.bounds.size.width, 40);
	[_leaderType addTarget:self action:@selector(switchLeaderboard:) forControlEvents:UIControlEventValueChanged];
	[_leaderType setSelectedSegmentIndex:0];
	[_leaderType setTintColor:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1]];
	[_leaderType setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:20]} forState:UIControlStateNormal];
	[_leaderType setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:20]} forState:UIControlStateSelected];
	[_leaderType setBackgroundColor:[UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1]];
	[self.view addSubview:_leaderType];
	[self getUserCountWithCompletionHandler:^(BOOL completed){
		[self loadLeaders:5];
		_leaderType.selectedSegmentIndex = 1;
		[self loadLeaders:5];
		_leaderType.selectedSegmentIndex = 0;
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

- (void)switchLeaderboard:(id)sender
{
	if (_leaderType.selectedSegmentIndex == 0)
	{
		[_hateLeaders removeFromSuperview];
		[self.view addSubview:_enemyLeaders];
	}
	else if (_leaderType.selectedSegmentIndex == 1)
	{
		[_enemyLeaders removeFromSuperview];
		[self.view addSubview:_hateLeaders];
	}
}

- (void)loadLeaders:(int)leaders
{
	if (_leaderType.selectedSegmentIndex == 0)
	{
		int i = _enemyLeadersLoaded;
		if (leaders + _enemyLeadersLoaded > _numUsers)
		{
			_enemyLeadersLoaded = _numUsers;
		}
		else
		{
			_enemyLeadersLoaded += leaders;
		}
		while (i < _enemyLeadersLoaded)
		{
			[self getLeaderWithIndex:i];
			i++;
		}
	}
	else if (_leaderType.selectedSegmentIndex == 1)
	{
		int i = _hateLeadersLoaded;
		if (leaders + _hateLeadersLoaded > _numUsers)
		{
			_hateLeadersLoaded = _numUsers;
		}
		else
		{
			_hateLeadersLoaded += leaders;
		}
		while (i < _hateLeadersLoaded)
		{
			[self getLeaderWithIndex:i];
			i++;
		}
		
	}
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
	_loading = NO;
}

- (void)getLeaderWithIndex:(int)index
{
	if (_leaderType.selectedSegmentIndex == 0)
	{
		NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getMostEnemyLeaderData.php?arg1=%d", index]];
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
													  int enemies1 = [[object valueForKey:@"enemies"] intValue];
													  int i = 0;
													  for (i = 0; i < [_enemyLeadersData count]; i++)
													  {
														  NSDictionary *data2 = [_enemyLeadersData objectAtIndex:i];
														  int enemies2 = [[data2 valueForKey:@"enemies"] intValue];
														  if (enemies1 > enemies2)
														  {
															  [_enemyLeadersData insertObject:object atIndex:i];
															  break;
														  }
													  }
													  if ([_enemyLeadersData count] == 0 || i >= [_enemyLeadersData count])
													  {
														  [_enemyLeadersData addObject:object];
													  }
													  //[self sortFriendData];
													  dispatch_async(dispatch_get_main_queue(), ^{
														  [_enemyLeaders reloadData];
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
	else if (_leaderType.selectedSegmentIndex == 1)
	{
		NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getMostHateLeaderData.php?arg1=%d", index]];
		NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
		NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
										  {
											  if (error != nil)
											  {
												  NSLog(@"Error: %@", [error localizedDescription]);
											  }
											  else
											  {
												  NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
												  NSLog(@"%@", text);
												  NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
												  if (object != nil)
												  {
													  int hates1 = [[object valueForKey:@"likes"] intValue];
													  int i = 0;
													  for (i = 0; i < [_hateLeadersData count]; i++)
													  {
														  NSDictionary *data2 = [_hateLeadersData objectAtIndex:i];
														  int hates2 = [[data2 valueForKey:@"likes"] intValue];
														  if (hates1 > hates2)
														  {
															  [_hateLeadersData insertObject:object atIndex:i];
															  break;
														  }
													  }
													  if ([_hateLeadersData count] == 0 || i >= [_hateLeadersData count])
													  {
														  [_hateLeadersData addObject:object];
													  }
													  //[self sortFriendData];
													  dispatch_async(dispatch_get_main_queue(), ^{
														  [_hateLeaders reloadData];
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
}

- (void)sortLeaderData
{
	if (_leaderType.selectedSegmentIndex == 0)
	{
	for (int i = 0; i < [_enemyLeadersData count]; i++)
	{
		NSDictionary *data1 = [_enemyLeadersData objectAtIndex:i];
		int enemies1 = [[data1 valueForKey:@"enemies"] intValue];
		int greatest = i;
		for (int j = i + 1; j < [_enemyLeadersData count]; j++)
		{
			NSDictionary *data2 = [_enemyLeadersData objectAtIndex:j];
			int enemies2 = [[data2 valueForKey:@"enemies"] intValue];
			if (enemies1 < enemies2)
			{
				greatest = j;
				enemies1 = enemies2;
			}
		}
		[_enemyLeadersData exchangeObjectAtIndex:i withObjectAtIndex:greatest];
	}
	}
	else if (_leaderType.selectedSegmentIndex == 1)
	{
		for (int i = 0; i < [_hateLeadersData count]; i++)
		{
			NSDictionary *data1 = [_hateLeadersData objectAtIndex:i];
			int hates1 = [[data1 valueForKey:@"likes"] intValue];
			int greatest = i;
			for (int j = i + 1; j < [_enemyLeadersData count]; j++)
			{
				NSDictionary *data2 = [_enemyLeadersData objectAtIndex:j];
				int hates2 = [[data2 valueForKey:@"likes"] intValue];
				if (hates1 < hates2)
				{
					greatest = j;
					hates1 = hates2;
				}
			}
			[_enemyLeadersData exchangeObjectAtIndex:i withObjectAtIndex:greatest];
		}
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([tableView isEqual:_enemyLeaders])
	{
		if (_numUsers > _enemyLeadersLoaded && _enemyLeadersLoaded != 0)
		{
			return [_enemyLeadersData count] + 1;
		}
		return [_enemyLeadersData count];
	}
	else if ([tableView isEqual:_hateLeaders])
	{
		if (_numUsers > _hateLeadersLoaded && _hateLeadersLoaded != 0)
		{
			return [_hateLeadersData count] + 1;
		}
		return [_hateLeadersData count];
	}
	return 0;
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
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
	}
	if ([tableView isEqual:_enemyLeaders])
	{
		if (_numUsers > _enemyLeadersLoaded && indexPath.row == [_enemyLeadersData count])
		{
			cell.textLabel.text = @"Scroll down to load more users";
			cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
		}
		else
		{
			NSDictionary *data = [_enemyLeadersData objectAtIndex:indexPath.row];
			cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", (int)indexPath.row + 1, [data valueForKey:@"username"]];
			cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
			cell.textLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
			cell.textLabel.tag = [[data valueForKey:@"id"] intValue];
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ enemies", [data valueForKey:@"enemies"]];
			cell.detailTextLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
			cell.detailTextLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
			cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
			cell.detailTextLabel.numberOfLines = 0;
			cell.detailTextLabel.backgroundColor = [UIColor clearColor];
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
		}
	}
	else if ([tableView isEqual:_hateLeaders])
	{
		if (_numUsers > _hateLeadersLoaded && indexPath.row == [_hateLeadersData count])
		{
			cell.textLabel.text = @"Scroll down to load more users";
			cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
		}
		else
		{
			NSDictionary *data = [_hateLeadersData objectAtIndex:indexPath.row];
			cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", (int)indexPath.row + 1, [data valueForKey:@"username"]];
			cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
			cell.textLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
			cell.textLabel.tag = [[data valueForKey:@"id"] intValue];
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ hates", [data valueForKey:@"likes"]];
			cell.detailTextLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
			cell.detailTextLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
			cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
			cell.detailTextLabel.numberOfLines = 0;
			cell.detailTextLabel.backgroundColor = [UIColor clearColor];
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
		}
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
	return 70;
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

- (void)getUserCountWithCompletionHandler:(void (^)(BOOL completed))completionHandler
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getNumUsers.php"]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  _numUsers = [text intValue];
									  dispatch_async(dispatch_get_main_queue(), ^{
										  completionHandler(YES);
									  });
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
			if (_leaderType.selectedSegmentIndex == 0)
			{
				if (_enemyLeadersLoaded < _numUsers)
				{
					activityIndicator.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
					[self.view addSubview:activityIndicator];
					[activityIndicator startAnimating];
					_loading = YES;
					[self getUserCountWithCompletionHandler:^(BOOL completed){
						[self loadLeaders:5];
					}];
				}
			}
			else if (_leaderType.selectedSegmentIndex == 1)
			{
				if (_hateLeadersLoaded < _numUsers)
				{
					activityIndicator.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
					[self.view addSubview:activityIndicator];
					[activityIndicator startAnimating];
					_loading = YES;
					[self getUserCountWithCompletionHandler:^(BOOL completed){
						[self loadLeaders:5];
					}];
				}
			}
		}
	}
}

@end
