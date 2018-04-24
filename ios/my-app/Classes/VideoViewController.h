//
//  VideoViewController.h
//  my-app
//
//  Created by 刘佳杰 on 2018/4/19.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "VideoViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "AnyChatPlatform.h"
#import "AnyChatDefine.h"
#import "AnyChatErrorCode.h"


@class VideoViewController;

@interface VideoViewController :  UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,MBProgressHUDDelegate,UITextFieldDelegate,AnyChatNotifyMessageDelegate>{
    MBProgressHUD *HUD;
}



@property (strong, nonatomic) VideoViewController           *videoVC;
@property (strong, nonatomic) AnyChatPlatform               *anyChat;
@property BOOL theOnLineLoginState;
@property int theMyUserID;
@property int theTargetUserID;
@property (strong, nonatomic) NSMutableArray                *onlineUserMArray;


@property (strong, nonatomic) AVCaptureVideoPreviewLayer    *localVideoSurface;
@property (strong, nonatomic) IBOutlet UIImageView          *remoteVideoSurface;
@property (strong, nonatomic) IBOutlet UIView               *theLocalView;
@property (weak, nonatomic) IBOutlet UIButton               *switchCameraBtn;
@property (weak, nonatomic) IBOutlet UIButton               *endCallBtn;
@property (weak, nonatomic) IBOutlet UIButton               *voiceBtn;
@property (weak, nonatomic) IBOutlet UIButton               *cameraBtn;
@property int iRemoteUserId;

- (IBAction) FinishVideoChatBtnClicked:(id)sender;

- (IBAction) OnSwitchCameraBtnClicked:(id)sender;

- (IBAction) OnCloseVoiceBtnClicked:(id)sender;

- (IBAction) OnCloseCameraBtnClicked:(id)sender;

- (void) FinishVideoChat;

- (void) StartVideoChat:(int) userid;

- (void) btnSelectedOnClicked:(UIButton*)button;


- (IBAction) OnLoginBtnClicked:(id)sender;

- (NSMutableArray *) getOnlineUserArray;

- (void) OnLogout;
- (void) saveSettings;

@end
