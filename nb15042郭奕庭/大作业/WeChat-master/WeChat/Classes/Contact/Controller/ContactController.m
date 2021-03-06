//
//  ContactController.m
//  WeChat
//
//  Created by greeting on 15/10/5.
//  Copyright © 2015年 com.greeting. All rights reserved.
//

#import "ContactController.h"
#import "AddFriendsController.h"
#import "NewFriendCell.h"
#import "FriendsCell.h"
#import "DetailFriendController.h"
#import "XMPPvCardTemp.h"

@interface ContactController ()<NSFetchedResultsControllerDelegate,UIScrollViewDelegate>

@property(nonatomic,strong) NSFetchedResultsController *resultsFriends;

@end

@implementation ContactController


-(NSFetchedResultsController *)resultsFriends
{
    if (!_resultsFriends)
    {
    // 指定查询的实体
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 显示的名称排序
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    
    // 添加排序
    request.sortDescriptors = @[sort1];
        
    //[NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[UserInfo sharedUserInfo].JID];

    // 添加谓词过滤器
    request.predicate = [NSPredicate predicateWithFormat:@"subscription != 'none'"];
    
    // 添加上下文
    NSManagedObjectContext *ctx = [XmppTools sharedXmppTools].rosterStorage.mainThreadManagedObjectContext;
    
    // 实例化结果控制器
    _resultsFriends = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    
    // 设置他的代理
    _resultsFriends.delegate = self;
    }
    
    return _resultsFriends;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.resultsFriends performFetch:NULL];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"contacts_add_friend"] style:UIBarButtonItemStylePlain target:self action:@selector(addFriends)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addFriends
{
    AddFriendsController *addfriends = [[AddFriendsController alloc]init];
    
    [self.navigationController pushViewController:addfriends animated:YES];
}


#pragma mark 当数据的内容发生改变后，会调用这个方法

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [UserInfo sharedUserInfo].addFriends.count;
    }
    else
    {
        return self.resultsFriends.fetchedObjects.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMPPUserCoreDataStorageObject *user = nil;
    XMPPvCardTemp *vCard = nil;
    SeparatorView *topseparator = [[SeparatorView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
    SeparatorView *bottomseparator = [[SeparatorView alloc] initWithFrame:CGRectMake(0, 60, ScreenWidth, 0.5)];

    if (indexPath.section == 0)
    {
        NewFriendCell *cell = [[NewFriendCell alloc]init];
        XMPPJID * Jid = [[UserInfo sharedUserInfo].addFriends objectAtIndex:indexPath.row];
        
        cell.friendName.text = Jid.user;
        cell.Jid = Jid;
        [cell.avatar setImage:[UIImage imageNamed:@"DefaultProfileHead_phone"]];
        
        vCard = [[XmppTools sharedXmppTools].vCard vCardTempForJID:Jid shouldFetch:YES];
    
        if (vCard)
        {
            if (vCard.nickname)
            {
                cell.friendName.text = vCard.nickname;
            }
            if (vCard.photo)
            {
                [cell.avatar setImage:[UIImage imageWithData:vCard.photo]];
            }
        }
        
        [cell.contentView addSubview:topseparator];
        [cell.contentView addSubview:bottomseparator];
        return cell;
    }
    else
    {
        FriendsCell *cell = [[FriendsCell alloc] init];
        user = [self.resultsFriends.fetchedObjects objectAtIndex:indexPath.row];
        cell.friendName.text = user.jid.user;
        [cell.avatar setImage:[UIImage imageNamed:@"DefaultProfileHead_phone"]];
        
        vCard = [[XmppTools sharedXmppTools].vCard vCardTempForJID:user.jid shouldFetch:YES];
        
        if (vCard)
        {
            if (vCard.nickname)
            {
                cell.friendName.text = vCard.nickname;
            }
            if (vCard.photo)
            {
                [cell.avatar setImage:[UIImage imageWithData:vCard.photo]];
            }
        }
        
        [cell.contentView addSubview:topseparator];
        [cell.contentView addSubview:bottomseparator];
        return cell;
    }
    // subscription
    // 如果是none表示对方还没有确认
    // to   我关注对方
    // from 对方关注我
    // both 互粉
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0 && [UserInfo sharedUserInfo].addFriends.count != 0)
    {
        return 26;
    }
    if (section == 1 && self.resultsFriends.fetchedObjects.count != 0)
    {
        return 26;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width,26)];
    [view setBackgroundColor:SelfColor(242, 242, 249)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 3, tableView.width - 10, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:SelfColor(135, 135, 142)];
    label.font = [UIFont systemFontOfSize:15];
    if(section == 0 && [UserInfo sharedUserInfo].addFriends.count != 0)
    {
        [label setText:@"新的朋友"];
        [view addSubview:label];
    }
    if (section == 1 && self.resultsFriends.fetchedObjects.count != 0)
    {
        [label setText:@"好友"];
        [view addSubview:label];
    }
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        DetailFriendController *detailfriends = [[DetailFriendController alloc]init];
        XMPPUserCoreDataStorageObject *user = [self.resultsFriends.fetchedObjects objectAtIndex:indexPath.row];
        detailfriends.account = user.jid;
        
        [self.navigationController pushViewController:detailfriends animated:YES];
    }
}

@end
