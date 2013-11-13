//
//  TRIBaseScreenController.h
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import UIKit;


@interface TRIBaseScreenController : UIViewController

@property (nonatomic, strong) NSDictionary *definition;

- (instancetype)initWithDefinition:(NSDictionary *)definition;

@end
