//
//  NSObject+JsonStr.m
//  QiTalk
//
//  Created by 程建良 on 2017/6/23.
//  Copyright © 2017年 keylert.com. All rights reserved.
//

#import "NSObject+JsonStr.h"
#import <objc/runtime.h>
#import "NSString+JS.h"

@implementation NSObject (JsonStr)

const void *kPropertyList = @"kPropertyList";

- (NSArray *)getPropertyList {
    
    //尝试获取属性数组
    NSArray *kList = objc_getAssociatedObject(self, kPropertyList);
    if (kList != nil) {
        return kList;
    }
    
    unsigned int outCount = 0;
    //You must free the array with free().
    objc_property_t *propertyList  = class_copyPropertyList([self class], &outCount);
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < outCount; i++) {
        const char * cName = property_getName(propertyList[i]);
        //c --> oc string
        NSString *name = [NSString stringWithUTF8String:cName];
        [array addObject:name];
    }
    free(propertyList);
    
    //关联对象 记录属性数组
    objc_setAssociatedObject(self, kPropertyList, array.copy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return array.copy;
}


-(NSString*)getJsonStr{
    
    unsigned int outCount = 0;
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    Ivar * ivars = class_copyIvarList([self class], &outCount);
    NSArray *propertyList = [self getPropertyList];
    for (unsigned int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString *key = propertyList[i];
        id value = object_getIvar(self, ivar);
        if ([value isKindOfClass:[NSObject class]]) {
            
            if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
                
                NSError *error;
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:&error];
                NSString *str = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                [mDic setValue:str forKey:key];
                
                continue;
            }
            
            
            if (!([value isKindOfClass:[NSString class]]||[value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]])) {
                
                NSString *str = [value getJsonStr];
                
                [mDic setValue:str forKey:key];
                
                continue;
            }
            
            [mDic setValue:value forKey:key];
            
        }else{
            
            [mDic setValue:value forKey:key];
            
        }

    }
    
    free(ivars);
    
    
    NSError *error;
    
    NSData *totalJsonData = [NSJSONSerialization dataWithJSONObject:mDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc]initWithData:totalJsonData encoding:NSUTF8StringEncoding];
    jsonStr = [jsonStr replaceAll:@" " replacement:@""];
    jsonStr = [jsonStr replaceAll:@"\n" replacement:@""];
    return jsonStr;
}

-(instancetype)initWithDictionary:(NSDictionary*)dict{
    if (self = [self init]) {
        NSArray *keys = [self getPropertyList];
        for (NSString * key in keys) {
            if ([dict valueForKey:key] == nil) continue;
            [self setValue:[dict valueForKey:key]forKey:key];
        }
    }
    return self;
}


@end
