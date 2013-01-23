//
//  ResultsVC.m
//  twittersearch
//
//  Created by crkmnstr on 1/17/13.
//  Copyright (c) 2013 evilBlue. All rights reserved.
//

#import "ResultsVC.h"
#import "TwitterSearch.h"
#import "ZAActivityBar.h"
#import "UIImageView+AFNetworking.h"
#import "PrettyCustomViewTableViewCell.h"

@interface ResultsVC ()

- (void)reloadData:(NSNotification *)notification;

@end

@implementation ResultsVC

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"avatarLoaded" object:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - ResultsVC

- (void)reloadData:(NSNotification *)notification
{
    if([self.tableView.indexPathsForVisibleRows containsObject:(NSIndexPath*)notification.object])
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:notification.object] withRowAnimation:UITableViewRowAnimationFade];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[TwitterSearch sharedInstance] searchTweets] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PrettyTableViewCell *prettyCell = [tableView dequeueReusableCellWithIdentifier:@"resultCell"];
	
	if(!prettyCell)
	{
		prettyCell = [[PrettyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"resultCell"];
	}
	
	[prettyCell prepareForTableView:tableView indexPath:indexPath];
	
    prettyCell.textLabel.numberOfLines = 0;
    prettyCell.textLabel.font = [UIFont systemFontOfSize:9];
    prettyCell.detailTextLabel.font = [UIFont systemFontOfSize:9];
	prettyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    prettyCell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    prettyCell.imageView.image = [[TwitterSearch sharedInstance] avatarImageForIndexPath:indexPath];
    prettyCell.textLabel.text = [[[[TwitterSearch sharedInstance] searchTweets] objectAtIndex:indexPath.row] objectForKey:@"text"];
    prettyCell.detailTextLabel.text = [NSString stringWithFormat:@"@%@",[[[[TwitterSearch sharedInstance] searchTweets] objectAtIndex:indexPath.row] objectForKey:@"from_user"]];
    
    if([[[TwitterSearch sharedInstance] searchTweets] count] == indexPath.row + 1)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            _isReloading = FALSE;
        });
	
    return prettyCell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(![ZAActivityBar isVisible] && !_isReloading)
    {
        _isReloading = TRUE;
        
        [ZAActivityBar showWithStatus:@"Fetching More Results" forAction:@"fetch"];
        
        [[TwitterSearch sharedInstance] moreResultsOnSuccess:^{
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [ZAActivityBar showSuccessWithStatus:@"Got More Results!" forAction:@"fetch"];
                
                                                            [tableView reloadData];
                                                        });
                                                   }
                                                   onFailure:^(NSError *error) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [ZAActivityBar showErrorWithStatus:@"Fetch Failed" forAction:@"fetch"];
                                                       });
                                                   }];
    }
    
    return nil;
}

@end
