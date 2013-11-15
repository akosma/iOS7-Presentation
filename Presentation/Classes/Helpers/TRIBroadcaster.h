//
//  TRIBroadcaster.h
//  Presentation
//
//  Created by Adrian on 7/5/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;


#import "TRIBroadcasterDelegate.h"


@interface TRIBroadcaster : NSObject

@property (nonatomic, weak) id<TRIBroadcasterDelegate> delegate;

- (instancetype)initWithCharacteristic:(CBUUID *)characteristicID
                               service:(CBUUID *)serviceID;

- (void)startAdvertising;
- (void)stopAdvertising;
- (void)send:(NSString *)string;

@end
