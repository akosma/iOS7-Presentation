//
//  TRIBaseScreenController.h
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import UIKit;


typedef void(^TRIBaseScreenControllerFlashCallback)(void);


@interface TRIBaseScreenController : UIViewController

@property (nonatomic, strong) NSDictionary *definition;
@property (nonatomic) BOOL enableSourceCodeButton;
@property (nonatomic) NSTimeInterval delayForSnapshot;

- (instancetype)initWithDefinition:(NSDictionary *)definition;

- (void)flashAndThen:(TRIBaseScreenControllerFlashCallback)callback;

@end
