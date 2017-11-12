//
//  YLPSearchTableViewController.m
//  YelpAPI
//
//  Created by David Chen on 3/31/16.
//  Copyright © 2016 Yelp. All rights reserved.
//

#import "YLPSearchTableViewController.h"
#import "YLPDetailBusinessViewController.h"
//#import "YLPAppDelegate.h"

#import "YLPClient+Search.h"
#import "YLPSortType.h"
#import "YLPSearch.h"
#import "YLPBusiness.h"
#import "YLPCoordinate.h"
#import "YLPLocation.h"
#import "BBQApp-Swift.h"

@interface YLPSearchTableViewController ()

@property (nonatomic) YLPSearch *search;

@property (nonatomic) YLPCoordinate *coordinates;

@end

@implementation YLPSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AppDelegate sharedClient] searchWithLocation:@"Columbia, MO" term:nil limit:50 offset:0 categoryFilter:@[@"bbq"] sort:YLPSortTypeDistance completionHandler:^
     (YLPSearch *search, NSError* error) {
         self.search = search;
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
         });
     }];

//    self.coordinates.latitude = 38.9517;
//    self.coordinates.longitude = -92.3341;
    
//    [[AppDelegate sharedClient] searchWithCoordinate: self.coordinates  term:nil limit:50 offset:0 sort:YLPSortTypeDistance completionHandler:^
//     (YLPSearch *search, NSError* error) {
//         self.search = search;
//         dispatch_async(dispatch_get_main_queue(), ^{
//             [self.tableView reloadData];
//         });
//     }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.search.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    if (indexPath.item > [self.search.businesses count]) {
        cell.textLabel.text = @"";
    }
    else {
        cell.textLabel.text = self.search.businesses[indexPath.item].name;
        //NSLog(@"%@", self.search.businesses[indexPath.item].location.coordinate);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    YLPDetailBusinessViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YLPDetailBusinessViewController"];
    vc.business = self.search.businesses[indexPath.item];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
