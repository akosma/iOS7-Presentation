//
//  TRIReceiverDelegate.h
//  Lego
//
//  Created by Adrian on 7/5/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import Foundation;

@class TRIReceiver;


@protocol TRIReceiverDelegate <NSObject>

@optional

- (void)receiver:(TRIReceiver *)receiver didReceiveMessage:(NSString *)message;
- (void)receiver:(TRIReceiver *)receiver didReceiveData:(NSData *)data;

@end
