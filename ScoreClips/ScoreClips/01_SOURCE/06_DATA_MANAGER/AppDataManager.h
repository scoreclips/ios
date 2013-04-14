//
//  AppDataManager.h
//  VISIKARD
//
//  Created by Trong Vu on 2/21/13.
//
//

#import <Foundation/Foundation.h>
#import "APIRequester.h"

typedef enum {
    enumAppDataType_Invalid,
    enumAppDataType_ScoreClips,
    enumAppDataType_ScoreDates,
    enumAppDataType_Num
}enumAppDataType;

@protocol AppDataManagerDelegate <NSObject>
@optional
- (void)requestFinished:(ASIHTTPRequest *)request andType:(ENUM_API_REQUEST_TYPE)type;
- (void)requestFailed:(ASIHTTPRequest *)request andType:(ENUM_API_REQUEST_TYPE)type;
@end


@interface AppDataManager : NSObject <APIRequesterProtocol> {
     APIRequester       *_APIRequester;
}

@property (nonatomic, assign) id<AppDataManagerDelegate>  delegate;

- (NSMutableArray*) getDataType:(ENUM_API_REQUEST_TYPE)dataType forceUpdate:(BOOL)isForceUpdate;

+ (AppDataManager *)AppDataManagerShared;


@end
