//
//  NewFriendCell.h
//  WeChat
//
//  Created by greeting on 15/10/15.
//  Copyright © 2015年 com.greeting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFriendCell : UITableViewCell

@property (nonatomic,weak) UILabel *friendName;
@property (nonatomic,weak) UIImageView *avatar;
@property (nonatomic,weak) XMPPJID *Jid;

@end
