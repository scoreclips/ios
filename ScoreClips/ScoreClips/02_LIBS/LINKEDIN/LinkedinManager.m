//
//  ShareLinkedinHelper.m
//  OAuthStarterKit
//
//  Created by Pedro Milanez on 27/09/12.
//  Copyright (c) 2012 self. All rights reserved.
//


#import "LinkedinManager.h"
#import "LI_OAMutableURLRequest.h"
#import "XMLReader.h"

@implementation LinkedinManager
{
    NSInteger _requestStep; // 0: general info, 1: picture original
    NSMutableDictionary *_dataDic;
}
@synthesize oAuthLoginView = _oAuthLoginView;

+ (LinkedinManager *)sharedInstance
{
    static dispatch_once_t once;
    static LinkedinManager *instance;
    dispatch_once(&once, ^ { instance = [[LinkedinManager alloc] init]; });
    return instance;
}

-(void)presentWithVC:(UIViewController *)viewController andDelegate:(id<LinkedinManagerDelegate>)delegate
{
    self.delegate = delegate;
    _oAuthLoginView = [[OAuthLoginView alloc] initWithNibName:nil bundle:nil apiKey:kLinkedinApiKey secretKey:kLinkedinSecretKey];
    
    // register to be told when the login is finished
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginViewDidFinish:)
                                                 name:@"loginViewDidFinish"
                                               object:_oAuthLoginView];
    
    [viewController presentViewController:_oAuthLoginView animated:YES completion:^{}];
}

#pragma mark - Private Methods

-(void) loginViewDidFinish:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	// Login failed
	if (![_oAuthLoginView.accessToken isValid]) {
		return;
	}
	
    [self shareContentWithData];
}

#pragma mark - OADataFetcher return Methods
- (void) shareContentWithData
{
    _requestStep = 0;
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~:(first-name,last-name,picture-url::(original),headline,date-of-birth,educations,summary,positions,email-address,location:(name),main-address)"];
    LI_OAMutableURLRequest *request =
    [[LI_OAMutableURLRequest alloc] initWithURL:url
                                    consumer:_oAuthLoginView.consumer
                                       token:_oAuthLoginView.accessToken
                                    callback:nil
                           signatureProvider:nil];
    //[[LI_OAMutableURLRequest alloc] initWithURL:url consumer:_oAuthLoginView.consumer token:_oAuthLoginView.accessToken realm:nil signatureProvider:nil];
    
    
    [request setValue:@"text/xml;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];

	[request setHTTPMethod:@"GET"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(postUpdateApiCallResult:didFinish:)
                  didFailSelector:@selector(postUpdateApiCallResult:didFail:)];
}
- (void) getPicture
{
    _requestStep = 1;
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/picture-urls::(original)"];
    LI_OAMutableURLRequest *request =
    [[LI_OAMutableURLRequest alloc] initWithURL:url
                                    consumer:_oAuthLoginView.consumer
                                       token:_oAuthLoginView.accessToken
                                    callback:nil
                           signatureProvider:nil];
    
    //[[LI_OAMutableURLRequest alloc] initWithURL:url consumer:_oAuthLoginView.consumer token:_oAuthLoginView.accessToken realm:nil signatureProvider:nil];
    
    [request setValue:@"text/xml;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
	[request setHTTPMethod:@"GET"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(postUpdateApiCallResult:didFinish:)
                  didFailSelector:@selector(postUpdateApiCallResult:didFail:)];
}

- (void)postUpdateApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    // parse data
    NSDictionary *dataDic = [XMLReader dictionaryForXMLData:data error:nil];
    [self parseData:dataDic];
    if (_requestStep == 0) {
        [self getPicture];
    }
    
}

- (void)postUpdateApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}

-(void)parseData:(NSDictionary*)dataDic
{
    if(_requestStep == 0)
    {
        _dataDic = [NSMutableDictionary dictionaryWithDictionary:dataDic];
        NSDictionary *personDic = [dataDic objectForKey:@"person"];
        self.fName = [personDic objectForKey:@"first-name"];
        self.fName = self.fName ? self.fName : @"";
        self.lName = [personDic objectForKey:@"last-name"];
        self.lName = self.lName ? self.lName : @"";
        self.pictureURL = [personDic objectForKey:@"picture-url"];
        self.pictureURL = self.pictureURL ? self.pictureURL : @"";
        self.email = [personDic objectForKey:@"email-address"];
        self.email = self.email ? self.email : @"";
        self.gender = @"male"; // hard code for now, because cannot get gender info from linked in
        self.about = [personDic objectForKey:@"summary"];
        self.about = self.about ? self.about : @"";
        self.birthday = nil; // hard code for now, because cannot get this info from linked in
        self.initiatedFrom = @""; // hard code for now, because cannot get this info from linked in
        self.location = [[personDic objectForKey:@"location"] objectForKey:@"name"]; // hard code for now, because cannot get gender info from linked in
        self.location = self.location ? self.location : @"";
        
        if([[[dataDic objectForKey:@"educations"] objectForKey:@"@total"] integerValue] == 0) {
            self.education = [[NSArray alloc] init];
        }
        else {
            id eduDic = [[personDic objectForKey:@"educations"] objectForKey:@"education"];
            if ([eduDic isKindOfClass:[NSDictionary class]]) {
                self.education = [NSArray arrayWithObject:eduDic];
            }
            else {
                self.education = [NSArray arrayWithArray:eduDic];
            }
        }
        
        if([[[dataDic objectForKey:@"positions"] objectForKey:@"@total"] integerValue] == 0) {
            self.work = [[NSArray alloc] init];
        }
        else {
            id workDic = [[personDic objectForKey:@"positions"] objectForKey:@"position"];
            if ([workDic isKindOfClass:[NSDictionary class]]) {
                self.work = [NSArray arrayWithObject:workDic];
            }
            else {
                self.work = [NSArray arrayWithArray:workDic];
            }
        }
        
        self.relationshipStatus = @""; // hard code for now, because cannot get this info from linked in
    }
    else if (_requestStep == 1)
    {
        if([[[dataDic objectForKey:@"picture-urls"] objectForKey:@"@total"] integerValue] == 0)
        {
            self.pictureURL = @"";
        }
        else {
            id pictureDic = [[dataDic objectForKey:@"picture-urls"] objectForKey:@"picture-url"];
            if ([pictureDic isKindOfClass:[NSDictionary class]]) {
                self.pictureURL = [pictureDic objectForKey:@"text"];
            }
            else {
                self.pictureURL = [[pictureDic objectAtIndex:0] objectForKey:@"text"];
            }
        }
        [_dataDic setValue:self.pictureURL forKey:@"picture-url"];
        [self.delegate linkedInManager:self didFinishRequestData:_dataDic];
    }
}
@end
