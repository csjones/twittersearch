//
//  TwitterSearch.h
//  twittersearch
//
//  Created by crkmnstr on 1/16/13.
//  Copyright (c) 2013 evilBlue. All rights reserved.
//

#import "AFHTTPClient.h"

@interface TwitterSearch : AFHTTPClient
{
    NSCache         *_avatarCache;
    
    NSDictionary    *_jsonDictionary;
}

@property   (nonatomic,readonly)  NSMutableArray    *searchTweets;

+ (id)sharedInstance;

- (UIImage*)avatarImageForIndexPath:(NSIndexPath*)indexPath;

- (void)moreResultsOnSuccess:(void (^)())sblock
                   onFailure:(void (^)(NSError	*error))fblock;

- (void)searchWithTerms:(NSString*)terms
              onSuccess:(void (^)())sblock
              onFailure:(void (^)(NSError	*error))fblock;

@end
