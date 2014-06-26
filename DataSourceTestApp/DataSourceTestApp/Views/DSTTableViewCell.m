//
//  DSTTableViewCell.m
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "DSTTableViewCell.h"

#define DefaultTableViewCellHeight  44.0f

@implementation DSTTableViewCell

+ (UITableViewCellStyle)defaultTableViewCellStyle {
    return UITableViewCellStyleDefault;
}

+ (NSString *)defaultTableViewCellIdentifier {
    return NSStringFromClass([self class]);
}

+ (NSString *)defaultTableViewCellNibName {
    return nil;
}

+ (UINib *)defaultNib {
    if ([self defaultTableViewCellNibName] && [[self defaultTableViewCellNibName] length]) {
        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        return [UINib nibWithNibName:[self defaultTableViewCellNibName] bundle:bundle];
    }
    
    return nil;
}

+ (CGFloat)defaultTableViewCellHeight {
    if ([self defaultTableViewCellNibName] && [[self defaultTableViewCellNibName] length]) {
        NSArray * nibObjects = [[self defaultNib] instantiateWithOwner:nil options:nil];
        NSAssert2([nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[self class]], @"Nib '%@' doesn't appear to contain a valid %@", [self defaultTableViewCellNibName], NSStringFromClass([self class]));
        UITableViewCell * cell = (UITableViewCell *)[nibObjects objectAtIndex:0];
        return cell.bounds.size.height;
    }
    
    return DefaultTableViewCellHeight;
}

+ (id)cellForTableView:(UITableView *)tableView {
    NSParameterAssert(tableView);
    
    UITableViewCell * cell = nil;
    
    if ([self defaultTableViewCellNibName] && [[self defaultTableViewCellNibName] length]) {
        cell = [self cellForTableView:tableView fromNib:[self defaultNib]];
    }
    else {
        NSAssert([self defaultTableViewCellIdentifier] && [[self defaultTableViewCellIdentifier] length], @"Default table view cell identifier is empty");
        
        NSString * cellIdentifier = [self defaultTableViewCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            [tableView registerClass:[self class] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
    }
    
    return cell;
}

+ (id)cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib {
    NSParameterAssert(tableView);
    NSParameterAssert(nib);
    NSAssert([self defaultTableViewCellNibName] && [[self defaultTableViewCellNibName] length], @"Default table view cell nib name is empty");
    
    NSString * cellIdentifier = [self defaultTableViewCellNibName];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    return cell;
}

#pragma mark Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:[[self class] defaultTableViewCellStyle] reuseIdentifier:reuseIdentifier]) {
        [self finishInitialize];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self finishInitialize];
}

- (void)finishInitialize {
}

#pragma mark STNTableViewCellProtocol

- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    METHOD_MUST_BE_OVERRIDDEN;
}

@end
