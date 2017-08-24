//
//  SearchViewController.m
//  Roastr
//
//  Created by Ryan Wiener on 5/9/16.
//  Copyright © 2016 Ryan Wiener. All rights reserved.
//

#import "SearchViewController.h"
//#import "AppDelegate.h"

@implementation SearchViewController
{
	NSURLSession *session;
}

- (void)viewDidLoad
{
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:topView];
	//self.view.backgroundColor = [UIColor whiteColor];
	_similarUsers = [[NSArray alloc] init];
	session = [NSURLSession sharedSession];
	_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
	[_searchBar setPlaceholder:@"Search for other users"];
	_searchBar.delegate = self;
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 109) style:UITableViewStylePlain];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_searchBar];
	[self.view addSubview:_tableView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
 NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/getLikeUsers.php?arg1=%@", searchText]];
 NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
 NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
								   {
									   if (error != nil)
									   {
										   NSLog(@"%@", [error localizedDescription]);
									   }
									   else
									   {
										   NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
										   if (error != nil)
										   {
											   NSLog(@"%@", [error localizedDescription]);
										   }
										   else
										   {
											   //NSLog(@"%@", dictionary);
											   _similarUsers = dictionary.allKeys;
											   //NSLog(@"%@", _similarUsers);
											   dispatch_async(dispatch_get_main_queue(), ^{
												   [_tableView reloadData];
											   });
										   }
									   }
								   }];
 [dataTask resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_similarUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *simpleTableIdentifier = @"SimpleTableItem";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
	}
	cell.textLabel.text = [_similarUsers objectAtIndex:indexPath.row];
	cell.textLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
	cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
	cell.contentView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	return cell;
}

- (void)getUserID:(NSString*)username completionHandler:(void (^)(int userID))completionHandler
{
	NSString *urlString = [[NSString alloc] initWithFormat:@"https://roastr2.herokuapp.com/getIDForUser.php?arg1='%@'", username];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request
											completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
								  {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  if (![@"user doesn't exists" isEqualToString:text])
									  {
										  dispatch_async(dispatch_get_main_queue(), ^{
											  completionHandler([text intValue]);
										  });
									  }
								  }];
	[task resume];
}

- (IBAction)closeProfile:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSString *user = [_similarUsers objectAtIndex:indexPath.row];
	[self getUserID:user completionHandler:^(int userID){
		ProfileViewController *profilePage = [[ProfileViewController alloc] initWithUserID:userID];
		//profilePage.username.text = user;
		[self presentViewController:profilePage animated:YES completion:nil];
	}];
}

@end
