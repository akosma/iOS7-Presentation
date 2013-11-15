//
//  TRIMenuControllerDelegate.h
//  Presentation
//
//  Created by Adrian on 15/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import Foundation;

@class TRIMenuController;

@protocol TRIMenuControllerDelegate <NSObject>

@optional

- (void)menuController:(TRIMenuController *)menuController didSelectItemAtIndex:(NSInteger)index;

@end
