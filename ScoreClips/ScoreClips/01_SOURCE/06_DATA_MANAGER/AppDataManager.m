//
//  AppDataManager.m
//  VISIKARD
//
//  Created by Trong Vu on 2/21/13.
//
//

#import "AppDataManager.h"
#import "AppViewController.h"

@implementation AppDataManager

- (id)init {
    self = [super init];
    if (self) {
         _APIRequester = [APIRequester new];
        //rootData = [[KardsTableData alloc] init];
    }
    return self;
}

#pragma mark - Get data
- (NSMutableArray*) getDataType:(ENUM_API_REQUEST_TYPE)dataType forceUpdate:(BOOL)isForceUpdate  {
    
    // Trongv - update and use local database later. Now we store in mem by KardsDataManager
    switch (dataType) {
        case ENUM_API_REQUEST_TYPE_GET_SCORE_CLIPS:
            if (isForceUpdate) {
                // Request API to update data on APP
                [self requestData:ENUM_API_REQUEST_TYPE_GET_SCORE_CLIPS];
            } else {
                // Request API to update data on APP
                [self requestData:ENUM_API_REQUEST_TYPE_GET_SCORE_CLIPS];
            }
            break;
        case ENUM_API_REQUEST_TYPE_GET_SCORE_DATES:
            if (isForceUpdate) {
                // Request API to update data on APP
                [self requestData:ENUM_API_REQUEST_TYPE_GET_SCORE_DATES];
            } else {
                // Request API to update data on APP
                [self requestData:ENUM_API_REQUEST_TYPE_GET_SCORE_DATES];
            }
            break;
        default:
            break;
    }
    return  nil;
}



#pragma mark - APIRequester
- (void)requestData:(ENUM_API_REQUEST_TYPE) type {
    NSString *strURL = @"";
    switch (type) {
        case ENUM_API_REQUEST_TYPE_GET_SCORE_CLIPS:
        {
            [[AppViewController Shared] isRequesting:YES andRequestType:type andFrame:FRAME(0, HEIGHT_HOME_VIEW_CONTROLLER_TITLE, [SupportFunction getDeviceWidth], [SupportFunction getDeviceHeight] - HEIGHT_HOME_VIEW_CONTROLLER_TITLE)];
            
            NSString *date = @"2013-04-12";
            strURL = [NSString stringWithFormat:@"%@/%@", STRING_REQUEST_URL_GET_SCORE_CLIPS_ON_DAY,date];
            [_APIRequester requestWithType:type andRootURL:strURL andPostMethodKind:NO andParams:nil andDelegate:self];
            break;
        }
        case ENUM_API_REQUEST_TYPE_GET_SCORE_DATES:
        {
            [[AppViewController Shared] isRequesting:YES andRequestType:type andFrame:FRAME(0, HEIGHT_HOME_VIEW_CONTROLLER_TITLE, [SupportFunction getDeviceWidth], [SupportFunction getDeviceHeight] - HEIGHT_HOME_VIEW_CONTROLLER_TITLE)];
        
            strURL = [NSString stringWithFormat:@"%@", STRING_REQUEST_URL_GET_SCORE_DATES];
            [_APIRequester requestWithType:type andRootURL:strURL andPostMethodKind:NO andParams:nil andDelegate:self];
            break;
        }
        default:
            break;
    }
}


#pragma mark - APIRequesterProtocol

- (void)requestFinished:(ASIHTTPRequest *)request andType:(ENUM_API_REQUEST_TYPE)type {
    //VKLog(@"requestFinished: %@", [request responseString]);
    
    [[AppViewController Shared] isRequesting:NO andRequestType:type andFrame:CGRectZero];
    
    NSError *error;
    SBJSON *sbJSON = [SBJSON new];
    
    if (![sbJSON objectWithString:[request responseString] error:&error] || request.responseStatusCode != 200 || !request) {
        //ALERT(STRING_ALERT_CONNECTION_ERROR_TITLE, STRING_ALERT_SERVER_ERROR);
        [self.delegate requestFinished:request andType:type];
        return;
    }
    
    //NSMutableArray *jsonData = [sbJSON objectWithString:[request responseString] error:&error];

    if (type == ENUM_API_REQUEST_TYPE_GET_SCORE_CLIPS) {
        //NSMutableArray *jsonData = [sbJSON objectWithString:[request responseString] error:&error];
    }
    
    [self.delegate requestFinished:request andType:type];
}

- (void)requestFailed:(ASIHTTPRequest *)request andType:(ENUM_API_REQUEST_TYPE)type {
    //VKLog(@" requestFailed %@ ", request.responseString);
    
    [[AppViewController Shared] isRequesting:NO andRequestType:ENUM_API_REQUEST_TYPE_INVALID andFrame:CGRectZero];
    
    if (![ASIHTTPRequest isNetworkReachable]) {
        //ALERT(STRING_ALERT_CONNECTION_ERROR_TITLE, STRING_ALERT_CONNECTION_ERROR);
    }
    
    [self.delegate requestFailed:request andType:type];
}


static AppDataManager *_AppDataManagerShared;
+ (AppDataManager *)AppDataManagerShared
{
    if (!_AppDataManagerShared){
        _AppDataManagerShared = [[AppDataManager alloc] init];
    }
    return _AppDataManagerShared;
}

@end
