//
//  MenuItemWithDict.h
//  Captured
//
//  Created by Christopher Sexton on 3/17/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MenuItemWithDict : NSMenuItem {
    NSDictionary *dict;
@private
    
}
@property (retain) NSDictionary *dict;


@end
