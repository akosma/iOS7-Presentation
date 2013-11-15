//
//  TRIPDFHelper.h
//  Presentation
//
//  Created by Adrian on 15/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import Foundation;
@import CoreText;

@interface TRIPDFHelper : NSObject

- (instancetype)initWithFiles:(NSArray *)files
                       bounds:(CGRect)bounds
                  orientation:(UIInterfaceOrientation)orientation;

- (void)generatePDFWithPath:(NSString *)path;

@end
