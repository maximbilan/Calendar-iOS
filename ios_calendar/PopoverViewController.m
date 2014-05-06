//
//  PopoverViewController.m
//  ios_calendar
//
//  Created by Maxim Bilan on 1/21/14.
//  Copyright (c) 2014 Maxim Bilan. All rights reserved.
//

#import "PopoverViewController.h"

@interface PopoverViewController ()

@property (weak, nonatomic) IBOutlet CalendarView *calendarView;

@end

@implementation PopoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.calendarView.calendarDelegate = self;
    
    // Custom colors
    self.calendarView.selectionColor = [UIColor colorWithRed:0.203 green:0.666 blue:0.862 alpha:1.000];
    self.calendarView.fontHeaderColor = [UIColor colorWithRed:0.203 green:0.666 blue:0.862 alpha:1.000];
}

- (void)didChangeCalendarDate:(NSDate *)date
{
    NSLog(@"didChangeCalendarDate:%@", date);
}

- (void)didChangeCalendarDate:(NSDate *)date withType:(NSInteger)type withEvent:(NSInteger)event
{
    NSLog(@"didChangeCalendarDate:%@ withType:%ld withEvent:%ld", date, (long)type, (long)event);
}

- (void)didDoubleTapCalendar:(NSDate *)date withType:(NSInteger)type
{
    NSLog(@"didDoubleTapCalendar:%@ withType:%ld", date, (long)type);
}

@end
