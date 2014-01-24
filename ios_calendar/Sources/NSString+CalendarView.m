//
//  NSString+CalendarView.m
//  ios_calendar
//
//  Created by Maxim Bilan on 1/24/14.
//  Copyright (c) 2014 Maxim Bilan. All rights reserved.
//

#import "NSString+CalendarView.h"

#define CALENDAR_VIEW_IS_OS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@implementation NSString (CalendarView)

- (void)drawUsingRect:(CGRect)rect withAttributes:(NSDictionary *)attrs
{
    if (CALENDAR_VIEW_IS_OS_7_OR_LATER) {
        [self drawInRect:rect withAttributes:attrs];
    }
    else {
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self attributes:attrs];
        [attributedString drawInRect:rect];
    }
}

@end
