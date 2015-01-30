//
//  ContactsVC.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "ContactsVC.h"
#import "CoreEngine.h"
#import "UserInfo.h"

@interface ContactsVC () <UITableViewDataSource, UITableViewDelegate> {
    
    UITableView *_tableView;
    
    NSMutableArray *_marrFriend;
}

@end

@implementation ContactsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"联系人";
        _marrFriend = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    [self.view addSubview:_tableView];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
    [defaultCenter addObserver:self selector:@selector(notifUserInfoSuccess:)
                          name:NetUserInfoSuccess object:nil];
    
    if ([self.dataSource respondsToSelector:@selector(contactsVC:loadContacts:)]) {
        [self.dataSource contactsVC:self loadContacts:_marrFriend];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    _tableView.frame = self.view.bounds;
}


#pragma mark - Notification

- (void)notifUserInfoSuccess:(NSNotification *)notif
{
    UInt64 userID = [[notif.userInfo objectForKey:@"userid"] longLongValue];
    NSString *userName = [notif.userInfo objectForKey:@"username"];
    NSString *avatarUrl = [notif.userInfo objectForKey:@"avatar"];
    //
    for (UserInfo *friendInfo in _marrFriend) {
        if (friendInfo.userID == userID) {
            friendInfo.userName = userName;
            friendInfo.avatarUrl = avatarUrl;
            [_tableView reloadData];
            break;
        }
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _marrFriend.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellId = @"FriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId] autorelease];
    }
    //
    UserInfo *friendInfo = [_marrFriend objectAtIndex:indexPath.row];
    cell.textLabel.text = friendInfo.userName;
    // 显示头像
    [cell.imageView loadImageFromCachePath:nil orPicUrl:friendInfo.avatarUrl withDownloadResult:^(UIImageView *imageView, NSString *picUrl, NSError *error) {
        // error为nil表示下载成功
        if (nil == error) {
            [_tableView reloadData];
        }
    }];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(contactsVC:showContactsInfo:)]) {
        UserInfo *friendInfo = [_marrFriend objectAtIndex:indexPath.row];
        [self.delegate contactsVC:self showContactsInfo:friendInfo.userID];
    }
}

@end
