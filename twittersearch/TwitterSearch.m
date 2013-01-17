//
//  TwitterSearch.m
//  twittersearch
//
//  Created by crkmnstr on 1/16/13.
//  Copyright (c) 2013 evilBlue. All rights reserved.
//

#import "TwitterSearch.h"
#import "AFJSONRequestOperation.h"
#import "UIImageView+AFNetworking.h"

@implementation TwitterSearch

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self)
    {
        _avatarCache = [[NSCache alloc] init];
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setParameterEncoding:AFJSONParameterEncoding];
    }
	
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - TwitterSearch

- (UIImage*)avatarImageForIndexPath:(NSIndexPath*)indexPath
{
    if([_avatarCache objectForKey:[[_searchTweets objectAtIndex:indexPath.row] objectForKey:@"profile_image_url"]])
        return [[_avatarCache objectForKey:[[_searchTweets objectAtIndex:indexPath.row] objectForKey:@"profile_image_url"]] image];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    NSURL *avatarURL = [NSURL URLWithString:[[_searchTweets objectAtIndex:indexPath.row] objectForKey:@"profile_image_url"]];
    
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:avatarURL]
                     placeholderImage:[UIImage imageNamed:@"placeholder-avatar"]
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  [[_avatarCache objectForKey:[[_searchTweets objectAtIndex:indexPath.row] objectForKey:@"profile_image_url"]] setImage:image];
                                  
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"avatarLoaded" object:indexPath];
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  NSLog(@"avatar.image setImageWithURLRequest %@",error);
                              }];
    
    [_avatarCache setObject:imageView forKey:[[_searchTweets objectAtIndex:indexPath.row] objectForKey:@"profile_image_url"]];
    
    return [[_avatarCache objectForKey:[[_searchTweets objectAtIndex:indexPath.row] objectForKey:@"profile_image_url"]] image];
}

- (void)moreResultsOnSuccess:(void (^)())sblock
                   onFailure:(void (^)(NSError	*error))fblock
{
    [self getPath:[NSString stringWithFormat:@"search.json%@",[_jsonDictionary objectForKey:@"next_page"]]
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id json) {
              _jsonDictionary = [NSDictionary dictionaryWithDictionary:json];
              
              [_searchTweets addObjectsFromArray:[_jsonDictionary objectForKey:@"results"]];
              
              sblock();
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              fblock(error);
          }];
}

- (void)searchWithTerms:(NSString*)terms
              onSuccess:(void (^)())sblock
              onFailure:(void (^)(NSError	*error))fblock
{
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:terms,@"q",
                                     @"1",@"page",
                                     @"10",@"rpp",
                                     @"recent",@"result_type",nil];
    
    [self getPath:@"search.json"
       parameters:paramDictionary
          success:^(AFHTTPRequestOperation *operation, id json) {
              [_avatarCache removeAllObjects];
              
              _jsonDictionary = [NSDictionary dictionaryWithDictionary:json];
              
              _searchTweets = [NSMutableArray arrayWithArray:[_jsonDictionary objectForKey:@"results"]];
              
              sblock();
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              fblock(error);
          }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Singleton

+ (TwitterSearch*)sharedInstance
{
    static TwitterSearch *sharedInstance = nil;
	
	if(sharedInstance)
		return sharedInstance;
	
    static dispatch_once_t pred;		// Lock
	
    dispatch_once(&pred,
				  ^{					// This code is called at most once per app
					  sharedInstance = [[TwitterSearch alloc] initWithBaseURL:[NSURL URLWithString:@"http://search.twitter.com/"]];
				  });
	
    return sharedInstance;
}

@end
