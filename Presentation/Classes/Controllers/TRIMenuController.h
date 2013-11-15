//
//  TRIMenuController.h
//  Presentation
//
//  Created by Adrian on 15/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import UIKit;

#import "TRIMenuControllerDelegate.h"

@interface TRIMenuController : UITableViewController

@property (nonatomic, weak) id<TRIMenuControllerDelegate> delegate;

- (id)initWithDefinitions:(NSArray *)definitions;

@end
