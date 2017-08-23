//
//  SearchViewController.h
//  Roastr
//
//  Created by Ryan Wiener on 5/9/16.
//  Copyright © 2016 Ryan Wiener. All rights reserved.
//

#ifndef SearchViewController_h
#define SearchViewController_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ProfileViewController.h"

@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) NSArray *similarUsers;
@property (nonatomic) UITableView *tableView;
//- (void)loadSimilarUserswithText:(NSString*)searchText;

@end

#endif
