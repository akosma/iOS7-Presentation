//
//  TRIBroadcasterDelegate.h
//  Presentation
//
//  Created by Adrian on 15/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import Foundation;

@class TRIBroadcaster;



@protocol TRIBroadcasterDelegate <NSObject>

@optional

- (void)broadcasterIsReady:(TRIBroadcaster *)broadcaster;

@end
