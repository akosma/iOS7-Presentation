//
//  TRIReceiver.h
//  Presentation
//
//  Created by Adrian on 7/5/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

#import "TRIReceiverDelegate.h"

@interface TRIReceiver : NSObject

- (instancetype)initWithCharacteristic:(CBUUID *)characteristicID
                               service:(CBUUID *)serviceID;

@property (nonatomic, weak) id<TRIReceiverDelegate> delegate;

@end
