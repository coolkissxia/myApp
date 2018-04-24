//
//  VideViewController.m
//  my-app
//
//  Created by 刘佳杰 on 2018/4/13.
//
//

#import "VideViewController.h"
#import "SettingVC.h"



#define kAnyChatRoomID 1
#define kUserID 1001
#define kAnyChatIP @"demo.anychat.cn"
#define kAnyChatPort 8906
#define kAnyChatUserName @"AnyChat"



@interface VideoViewController()
@end

@implementation VideoViewController

@synthesize anyChat;
@synthesize theServerIP;
@synthesize theServerPort;
@synthesize theRoomNO;
@synthesize theUserName;
@synthesize onlineUserMArray;
@synthesize theOnLineLoginState;

@synthesize theMyUserID;
@synthesize videoVC;


@synthesize iRemoteUserId;
@synthesize remoteVideoSurface;
@synthesize localVideoSurface;
@synthesize theLocalView;
@synthesize endCallBtn;
@synthesize switchCameraBtn;
@synthesize voiceBtn;
@synthesize cameraBtn;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}


-(void)viewDidLoad{

    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AnyChatNotifyHandler:) name:@"ANYCHATNOTIFY" object:nil];
    
    [AnyChatPlatform InitSDK:0];
    
    anyChat = [AnyChatPlatform getInstance];
    anyChat.notifyMsgDelegate = self;
    // 设置应用ID
    //    [AnyChatPlatform SetSDKOptionString:BRAC_SO_CLOUD_APPGUID :nil];
    //创建默认视频参数
    
    //[[SettingVC sharedSettingVC] createObjPlistFileToDocumentsPath];
    
}
- (void) OnLogin
{
    //连接服务器
    [AnyChatPlatform Connect:kAnyChatIP : kAnyChatPort];
    
    //执行anychat登陆
    [AnyChatPlatform Login:kAnyChatUserName :nil];
    
}

// 连接服务器消息
- (void) OnAnyChatConnect:(BOOL) bSuccess
{
    if (bSuccess)
    {
        NSLog(@"• Success connected to server");
    }else {
        NSLog( @"• Fail connected to server");
        [HUD hide:YES];
    }
}

// 用户登陆消息
- (void) OnAnyChatLogin:(int) dwUserId : (int) dwErrorCode
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    onlineUserMArray = [NSMutableArray arrayWithCapacity:5];
    if(dwErrorCode == GV_ERR_SUCCESS)
    {
        theOnLineLoginState = YES;
        theMyUserID = dwUserId;
        [self saveSettings];  //save correct configuration
        
        NSLog(@" Login successed. Self UserId: %d", dwUserId);
        if([theRoomNO.text length] == 0)
        {
            theRoomNO.text = [NSString stringWithFormat:@"%d",kAnyChatRoomID];
        }
        [AnyChatPlatform EnterRoom:(int)[theRoomNO.text integerValue] :@""];
    }
    else
    {
        theOnLineLoginState = NO;
        NSLog(@"• Login failed(ErrorCode:%i)",dwErrorCode);
    }
    
}

// 用户进入房间消息
- (void) OnAnyChatEnterRoom:(int) dwRoomId : (int) dwErrorCode
{
    if (dwErrorCode != 0) {
        NSLog(@"• Enter room failed(ErrorCode:%i)",dwErrorCode);
    }
    if (dwErrorCode == 0) {
        [self StartVideoChat:self.iRemoteUserId];
    }

    //[onLineUserTableView reloadData];
}

- (void) StartVideoChat:(int) userid{
    NSMutableArray* cameraDeviceArray = [AnyChatPlatform EnumVideoCapture];
    if (cameraDeviceArray.count > 0)
    {
        [AnyChatPlatform SelectVideoCapture:[cameraDeviceArray objectAtIndex:1]];
    }
    
    // open local video
    [AnyChatPlatform SetSDKOptionInt:BRAC_SO_LOCALVIDEO_OVERLAY :1];
    [AnyChatPlatform UserSpeakControl: -1:YES];
    [AnyChatPlatform SetVideoPos:-1 :self :0 :0 :0 :0];
    [AnyChatPlatform UserCameraControl:-1 : YES];
    // request other user video
    [AnyChatPlatform UserSpeakControl: userid:YES];
    [AnyChatPlatform SetVideoPos:userid: self.remoteVideoSurface:0:0:0:0];
    [AnyChatPlatform UserCameraControl:userid : YES];
    
    self.iRemoteUserId = userid;
    //远程视频显示时随设备的方向改变而旋转（参数为int型， 0表示关闭， 1 开启[默认]，视频旋转时需要参考本地视频设备方向参数）
    [AnyChatPlatform SetSDKOptionInt:BRAC_SO_LOCALVIDEO_ORIENTATION : self.interfaceOrientation];
}

- (void) FinishVideoChat
{
    // 关闭摄像头
    [AnyChatPlatform UserSpeakControl: -1 : NO];
    [AnyChatPlatform UserCameraControl: -1 : NO];
    
    [AnyChatPlatform UserSpeakControl: self.iRemoteUserId : NO];
    [AnyChatPlatform UserCameraControl: self.iRemoteUserId : NO];
    
    self.iRemoteUserId = -1;
    
    AnyChatViewController *videoVC = [AnyChatViewController new];
    videoVC.onlineUserMArray = [videoVC getOnlineUserArray];
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 房间在线用户消息（在线用户进入房间成功后调用一次）
- (void) OnAnyChatOnlineUser:(int) dwUserNum : (int) dwRoomId
{
    onlineUserMArray = [self getOnlineUserArray];
   // [onLineUserTableView reloadData];
    
    
    
}


// 用户退出房间消息
- (void) OnAnyChatUserLeaveRoom:(int) dwUserId
{
    if (videoVC.iRemoteUserId == dwUserId )
    {
        [videoVC FinishVideoChat];
        NSString *name = [AnyChatPlatform GetUserName:dwUserId];
        NSString *theLeaveRoomName = [[NSString alloc] initWithFormat:@"\"%@\"已离开房间!",name];
        UIAlertView *leaveRoomAlertView = [[UIAlertView alloc] initWithTitle:theLeaveRoomName
                                                                     message:@"The remote user Leave Room."
                                                                    delegate:self
                                                           cancelButtonTitle:nil
                                                           otherButtonTitles:@"确定",nil];
        [leaveRoomAlertView show];
        //videoVC.iRemoteUserId = -1;
    }
    onlineUserMArray = [self getOnlineUserArray];
    //[onLineUserTableView reloadData];
}

// 网络断开消息
- (void) OnAnyChatLinkClose:(int) dwErrorCode {
    [videoVC FinishVideoChat];
    [AnyChatPlatform LeaveRoom:-1];
    [AnyChatPlatform Logout];
    theOnLineLoginState = NO;
    [onlineUserMArray removeAllObjects];
    //[onLineUserTableView reloadData];
    
    NSLog(@"• OnLinkClose(ErrorCode:%i)",dwErrorCode);
    
}



-(void)OnLogout{
}
@end
