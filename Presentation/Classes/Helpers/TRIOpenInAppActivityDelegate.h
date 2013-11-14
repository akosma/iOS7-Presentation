//
//  TRIOpenInAppActivityDelegate.h
//  Presentation
//
//  Created by Adrian on 14/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import Foundation;


@class TRIOpenInAppActivity;


@protocol TRIOpenInAppActivityDelegate <NSObject>

@optional

- (void)openInAppActivityWillPresentDocumentInteractionController:(TRIOpenInAppActivity *)activity;

- (void)openInAppActivityDidDismissDocumentInteractionController:(TRIOpenInAppActivity *)activity;

@end
