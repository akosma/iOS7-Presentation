//
//  TRIBroadcaster.h
//  Presentation
//
//  Created by Adrian on 7/5/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;


@interface TRIBroadcaster : NSObject

+ (TRIBroadcaster *)broadcaster;

- (void)send:(NSString *)string;
- (void)sendReset;
- (void)sendNext;
- (void)sendPrevious;
- (void)sendShowSource;
- (void)sendHideSource;
- (void)sendToggleMenu;

- (void)startAdvertising;
- (void)stopAdvertising;

@end
