//
//  ViewController.m
//  ios_calendar
//
//  Created by Maxim Bilan on 1/1/14.
//  Copyright (c) 2014 Maxim Bilan. All rights reserved.
//

#import "ViewController.h"
#import "PopoverViewController.h"
#import "UIPopoverController+iPhone.h"

@interface ViewController ()
{
    PopoverViewController *viewController;
    UIPopoverController *popover;
}

@property (weak, nonatomic) IBOutlet CalendarView *calendarView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverContentController"];
    
    popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
	popover.popoverContentSize = CGSizeMake(300, 320);
	popover.delegate = self;
    
    self.calendarView.calendarDelegate = self;
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

- (IBAction)popoverButtonAction:(UIButton *)sender
{
    [popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

@end
