iOS Calendar
============

[![Version](https://img.shields.io/cocoapods/v/Calendar-iOS.svg?style=flat)](http://cocoadocs.org/docsets/Calendar-iOS)
[![License](https://img.shields.io/cocoapods/l/Calendar-iOS.svg?style=flat)](http://cocoadocs.org/docsets/Calendar-iOS)
[![Platform](https://img.shields.io/cocoapods/p/Calendar-iOS.svg?style=flat)](http://cocoadocs.org/docsets/Calendar-iOS)

It's lightweight and simple control. There're samples for iphone and ipad, and also with using popover.<br>
![alt tag](https://raw.github.com/maximbilan/ios_calendar/master/img/img4.png)
<br>
Using popover:
<br><br>
![alt tag](https://raw.github.com/maximbilan/ios_calendar/master/img/img5.png)
<br>
## Installation:
<b>Manual:</b><br><br>
Add to your project the next source files: <br>
<pre>
CalendarView.h
CalendarView.m
NSDate+CalendarView.h
NSDate+CalendarView.m
</pre>
<b>Cocoapods:</b>
<pre>
pod 'Calendar-iOS'
</pre>
## How to use:
You can add view in the Interface builder and set class to CalendarView or create in the code: <br>
<pre>
CalendarView *cv = [[CalendarView alloc] initWithPosition:10.0 y:10.0];
[self.view addSubview:cv];
</pre>
So, it's all, you should see the calendar view. <br>
This component was created for iphone/ipod resolution, for ipad it's works, but it looks really small, if it's necessary, you can playing with static constants in the CalendarView.m, and maybe in future, will be done the scaling.
<br>
This calendar has some modes: <br>
<pre>
typedef NS_ENUM(NSInteger, CalendarMode)
{
    CalendarModeDefault,
    CalendarModeMonthsAndYears,
    CalendarModeYears
};
</pre>
<i>Default</i> - there're days, months and years, the user can change monthes with help swipe gesture or pinch gesture for transitions in the calendar <br>
<i>MonthsAndYears</i> - available months and years <br>
<i>Years</i> - only years <br>
## How to handle changing date event:
For this you should use CalendarViewDelegate protocol:
<pre>
@interface ViewController : UIViewController &#60;CalendarViewDelegate&#62;

@end
</pre>
And setup delegate: <br>
<pre>
self.calendarView.calendarDelegate = self;
</pre>

After that you should implement required method didChangeCalendarDate:
<pre>
- (void)didChangeCalendarDate:(NSDate *)date
{
    NSLog(@"didChangeCalendarDate:%@", date);
}
</pre>

For more details there're optional methods for other things: <br>
<pre>
@optional
- (void)didChangeCalendarDate:(NSDate *)date withType:(NSInteger)type withEvent:(NSInteger)event;
- (void)didDoubleTapCalendar:(NSDate *)date withType:(NSInteger)type;
</pre>
## How to customize colors:
For customization of colors you can use the following properties:
<pre>
// Main color of numbers
@property (nonatomic, strong) UIColor *fontColor;
// Color of the headers (Year and month)
@property (nonatomic, strong) UIColor *fontHeaderColor;
// Color of selected numbers
@property (nonatomic, strong) UIColor *fontSelectedColor;
// Color of selection
@property (nonatomic, strong) UIColor *selectionColor;
</pre>
For example:
<pre>
self.calendarView.selectionColor = [UIColor colorWithRed:0.203 green:0.666 blue:0.862 alpha:1.000];
self.calendarView.fontHeaderColor = [UIColor colorWithRed:0.203 green:0.666 blue:0.862 alpha:1.000];
</pre>
And you can see the result:<br>
![alt tag](https://raw.github.com/maximbilan/ios_calendar/master/img/img6.png)<br>
It's free for using, feel free. And I hope it will be helpful.<br>

## License

iOS Calendar is available under the MIT license. See the LICENSE file for more info.
