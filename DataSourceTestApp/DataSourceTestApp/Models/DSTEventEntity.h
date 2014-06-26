//
//  DSTEventEntity.h
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "DSTManagedObject.h"

@interface DSTEventEntity : DSTManagedObject

@property (nonatomic, readwrite, strong) NSDate * timestamp;

@end
