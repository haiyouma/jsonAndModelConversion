//
//  NSObject+JsonStr.h
//  QiTalk
//
//  Created by 程建良 on 2017/6/23.
//  Copyright © 2017年 keylert.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JsonStr)

-(NSString*)getJsonStr;

-(instancetype)initWithDictionary:(NSDictionary*)dict;

@end
