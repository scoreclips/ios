//
//  ShareLinkedinHelper.h
//  OAuthStarterKit
//
//  Created by Pedro Milanez on 27/09/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthLoginView.h"
//#import "JSONKit.h"
#import "OAConsumer.h"
#import "LI_OAMutableURLRequest.h"
#import "OADataFetcher.h"
//#import "OATokenManager.h"

#define kLinkedinApiKey @"ytr36i0xyvce"
#define kLinkedinSecretKey @"2v7PcWljSe3vDkiY"

@class LinkedinManager;
@protocol LinkedinManagerDelegate <NSObject>

@optional
-(void)linkedInManager:(LinkedinManager*)manager didFinishRequestData:(NSDictionary*)dataDic;

@end

@interface LinkedinManager : NSObject
@property (nonatomic, retain) NSString *fName;
@property (nonatomic, retain) NSString *lName;
@property (nonatomic, retain) NSString *pictureURL;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSString *about;
@property (nonatomic, strong) NSDate   *birthday;
@property (nonatomic, retain) NSString *initiatedFrom;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSArray *education;
@property (nonatomic, retain) NSArray *work;
@property (nonatomic, retain) NSString *relationshipStatus;

@property (strong, nonatomic) id<LinkedinManagerDelegate> delegate;
@property (nonatomic, strong) OAuthLoginView *oAuthLoginView;

+ (LinkedinManager *)sharedInstance;
-(void)presentWithVC:(UIViewController *)viewController andDelegate:(id<LinkedinManagerDelegate>)delegate;

@end
