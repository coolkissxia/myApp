//
//  VideoViewController.m
//  my-app
//
//  Created by 刘佳杰 on 2018/4/19.
//
//

#import "VideoViewController.h"
#import "SettingVC.h"

#define kAnyChatRoomID 1
#define kUserID 1001
#define kAnyChatIP @"demo.anychat.cn"
#define kAnyChatPort @"8906"
#define kAnyChatUserName @"AnyChat"


@interface VideoViewController ()

@end

@implementation VideoViewController

@synthesize anyChat;
@synthesize theOnLineLoginState;
@synthesize theMyUserID;
@synthesize iRemoteUserId;
@synthesize onlineUserMArray;

@synthesize switchCameraBtn;
@synthesize voiceBtn;
@synthesize cameraBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AnyChatNotifyHandler:) name:@"ANYCHATNOTIFY" object:nil];
    
    [AnyChatPlatform InitSDK:0];
    
    anyChat = [AnyChatPlatform getInstance];
    anyChat.notifyMsgDelegate = self;
    // 设置应用ID
    //    [AnyChatPlatform SetSDKOptionString:BRAC_SO_CLOUD_APPGUID :nil];
    
    //创建默认视频参数
    [[SettingVC sharedSettingVC] createObjPlistFileToDocumentsPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)AnyChatNotifyHandler:(NSNotification*)notify
{
    NSDictionary* dict = notify.userInfo;
    [anyChat OnRecvAnyChatNotify:dict];
}

- (void) OnLogin
{
    //连接服务器
    [AnyChatPlatform Connect:kAnyChatIP: kAnyChatPort];
    
}


// 连接服务器消息
- (void) OnAnyChatConnect:(BOOL) bSuccess
{
    if (bSuccess)
    {
        NSLog(@"• Success connected to server");
        //登陆
        [AnyChatPlatform Login:kAnyChatUserName:nil];
    }else {
        NSLog(@"• Fail connected to server");
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
        //根据房间ID进入房间
       [AnyChatPlatform EnterRoom:kAnyChatRoomID :@""];
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
    
}
// 房间在线用户消息
- (void) OnAnyChatOnlineUser:(int) dwUserNum : (int) dwRoomId
{
    onlineUserMArray = [self getOnlineUserArray];
    
}

// 用户进入房间消息
- (void) OnAnyChatUserEnterRoom:(int) dwUserId
{
    onlineUserMArray = [self getOnlineUserArray];
    
}

// 用户退出房间消息
- (void) OnAnyChatUserLeaveRoom:(int) dwUserId
{
    if (iRemoteUserId == dwUserId )
    {
        [self FinishVideoChat];
        NSString *name = [AnyChatPlatform GetUserName:dwUserId];
        NSString *theLeaveRoomName = [[NSString alloc] initWithFormat:@"\"%@\"已离开房间!",name];
        UIAlertView *leaveRoomAlertView = [[UIAlertView alloc] initWithTitle:theLeaveRoomName
                                                                     message:@"The remote user Leave Room."
                                                                    delegate:self
                                                           cancelButtonTitle:nil
                                                           otherButtonTitles:@"确定",nil];
        [leaveRoomAlertView show];
        iRemoteUserId = -1;
    }
    onlineUserMArray = [self getOnlineUserArray];
    
}

// 网络断开消息
- (void) OnAnyChatLinkClose:(int) dwErrorCode {
    [self FinishVideoChat];
    [AnyChatPlatform LeaveRoom:-1];
    [AnyChatPlatform Logout];
    theOnLineLoginState = NO;
    [onlineUserMArray removeAllObjects];
    NSLog(@"• OnLinkClose(ErrorCode:%i)",dwErrorCode);
    
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


//摄像头资源释放
- (void) OnLocalVideoRelease:(id)sender
{
    if(self.localVideoSurface) {
        self.localVideoSurface = nil;
    }
}
//摄像头资源初始化
- (void) OnLocalVideoInit:(id)session
{
    self.localVideoSurface = [AVCaptureVideoPreviewLayer layerWithSession: (AVCaptureSession*)session];
    self.localVideoSurface.frame = CGRectMake(0, 0, kLocalVideo_Width, kLocalVideo_Height);
    self.localVideoSurface.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.theLocalView.layer addSublayer:self.localVideoSurface];
}


- (void) btnSelectedOnClicked:(UIButton*)button{}

- (IBAction) OnLoginBtnClicked:(id)sender{}

- (NSMutableArray *) getOnlineUserArray{
    NSMutableArray *onLineUserList = [[NSMutableArray alloc] initWithArray:[AnyChatPlatform GetOnlineUser]];
    [onLineUserList insertObject:[NSString stringWithFormat:@"%i",self.theMyUserID] atIndex:0];
    return onLineUserList;}

//结束
- (IBAction)FinishVideoChatBtnClicked:(id)sender
{
    UIActionSheet *isFinish = [[UIActionSheet alloc]
                               initWithTitle:@"确定结束会话?"
                               delegate:self
                               cancelButtonTitle:nil
                               destructiveButtonTitle:nil
                               otherButtonTitles:@"确定",@"取消", nil];
    isFinish.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [isFinish showInView:self.view];
}
//摄像头切换

- (IBAction) OnSwitchCameraBtnClicked:(id)sender
{
    static int CurrentCameraDevice = 1;
    NSMutableArray* cameraDeviceArray = [AnyChatPlatform EnumVideoCapture];
    if(cameraDeviceArray.count == 2)
    {
        CurrentCameraDevice = (CurrentCameraDevice+1) % 2;
        [AnyChatPlatform SelectVideoCapture:[cameraDeviceArray objectAtIndex:CurrentCameraDevice]];
    }
    
    [self btnSelectedOnClicked:switchCameraBtn];
}
- (IBAction)OnCloseVoiceBtnClicked:(id)sender
{
    if (voiceBtn.selected == NO)
    {
        [AnyChatPlatform UserSpeakControl:-1 :NO];
        voiceBtn.selected = YES;
    }
    else
    {
        [AnyChatPlatform UserSpeakControl: -1:YES];
        voiceBtn.selected = NO;
    }
}

- (IBAction) OnCloseCameraBtnClicked:(id)sender{}

- (void) FinishVideoChat{

    // 关闭摄像头
    [AnyChatPlatform UserSpeakControl: -1 : NO];
    [AnyChatPlatform UserCameraControl: -1 : NO];
    
    [AnyChatPlatform UserSpeakControl: self.iRemoteUserId : NO];
    [AnyChatPlatform UserCameraControl: self.iRemoteUserId : NO];
    
    self.iRemoteUserId = -1;
    
    [self.navigationController popViewControllerAnimated:YES];

}
//设置保存
-(void) saveSettings{

}

- (void) OnLogout{}


@end
