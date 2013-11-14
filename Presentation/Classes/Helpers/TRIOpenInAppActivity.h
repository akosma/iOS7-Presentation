//
//  TRIOpenInAppActivity.h
//  Presentation
//
//  Created by Adrian on 14/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//
//  Adapted from TTOpenInAppActivity
//  https://github.com/honkmaster/TTOpenInAppActivity
//
//  Created by Tobias Tiemerding on 12/25/12.
//  Copyright (c) 2012-2013 Tobias Tiemerding
//

@import UIKit;
@import MobileCoreServices;

#import "TRIOpenInAppActivityDelegate.h"

@interface TRIOpenInAppActivity : UIActivity <UIDocumentInteractionControllerDelegate>

@property (nonatomic, weak) id superViewController;
@property (nonatomic, weak) id<TRIOpenInAppActivityDelegate> delegate;

- (id)initWithView:(UIView *)view andRect:(CGRect)rect;
- (id)initWithView:(UIView *)view andBarButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)dismissDocumentInteractionControllerAnimated:(BOOL)animated;

@end
