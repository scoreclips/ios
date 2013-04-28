//
//  AlbumAddObjectViewController.m
//  VISIKARD
//
//  Created by Vinh Huynh on 3/4/13.
//
//

#import "AlbumAddObjectViewController.h"
#import "Define.h"
#import "JSON.h"
#import "APIRequester.h"
#import "AppViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Facebook.h"
#import "FBLoginManager.h"
#import "FBFunLoginManager.h"

// VK
//#define kOAuthConsumerKey                              @"m9aTWyCP2eALmqFjXbSVA"
//#define kOAuthConsumerSecret                           @"E21RJ7jzprrSrtl7Ep3AZrzZPctJuulfNGe4Pk2w0g"

// aigo
#define kOAuthConsumerKey                              @"sDYHa0PzvYE8kpQvLTSsiA"
#define kOAuthConsumerSecret                           @"nNRiiVKNwnCxqV4LeOxOVZKXLsMjgCMMSFmPuNGx8"

// Get here: http://dev.twitpic.com/apps/
#define TWITPIC_API_KEY @"94c0e7c3c68b8bfa0d868a5083d34d65"


@interface AlbumAddObjectViewController()<APIRequesterProtocol, UITextViewDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    APIRequester    *_requester;
    NSMutableString *_friendsTag;
    NSMutableArray  *_friendKardList;
    
    NSInteger   makingLoginWith;   // 1 for Twitter  ;  2 for Facebook
}


@end

@implementation AlbumAddObjectViewController
@synthesize lbTitle,_engine;
@synthesize facebookAccessToken;
@synthesize isTwitter;
@synthesize isFacebook;
@synthesize profileID;
@synthesize lbCaption;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_statusTextView becomeFirstResponder];
    _statusTextView.inputAccessoryView = _menuTagView;
    
    _statusTextView.returnKeyType = UIReturnKeyDone;//Qasim:26/04/2013
    
    [self loadInterFaceWithType];
    _friendsTag = [[NSMutableString alloc] init];
    _requester = [[APIRequester alloc] init];
    // Do any additional setup after loading the view from its nib.dd
    
    //Qasim: 13/03/2013
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FBLoginStatus) name:STRING_LOGIN_ON_FB object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TwitterLoginStatus) name:STRING_LOGIN_ON_TWITTER object:nil];
    //self.lbTitle.font = [UIFont fontWithName:FONT_GOTHAM_MEDIUM size:17];
    
    self.isFinishPostTwitter = NO;
    self.isFinishPostFacebook = NO;
    
    //self.lbLocation.font = [UIFont fontWithName:FONT_GOTHAM_BOOK size:14];
    
//    if(self.annotation != nil) {
////        self.locationButton.selected = YES;
//        locationBtnBgImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"upload_location_active" ofType:@"png"]];
//    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLbTitle:nil];
    [self setThumbView:nil];
    [self setThumbImage:nil];
    [self setTextPostView:nil];
    [self setStatusField:nil];
    [self setStatusTextView:nil];
    [self setMenuTagView:nil];
    [self setLocationButton:nil];
    [self setPeopleButton:nil];
    [self setTwitterButton:nil];
    [self setFacebookButton:nil];
    [self setProfileID:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setLbCaption:nil];
    [self setStrCaption:nil];
    [super viewDidUnload];
}

- (void)loadInterFaceWithType
{
    switch (_postingType) {
        case enumPostingType_AddVideo_At_Back_Kard:
        case enumPostingType_AddVideo:
        {
            _textPostView.frame = FRAME(0, _thumbView.frame.origin.y + _thumbView.frame.size.height,WIDTH_IPHONE,HEIGHT_IPHONE - HEIGHT_STATUS_BAR - _thumbView.frame.origin.y - _thumbView.frame.size.height - _menuTagView.frame.size.height - HEIGHT_IPHONE_KEYBOARD);
            _statusTextView.frame = CGRectMake(0, 0, _textPostView.frame.size.width, _textPostView.frame.size.height);
            _thumbImage.image = _thumbnailImage;
            _statusField.placeholder = kPlaceholderVideo;
            //TODO add Video
            
            _twitterButton.userInteractionEnabled = NO;
            _twitterButton.alpha = 0.5;
            _facebookButton.userInteractionEnabled = NO;
            _facebookButton.alpha = 0.5;
        }
            break;
        case enumPostingType_Audio:
        {
            // TODO add Audio
        }
            break;
            
        case enumPostingType_AddPhoto_At_Back_Kard:
        case enumPostingType_AddPhoto:
        {
            // TODO Add Photo
            _textPostView.frame = FRAME(0, _thumbView.frame.origin.y + _thumbView.frame.size.height,WIDTH_IPHONE,HEIGHT_IPHONE - HEIGHT_STATUS_BAR - _thumbView.frame.origin.y - _thumbView.frame.size.height - _menuTagView.frame.size.height - HEIGHT_IPHONE_KEYBOARD);
            _statusTextView.frame = CGRectMake(0, 0, _textPostView.frame.size.width, _textPostView.frame.size.height);
            _thumbImage.image = [UIImage imageWithData:_mediaData];
            _statusField.placeholder = kPlaceholderPhoto;
        }
            break;
            
        case enumPostingType_Status_At_Back_Kard:
        case enumPostingType_Status:
        {
            self.lbCaption.hidden = NO;
            //[_lbCaption setText:@"Atletico – Real: Người hùng Di Maria http://hcm.24h.com.vn/bong-da/atletico-real-c48a538757.html"];
            //_lbCaption.frame = CGRectMake(0, HEIGHT_HOME_VIEW_CONTROLLER_TITLE, _lbCaption.frame.size.width, _lbCaption.frame.size.height);
            self.lbCaption.text = self.strCaption;
            [self.lbCaption sizeToFit];
            
            [_thumbView setHidden:YES];
            
            [_textPostView setFrame:CGRectMake(0, HEIGHT_HOME_VIEW_CONTROLLER_TITLE + self.lbCaption.frame.size.height + 10, WIDTH_IPHONE, HEIGHT_IPHONE - HEIGHT_HOME_VIEW_CONTROLLER_TITLE - HEIGHT_STATUS_BAR - HEIGHT_IPHONE_KEYBOARD    - _menuTagView.frame.size.height)];
            _statusTextView.frame = CGRectMake(0, 0, _textPostView.frame.size.width, _textPostView.frame.size.height);
            _statusField.placeholder = kPlaceholderStatus;
        }
            break;
        case enumPostingType_AddLocation:
        {
//            // TODO Locationsf
//            [_thumbView setHidden:YES];
//            _statusField.placeholder = [NSString stringWithFormat:@"%@ %@?", kPlaceholderLocation ,_annotation.title];
//            [_textPostView setFrame:CGRectMake(0, HEIGHT_HOME_VIEW_CONTROLLER_TITLE, WIDTH_IPHONE, HEIGHT_IPHONE - HEIGHT_HOME_VIEW_CONTROLLER_TITLE - HEIGHT_STATUS_BAR - HEIGHT_IPHONE_KEYBOARD    - _menuTagView.frame.size.height)];
//            _statusTextView.frame = CGRectMake(0, 0, _textPostView.frame.size.width, _textPostView.frame.size.height);
        }
            break;
        default:
            break;
    }
}

#pragma mark - Action Methods

- (IBAction)locationButtonPressed:(id)sender {
//    if (!_addLocationView) {
//        _addLocationView = [[AddLocationView alloc] init];
//        _addLocationView.frame = [[UIScreen mainScreen] applicationFrame];
//        _addLocationView.delegate = self;
//        [self.view addSubview:_addLocationView];
//    }
//    //_addLocationView.hidden = NO;
//    [self.view bringSubviewToFront:_addLocationView];
//    
//    [UIView transitionFromView:self.view toView:_addLocationView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve completion:nil];
//    
//    
//    [_addLocationView initInterface];
}

- (IBAction)donePostingPressed:(id)sender {
    
    if (!self.isFacebook) {
        self.isFinishPostFacebook = YES;
    }
    
    if (!self.isTwitter) {
        self.isFinishPostTwitter = YES;
    }
    
    if (!self.isFacebook && !self.isTwitter) {
        //[self post2VK];
    } else {
        [self performSelector:@selector(postTwitterAndFacebook)];
    }
    
    return;
}

- (IBAction)cancelPostingPressed:(id)sender {
    if ([AppViewController Shared].isRequesting) {
        [[AppViewController Shared] isRequesting:NO andRequestType:ENUM_API_REQUEST_TYPE_INVALID andFrame:CGRectZero];
        [_requester cancelRequest];
    }
    
    if ([_delegate respondsToSelector:@selector(cancelPostingCallBack)]) {
        [_delegate cancelPostingCallBack];
    }
}

#pragma mark - APIRequesterProtocol
- (void)requestFailed:(ASIHTTPRequest *)request andType:(ENUM_API_REQUEST_TYPE)type
{
    NSLog(@"fail Responstring ===>  %@ response code:%d", request.responseString,request.responseStatusCode);
    [[AppViewController Shared] isRequesting:NO andRequestType:ENUM_API_REQUEST_TYPE_INVALID andFrame:CGRectZero];
    
    doneBtn.enabled = YES;
    doneBtn.alpha = 1.0f;
    _menuTagView.userInteractionEnabled = YES;

    if (![ASIHTTPRequest isNetworkReachable]) {
        ALERT(STRING_ALERT_CONNECTION_ERROR_TITLE, STRING_ALERT_CONNECTION_ERROR);
    }

}

- (void)requestFinished:(ASIHTTPRequest *)request andType:(ENUM_API_REQUEST_TYPE)type
{
    VKLog(@"Responstring ===>  %@", request.responseString);
    NSError *error;
    SBJSON *sbJSON = [[SBJSON alloc]init];
    if (![sbJSON objectWithString:[request responseString] error:&error] || request.responseStatusCode != 200 || !request) {
        
        //ALERT(STRING_ALERT_CONNECTION_ERROR_TITLE, STRING_ALERT_SERVER_ERROR); //Qasim 8/11/12
        VKLog(@"responseStatusCode=%i---responseString=%@",request.responseStatusCode,[request responseString]);
        return;
    }
    
    doneBtn.enabled = YES;
    doneBtn.alpha = 1.0f;
    _menuTagView.userInteractionEnabled = YES;

    
     NSMutableArray *jsonData = [sbJSON objectWithString:[request responseString] error:&error];
//    if (type == ENUM_API_REQUEST_TYPE_ALBUM_UPDATE_OBJECT_INFO) {
//        [[AppViewController Shared] isRequesting:NO andRequestType:type andFrame:CGRectZero];
//        if (jsonData.count > 0) {
//            if ([_delegate respondsToSelector:@selector(donePostingCallBackWithData:)]) {
//                [_delegate donePostingCallBackWithData:[jsonData objectAtIndex:0]];
//            }
//
//        }
//    }
//    if (type == ENUM_API_REQUEST_TYPE_ALBUM_UPLOAD_MEDIA) {
//        if (jsonData.count > 0) {
//            NSDictionary *mediaInfo = [SupportFunction normalizeDictionary:[jsonData objectAtIndex:0]];
//            NSString *locatonTitle = @"";
//            NSString *longitude = @"";
//            NSString *latitude = @"";
//            
//            if (_annotation) {
//                locatonTitle = _annotation.title;
//                longitude = [NSString stringWithFormat:@"%f",_annotation.coordinate.longitude];
//                latitude = [NSString stringWithFormat:@"%f", _annotation.coordinate.latitude];
//            }
//            NSArray *value = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%i",[UserDataManager Shared].userID], [NSString stringWithFormat:@"%i",_kardID], [NSString stringWithFormat:@"%i",_albumID],@"",_statusTextView.text,locatonTitle ,latitude, longitude, [NSString stringWithFormat:@"%i",_postingType],@"0",[mediaInfo objectForKey:@"fileM3u8"], [mediaInfo objectForKey:@"fileMp4"],[mediaInfo objectForKey:@"fileOgg"], [mediaInfo objectForKey:@"fileThumb"] , _friendsTag, nil];
//            NSArray *keys = [NSArray arrayWithObjects:@"fkUser", @"fkKard",@"fkAlbum", @"title", @"description", @"optionalLocation", @"latitude", @"longitude",@"mediatype",@"posttype", @"fileM3u8", @"fileMp4", @"fileOgg", @"fileThumbnail", @"tagFriendKard", nil];
//            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:value forKeys:keys];
//            [_requester requestWithType:ENUM_API_REQUEST_TYPE_ALBUM_UPDATE_OBJECT_INFO andRootURL:STRING_REQUEST_URL_ALBUM_ADD_OBJECT_INFO andPostMethodKind:YES andParams:params andDelegate:self];
//        }
//    }
//    else if (type == ENUM_API_REQUEST_TYPE_ALBUM_POST_PHOTO_ITEM_ON_FB) {
//        VKLog(@"%@", jsonData);
//        self.isFinishPostFacebook = YES;
//        if (self.isFinishPostTwitter) {
//            [self post2VK];
//        }
//    }
//    
//    else
    if (type == ENUM_API_REQUEST_TYPE_ALBUM_POST_STATUS_ON_FB) {
        self.isFinishPostFacebook = YES;
        if (self.isFinishPostTwitter) {
            //[self post2VK];
            [_delegate donePostingCallBackWithData:nil];
        }
    } else if (type == ENUM_API_REQUEST_TYPE_GET_SHORTENT_URL_ON_BITLY) {
        // NO USE ON APP FOR NOW. API will provide the shortent link
    }
}

- (void)requestUploadingProgress:(float)progress {
    if (progress > 0.93) {
        progressLable.text = @"Encoding Video";
    } else {
        videoCompressProgressBar.progress = progress;
    }
}

#pragma mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView isEqual:_statusTextView] && [_statusTextView.text isEqualToString:@""]) {
        [_statusField setHidden:NO];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView isEqual:_statusTextView] && _statusTextView.text.length <= 1 && range.location == 0 && [text isEqualToString:@""]) {
        [_statusField setHidden:NO];
    } else if ([textView isEqual:_statusTextView]) {
        [_statusField setHidden:YES];
    }
    
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        if (_statusTextView.text.length == 0) {
            [_statusField setHidden:NO];
        }
        //[_statusTextView resignFirstResponder];
        return FALSE;
    }
    
    return YES;
}


#pragma mark --- UIAlerview Delegate ---
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
   
    if (buttonIndex == 1) {
        NSLog(@"Connect");
        switch (makingLoginWith) {
            case 1:
            {
                UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
                [self presentViewController:controller animated:YES completion:nil];
                
            }
                break;
                
            case 2:
            {
                if (!_FBLoginDialogVC) {
                    _FBLoginDialogVC = [[FBFunLoginDialog alloc] initWithAppId:STRING_FACEBOOK_APP_ID requestedPermissions:STRING_FACEBOOK_APP_PERMISSION delegate:self];
                    //[_FBLoginDialogVC isLoadingView:YES];
                }
                
                [_FBLoginDialogVC login];
                [self presentViewController:_FBLoginDialogVC animated:YES completion:nil];
            }
            default:
                break;
        }
        
    }
}
#pragma mark Facbook & Twitter

- (IBAction)twitterButtonPressed:(id)sender {
    //UIButton *btn = (UIButton *)sender;
    if (self.isTwitter) {
        self.isTwitter = NO;
        twitterBtnBgImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"upload_twitter_default" ofType:@"png"]];
    } else {
        
        if (![ASIHTTPRequest isNetworkReachable]) {
            [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
            ALERT(STRING_ALERT_CONNECTION_ERROR_TITLE, STRING_ALERT_CONNECTION_ERROR);
        } else {
            if (!_engine) {
                _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
                _engine.consumerKey = kOAuthConsumerKey;
                _engine.consumerSecret = kOAuthConsumerSecret;
            }
            
            if (!_engine.isAuthorized) {
                //dongha 2013_04_11
                makingLoginWith = 1;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:[NSString stringWithFormat:@"To connect to %@ \n please sign in", @"Twitter"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Connect", nil];
                [alert show];
                
            } else {
                self.isTwitter = YES;
                twitterBtnBgImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"upload_twitter_active" ofType:@"png"]];
            }
        }
    }
}

- (IBAction)facebookButtonPressed:(id)sender {
    //UIButton *btn = (UIButton *)sender;
    if (self.isFacebook) {
        self.isFacebook = NO;
        facebookBtnBgImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"upload_facebook_default" ofType:@"png"]];
    } else {
        
        if (![ASIHTTPRequest isNetworkReachable]) {
            [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
            ALERT(STRING_ALERT_CONNECTION_ERROR_TITLE, STRING_ALERT_CONNECTION_ERROR);
        } else {
            /* VanDo -- 2013/03/29 -- edited Facebook posting */
            if ([FBFunLoginManager Shared].loginStatus) {
                self.facebookAccessToken = [FBFunLoginManager Shared].accessToken;
                self.isFacebook = YES;
                facebookBtnBgImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"upload_facebook_active" ofType:@"png"]];

            } else {
                //dongha 2013_04_11
                makingLoginWith = 2;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:[NSString stringWithFormat:@"To connect to %@ \n please sign in", @"Facebook"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Connect", nil];
                [alert show];
            }
        }
    }
}

- (void)FBLoginStatus {
    if ([FBFunLoginManager Shared].loginStatus) {
        //post photo/video to FB
         [self postDataOnSocialMedia:YES];
    }
}

- (void)TwitterLoginStatus {
    // TaiT: add new Twitter Lib
//    if ([TWLoginManager Shared].loginStatus) {
//        [self postDataOnSocialMedia:NO];
//    }
}

- (void)postDataOnSocialMedia:(BOOL)isOnFB {
    
//    if (_postingType == enumPostingType_AddPhoto || _postingType == enumPostingType_AddPhoto_At_Back_Kard) {
//        
//        if (isOnFB) {
//            NSString *_caption = _statusTextView.text;
//            NSString *strURLString = [NSString stringWithFormat:@"https://graph.facebook.com/me/photos?access_token=%@", self.facebookAccessToken];
//            
//            //dongha 2013_04_16 add location for post fb
//            if(self.lbLocation.text.length > 0) {
//                _caption = [NSString stringWithFormat:@"%@ — at %@", _caption, self.lbLocation.text];
//            }
//            //end
//            NSArray *params = [[NSArray alloc] initWithObjects:_mediaData, _caption, nil];
//            NSArray *keys = [[NSArray alloc] initWithObjects:@"source", @"message", nil];
//            
//            [_requester requestMultiPartRequestType:ENUM_API_REQUEST_TYPE_ALBUM_POST_PHOTO_ITEM_ON_FB andRootURL:strURLString andPostMethodKind:YES andParams:params andKeys:keys andDelegate:self];
//        } else {
//            //[_engine sendUpdate:@"test111111"];
//            UIImage *picture = _thumbImage.image;
//            NSData *imageData = UIImageJPEGRepresentation(picture, 1.0f);
//            //dongha 2013_04_16
//            if (_annotation.coordinate.latitude == _annotation.coordinate.longitude && _annotation.coordinate.longitude == 0.00000f ) {
//                [_engine postImageTW:imageData status:_statusTextView.text lat:@"" lon:@""];
//            } else {
//                [_engine postImageTW:imageData status:_statusTextView.text lat:[NSString stringWithFormat:@"%f", _annotation.coordinate.latitude] lon:[NSString stringWithFormat:@"%f", _annotation.coordinate.longitude]];
//            }
//            
//            //            [_engine postImageTW:imageData status:_statusTextView.text];
//        }
//        
//    } else if (_postingType == enumPostingType_AddVideo) {
    
//    } else
    if (_postingType == enumPostingType_AddLocation || _postingType == enumPostingType_Status || _postingType == enumPostingType_Status_At_Back_Kard) {
        if (isOnFB) {
            
            NSString *status = [NSString stringWithFormat:@"%@ \n%@",self.lbCaption.text,_statusTextView.text];
            //dongha 2013_04_16 add location for post fb
//            if(self.lbLocation.text.length > 0) {
//                status = [NSString stringWithFormat:@"%@ — at %@", status, self.lbLocation.text];
//            }
            //end
            
            NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithCapacity:1];
            [paramsDic setObject:status forKey:@"message"];
            
            NSString *strURLString = [NSString stringWithFormat:@"https://graph.facebook.com/me/feed?access_token=%@", self.facebookAccessToken];
            [_requester requestWithType:ENUM_API_REQUEST_TYPE_ALBUM_POST_STATUS_ON_FB andRootURL:strURLString andPostMethodKind:YES andParams:paramsDic andDelegate:self];
            
        } else {
            NSString *coordinateString = @"";
//            if (_annotation.coordinate.latitude == _annotation.coordinate.longitude && _annotation.coordinate.longitude == 0.00000f ) {
//                
//            } else {
//                coordinateString = [NSString stringWithFormat:@"%f,%f", _annotation.coordinate.latitude, _annotation.coordinate.longitude];
//            }
            
        NSString *status = [NSString stringWithFormat:@"%@ \n%@",self.lbCaption.text,_statusTextView.text];
            [_engine sendUpdate:status withLocation:coordinateString];
        }
    }
}
////
////=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
    
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	NSLog(@"Authenicated for %@", username);
    
    //[self postDataOnSocialMedia:NO];
    
    self.isTwitter = YES;
    twitterBtnBgImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"upload_twitter_active" ofType:@"png"]];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Failed!");
    
    self.isTwitter = NO;
    twitterBtnBgImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"upload_twitter_default" ofType:@"png"]];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Canceled.");
    
    self.isTwitter = NO;
    twitterBtnBgImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"upload_twitter_default" ofType:@"png"]];}

#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
    [self presentLoadingView:NO];
	NSLog(@"Request %@ succeeded", requestIdentifier);
    //ALERT(@"Twitter", @"Status posted successfully.");
    self.isFinishPostTwitter = YES;
    if (self.isFinishPostFacebook) {
        //[self post2VK];
        [_delegate donePostingCallBackWithData:nil];
    }
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
    [self presentLoadingView:NO];

	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate methods for TweetPic

- (void)requestFinished:(ASIHTTPRequest *)request {
    // TODO: Pass values as individual parameters to delegate methods instead of wrapping in NSDictionary.
    NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
    
    [delegateResponse setObject:request forKey:@"request"];
    [self presentLoadingView:NO];

    switch ([request responseStatusCode]) {
        case 200:
        {
            // Success, but let's parse and see.
            // TODO: Error out if parse failed?
            // TODO: Need further checks for success.
            NSDictionary *response = [[NSDictionary alloc] init];
            NSString *responseString = nil;
            responseString = [request responseString];
            response = [responseString JSONValue];
            NSLog(@"Success Response:%@",response.description);
            ALERT(@"Twitter", @"Photo posted successfully.");
            break;
        }
        case 400:
            NSLog(@"Failed: Bad request. Missing parameters");
            ALERT(@"Twitter", @"Bad request. Missing parameters");
            break;
        default:
            NSLog(@"Failed: request failed");
            ALERT(@"Twitter", @"request failed");

            break;
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request {
    NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
    
    [delegateResponse setObject:request forKey:@"request"];
    [self presentLoadingView:NO];

    switch ([request responseStatusCode]) {
        case 401:
            // Twitter.com could be down or slow. Or your request took too long to reach twitter.com authentication verification via twitpic.com.
            // TODO: Attempt to try again?
            [delegateResponse setObject:@"Timed out verifying authentication token with Twitter.com. This could be a problem with TwitPic servers. Try again later." forKey:@"errorDescription"];
            
            break;
        default:
            [delegateResponse setObject:@"Request failed." forKey:@"errorDescription"];
         break;
    }
    ALERT(@"Twitter", [delegateResponse valueForKey:@"errorDescription"]);
}

- (void)presentLoadingView:(BOOL)isRequesting {
    if (isRequesting) {
        if (_requestingView == nil) {
            _requestingView = [UIView new];
            _requestingView.backgroundColor = [UIColor blackColor];
            _requestingView.alpha= 0.5;
        }
        if (_requestingIndicator == nil) {
            _requestingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [_requestingView addSubview:_requestingIndicator];
            
        }
        
        [_requestingView removeFromSuperview];
        [_requestingIndicator startAnimating];
        CGRect frame = CGRectMake(0, HEIGHT_HOME_VIEW_CONTROLLER_TITLE, WIDTH_IPHONE, HEIGHT_IPHONE - HEIGHT_HOME_VIEW_CONTROLLER_TITLE - HEIGHT_STATUS_BAR);
		_requestingView.frame = frame;
		_requestingIndicator.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        [[self view] addSubview:_requestingView];
    }
    else {
        [_requestingIndicator stopAnimating];
        [_requestingView removeFromSuperview];
    }
}


#pragma mark FBFunLoginDialogDelegate

- (void)accessTokenFound:(NSString *)apiKey {
    [_FBLoginDialogVC dismissModalViewControllerAnimated:YES];
    
    //ALERT(@"Facebook", @"Status posted successfully.");
    
    self.facebookAccessToken = apiKey;
    
    // save token to share
    [FBFunLoginManager Shared].loginStatus = YES;
    [FBFunLoginManager Shared].accessToken = apiKey;
    VKLog(@"_vd_facebookAccessToken:%@", self.facebookAccessToken);
    
    self.isFacebook = YES;
    facebookBtnBgImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"upload_facebook_active" ofType:@"png"]];
}

- (void)displayRequired {
    
}

- (void)loginFail {
    
}

- (void)clickBack {
    [_FBLoginDialogVC dismissModalViewControllerAnimated:YES];
    
    self.isFacebook = NO;
    facebookBtnBgImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"upload_facebook_default" ofType:@"png"]];
}

- (void) getShortentUrl:(NSString*) url {
    //http://api.bitly.com/v3/shorten?login=aigogroup&apiKey=R_d0a7a46663ae22d76c35c4546bc7f049&longUrl=http%3A%2F%2Fbetaworks.com%2F&format=json
    
    NSString *strURL = [NSString stringWithFormat:@"http://api.bitly.com/v3/shorten?login=%@&apiKey=%@&longUrl=%@&format=json",BITLY_USERNAME,BITLY_API_KEY,url];
    [_requester requestWithType:ENUM_API_REQUEST_TYPE_GET_SHORTENT_URL_ON_BITLY andRootURL:strURL andPostMethodKind:NO andParams:nil andDelegate:self];
    
}

- (void)postTwitterAndFacebook {
    
    if (self.isTwitter) {
        [self postDataOnSocialMedia:NO];
        //[self UploadimageToTwitter];
        //[self postDataOnSocialMedia:NO];
    }
    
    if (self.isFacebook) {
        [self postDataOnSocialMedia:YES];
    }
}


//- (void)post2VK {
//    
//    doneBtn.enabled = NO;
//    doneBtn.alpha = 0.5f;
//    _menuTagView.userInteractionEnabled = NO;
//    
//    [[AppViewController Shared] isRequesting:YES andRequestType:ENUM_API_REQUEST_TYPE_ALBUM_UPDATE_OBJECT_INFO andFrame:CGRectMake(0, HEIGHT_HOME_VIEW_CONTROLLER_TITLE, WIDTH_IPHONE, HEIGHT_IPHONE - HEIGHT_HOME_VIEW_CONTROLLER_TITLE - HEIGHT_STATUS_BAR)];
//    
//    if (_postingType == enumPostingType_Status || _postingType == enumPostingType_AddLocation) {
//        if (![_statusTextView.text isEqualToString:@""]) {
//            NSString *locatonTitle = @"";
//            NSString *longitude = @"";
//            NSString *latitude = @"";
//            
//            if (_annotation) {
//                locatonTitle = _annotation.title;
//                longitude = [NSString stringWithFormat:@"%f",_annotation.coordinate.longitude];
//                latitude = [NSString stringWithFormat:@"%f", _annotation.coordinate.latitude];
//            }
//            NSArray *value = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%i",[UserDataManager Shared].userID], [NSString stringWithFormat:@"%i",_kardID], [NSString stringWithFormat:@"%i",_albumID],@"",_statusTextView.text,locatonTitle ,latitude, longitude, [NSString stringWithFormat:@"%i",_postingType],@"0",@"", @"", @"" , @"", _friendsTag, nil];
//            NSArray *keys = [NSArray arrayWithObjects:@"fkUser", @"fkKard",@"fkAlbum", @"title", @"description", @"optionalLocation", @"latitude", @"longitude",@"mediatype",@"posttype", @"fileM3u8", @"fileMp4", @"fileOgg", @"fileThumbnail", @"tagFriendKard", nil];
//            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:value forKeys:keys];
//            [_requester requestWithType:ENUM_API_REQUEST_TYPE_ALBUM_UPDATE_OBJECT_INFO andRootURL:STRING_REQUEST_URL_ALBUM_ADD_OBJECT_INFO andPostMethodKind:YES andParams:params andDelegate:self];
//            VKLog(@"===> %@", params);
//        }else
//        {
//            ALERT(@"", @"Write some thing please.");
//            doneBtn.enabled = YES;
//            doneBtn.alpha = 1.0f;
//        }
//    }
//    /*dongha 2013_04_12*/
//    if (_postingType == enumPostingType_Status_At_Back_Kard ) {
//        if (![_statusTextView.text isEqualToString:@""]) {
//            NSMutableDictionary  *params = [NSMutableDictionary new];
//            [params setObject:[NSString stringWithFormat:@"%i", [UserDataManager Shared].userID] forKey:@"fkUser"];
//            [params setObject:self.profileID forKey:@"fkProfile"];
//            [params setObject:[NSString stringWithFormat:@"%i", _kardID] forKey:@"fkKard"];
//            [params setObject:_statusTextView.text forKey:@"comments"];
//            
//            [_requester requestWithType:ENUM_API_REQUEST_TYPE_ADD_FEEDS andRootURL:STRING_REQUEST_URL_FEEDS_ADD andPostMethodKind:YES andParams:params andDelegate:self];
//
//        }else
//        {
//            ALERT(@"", @"Write some thing please.");
//            doneBtn.enabled = YES;
//            doneBtn.alpha = 1.0f;
//        }
//    }
//
//    //end
//    else if (_postingType == enumPostingType_AddPhoto )
//    {
//        NSArray *value = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%i",[UserDataManager Shared].userID], [NSString stringWithFormat:@"%i",_albumID],[NSString stringWithFormat:@"%i",_kardID], [NSString stringWithFormat:@"%i",_postingType] , @"0", @"1", STRING_APP_NAME ,@"photo.jpg", _mediaData, nil];
//        NSArray *keys = [NSArray arrayWithObjects:@"fkUser",@"fkAlbum" ,@"fkkard", @"mediatype", @"posttype",@"rotate", @"appname",@"filename", @"sourcemedia",nil];
//        [_requester requestMultiPartRequestType:ENUM_API_REQUEST_TYPE_ALBUM_UPLOAD_MEDIA andRootURL:STRING_REQUEST_URL_ALBUM_UPLOAD_MEDIA andPostMethodKind:YES andParams:value andKeys:keys andDelegate:self];
//        
//    }
//    /*dongha 2013_04_12 */
//    else if (_postingType == enumPostingType_AddPhoto_At_Back_Kard )
//    {
//        NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
//        NSString *intervalString = [NSString stringWithFormat:@"%.0f", today];
//        NSArray *value = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%i", [UserDataManager Shared].userID], [NSString stringWithFormat:@"%i", _kardID], @" ",[NSString stringWithFormat:@"%@.png", intervalString],_statusTextView.text, @"3", @"0", @"0", _mediaData, nil]];
//        
//        NSArray *keys = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:@"userId", @"kardId", @"mediaName", @"fileName", @"mediaDescription", @"mediaType", @"postType",@"rotate", @"media", nil]];
//        [_requester requestMultiPartRequestType:ENUM_API_REQUEST_TYPE_BACK_KARD_MEDIA_PHOTO andRootURL:STRING_REQUEST_URL_BACKARD_ADD_MEDIA andPostMethodKind:YES andParams:value andKeys:keys andDelegate:self];
//
//    } // end
//    
//    else if (_postingType == enumPostingType_AddVideo)
//    {
//        NSArray *value = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%i",[UserDataManager Shared].userID], [NSString stringWithFormat:@"%i",_albumID],[NSString stringWithFormat:@"%i",_kardID], [NSString stringWithFormat:@"%i",_postingType] , @"0", [NSString stringWithFormat:@"%i",_videoOrientation], STRING_APP_NAME ,@"video.mov", _mediaData, nil];
//        NSArray *keys = [NSArray arrayWithObjects:@"fkUser",@"fkAlbum" ,@"fkkard", @"mediatype", @"posttype",@"rotate", @"appname",@"filename", @"sourcemedia",nil];
//        
//        [self addProgressView];
//        
//        [_requester videoRequestMultiPartRequestType:ENUM_API_REQUEST_TYPE_ALBUM_UPLOAD_MEDIA andRootURL:STRING_REQUEST_URL_ALBUM_UPLOAD_MEDIA andPostMethodKind:YES andParams:value andKeys:keys andDelegate:self ProgressBar:videoCompressProgressBar andTimeOut:TIMER_REQUEST_UPLOAD_VIDEO_TIMEOUT];
//    }
//    else if (_postingType == enumPostingType_AddVideo_At_Back_Kard) {
//        
//        NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
//        NSString *intervalString = [NSString stringWithFormat:@"%.0f", today];
//
//        NSData *videoThumbnailData = nil;
//        videoThumbnailData = UIImagePNGRepresentation(_thumbnailImage);
//        
//        NSArray *value = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%i", [UserDataManager Shared].userID], [NSString stringWithFormat:@"%i",_kardID], @"Video",[NSString stringWithFormat:@"%@.%@", intervalString,@"mov"], _statusTextView.text, @"1", @"0", [NSString stringWithFormat:@"%i", _videoOrientation], _mediaData, videoThumbnailData, nil]];
//        
//        NSArray *keys = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:@"userId", @"kardId", @"mediaName", @"fileName", @"mediaDescription", @"mediaType", @"postType", @"rotate", @"media", @"thumbnail", nil]];
//        
//        [self addProgressView];
//        
//        [_requester videoRequestMultiPartRequestType:ENUM_API_REQUEST_TYPE_BACK_KARD_ADD_MEDIA_VIDEO andRootURL:STRING_REQUEST_URL_BACKARD_IOS_MEDIA_SAVE andPostMethodKind:YES andParams:value andKeys:keys andDelegate:self ProgressBar:videoCompressProgressBar andTimeOut:TIMER_REQUEST_UPLOAD_VIDEO_TIMEOUT];
//    }
//}

//Qasim: 26/04/2013
- (void) addProgressView {
    
    if (showProgressView) {
        [showProgressView removeFromSuperview];
    }
    // Add ProgressBarView
    showProgressView.frame = CGRectMake(0,(_textPostView.frame.origin.y+_textPostView.frame.size.height)-_menuTagView.frame.size.height, showProgressView.frame.size.width, showProgressView.frame.size.height);
    
    //showProgressView.frame = CGRectMake(0,[SupportFunction getDeviceHeight]-HEIGHT_IPHONE_KEYBOARD-_menuTagView.frame.size.height, showProgressView.frame.size.width, showProgressView.frame.size.height);
    
    [self.view addSubview:showProgressView];
    
    progressLable.text = @"Saving Video";
    videoCompressProgressBar.progress = 0.0f;
}



@end