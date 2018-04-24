//
//  VideViewController.h
//  my-app
//
//  Created by 刘佳杰 on 2018/4/13.
//
//
//
//  AnyChatViewController.h
//  helloAnyChat
//
//  Created by AnyChat on 14-9-12.
//  Copyright (c) 2014年 GuangZhou BaiRui NetWork Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"

#import "AnyChatPlatform.h"
#import "AnyChatDefine.h"
#import "AnyChatErrorCode.h"



@interface VideoViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,MBProgressHUDDelegate,UITextFieldDelegate,AnyChatNotifyMessageDelegate>{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UITextField            *theUserName;
@property (weak, nonatomic) IBOutlet UITextField            *theRoomNO;
@property (weak, nonatomic) IBOutlet UITextField            *theServerIP;
@property (weak, nonatomic) IBOutlet UITextField            *theServerPort;
@property (weak, nonatomic) IBOutlet UIButton               *theLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton               *theHideKeyboardBtn;
@property (weak, nonatomic) IBOutlet UILabel                *theVersion;
@property (weak, nonatomic) IBOutlet UILabel                *theStateInfo;

@property (strong, nonatomic) NSMutableArray                *onlineUserMArray;

@property (strong, nonatomic) VideoViewController           *videoVC;
@property (strong, nonatomic) AnyChatPlatform               *anyChat;
@property BOOL theOnLineLoginState;
@property int theMyUserID;
@property int theTargetUserID;
@property int iRemoteUserId;

- (NSMutableArray *) getOnlineUserArray;

- (void) StartVideoChat:(int) userid;

- (IBAction) FinishVideoChatBtnClicked:(id)sender;

- (IBAction) OnSwitchCameraBtnClicked:(id)sender;

- (IBAction) OnCloseVoiceBtnClicked:(id)sender;

- (IBAction) OnCloseCameraBtnClicked:(id)sender;

- (void) saveSettings;

- (void) OnLogout;


@end
