//
//  DSTViewController.h
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSTViewController : UIViewController

@property (nonatomic, readonly, assign) BOOL appearsFirstTime;
@property (nonatomic, readonly, assign, getter = isViewVisible) BOOL viewVisible;

@end

@interface DSTViewController (DSTSubclassOnly)

- (void)finishInitialize;

@end
