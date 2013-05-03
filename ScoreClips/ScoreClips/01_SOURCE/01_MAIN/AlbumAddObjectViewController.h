//
//  AlbumAddObjectViewController.h
//  VISIKARD
//
//  Created by Vinh Huynh on 3/4/13.
//
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import "OAToken.h"
#import "FBFunLoginDialog.h"

typedef enum {
    enumPostingType_Full = 0,
    enumPostingType_AddVideo,
    enumPostingType_Audio,
    enumPostingType_AddPhoto,
    enumPostingType_Status,
    enumPostingType_AddLocation,
    enumPostingType_AddPhoto_At_Back_Kard,
    enumPostingType_Status_At_Back_Kard,
    enumPostingType_AddVideo_At_Back_Kard
    
}enumPostingType;

#define kPlaceholderPhoto                   @"Add a caption to your photo..."
#define kPlaceholderVideo                   @"Add a caption to your video..."
#define kPlaceholderLocation                @"What's up at"
//#define kPlaceholderStatus                  @"What are you up to?"
#define kPlaceholderStatus                  @"Bình luận của bạn?"

@protocol AlbumAddObjectViewControllerDelegate<NSObject>
@optional
- (void)donePostingCallBackWithData:(NSDictionary *)data;
- (void)cancelPostingCallBack;

@end

@interface AlbumAddObjectViewController : UIViewController <ASIHTTPRequestDelegate,SA_OAuthTwitterControllerDelegate,ASIHTTPRequestDelegate, FBFunLoginDialogDelegate>
{
    SA_OAuthTwitterEngine				*_engine;
    FBFunLoginDialog                    *_FBLoginDialogVC;
    UIView                                          *_requestingView;
    UIActivityIndicatorView                         *_requestingIndicator;
    
    IBOutlet UIImageView *locationBtnBgImg;
    IBOutlet UIImageView *twitterBtnBgImg;
    IBOutlet UIImageView *facebookBtnBgImg;
    
    IBOutlet UIView *showProgressView;
    IBOutlet UIProgressView *videoCompressProgressBar;
    IBOutlet UILabel *progressLable;
    
    IBOutlet UIButton *doneBtn;
}

@property (weak, nonatomic) IBOutlet UIView *thumbView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImage;
@property (weak, nonatomic) IBOutlet UIView *textPostView;
@property (weak, nonatomic) IBOutlet UITextField *statusField;
@property (weak, nonatomic) IBOutlet UITextView *statusTextView;
@property (strong, nonatomic) IBOutlet UIView *menuTagView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *peopleButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (assign, nonatomic) id<AlbumAddObjectViewControllerDelegate> delegate;
@property (assign, nonatomic) enumPostingType postingType;
@property (assign, nonatomic) NSInteger albumID;
@property (assign, nonatomic) NSInteger kardID;
@property (assign, nonatomic) NSInteger videoOrientation;
@property (strong, nonatomic) NSString  *profileID;
@property (weak, nonatomic) IBOutlet UILabel *lbLocation;
@property (weak, nonatomic) IBOutlet UILabel *lbCaption;

//@property (unsafe_unretained, nonatomic) Annotation *annotation;
//@property (strong, nonatomic) Annotation *annotation;
@property (strong, nonatomic) NSData *mediaData;
@property (strong, nonatomic) UIImage *thumbnailImage;
@property (strong, nonatomic) IBOutlet UILabel    *lbTitle;

@property (nonatomic, retain) SA_OAuthTwitterEngine				*_engine;
@property (strong, nonatomic) NSString *facebookAccessToken;
@property (nonatomic) BOOL isTwitter;
@property (nonatomic) BOOL isFacebook;
@property (nonatomic) BOOL isFinishPostTwitter;
@property (nonatomic) BOOL isFinishPostFacebook;
@property (strong,nonatomic)    NSString    *strCaption;


- (IBAction)locationButtonPressed:(id)sender;
//- (IBAction)peopleButtonPressed:(id)sender;
- (IBAction)twitterButtonPressed:(id)sender;
- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)donePostingPressed:(id)sender;
- (IBAction)cancelPostingPressed:(id)sender;


@end
