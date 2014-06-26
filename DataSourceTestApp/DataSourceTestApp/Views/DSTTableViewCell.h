//
//  DSTTableViewCell.h
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DSTTableViewCellProtocol <NSObject>

@required
- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

@interface DSTTableViewCell : UITableViewCell <DSTTableViewCellProtocol>

+ (UITableViewCellStyle)defaultTableViewCellStyle;
+ (NSString *)defaultTableViewCellIdentifier;
+ (NSString *)defaultTableViewCellNibName;
+ (UINib *)defaultNib;
+ (CGFloat)defaultTableViewCellHeight;

+ (id)cellForTableView:(UITableView *)tableView;
+ (id)cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib;

@end

@interface DSTTableViewCell (DSTSubclassOnly)

- (void)finishInitialize;

@end