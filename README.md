iOS Calendar
============

[![Version](https://img.shields.io/cocoapods/v/Calendar-iOS.svg?style=flat)](http://cocoadocs.org/docsets/Calendar-iOS)
[![License](https://img.shields.io/cocoapods/l/Calendar-iOS.svg?style=flat)](http://cocoadocs.org/docsets/Calendar-iOS)
[![Platform](https://img.shields.io/cocoapods/p/Calendar-iOS.svg?style=flat)](http://cocoadocs.org/docsets/Calendar-iOS)
[![CocoaPods](https://img.shields.io/cocoapods/dt/Calendar-iOS.svg)](https://cocoapods.org/pods/Calendar-iOS)
[![CocoaPods](https://img.shields.io/cocoapods/dm/Calendar-iOS.svg)](https://cocoapods.org/pods/Calendar-iOS)

It's lightweight and simple control with supporting <i>Locale</i> and <i>CalendarIdentifier</i>. There're samples for iPhone and iPad, and also with using a popover.<br>
![alt tag](https://raw.github.com/maximbilan/ios_calendar/master/img/img4.png)
![alt tag](http://uupload.ir/files/71zl_img10.png)
<br>
Using popover:
<br><br>
![alt tag](https://raw.github.com/maximbilan/ios_calendar/master/img/img5.png)
<br>
## How to install
<b>Manual:</b><br><br>
Add to your project the next source files: <br>
<pre>
CalendarView.h
CalendarView.m
NSDate+CalendarView.h
NSDate+CalendarView.m
NSString+CalendarView.h
NSString+CalendarView.m
</pre>
<b>CocoaPods:</b>
<pre>
pod 'Calendar-iOS'
</pre>
## How to use
You can add view in the Interface Builder and set class to <i>CalendarView</i> or create in the code: <br>
<pre>
CalendarView *calendarView = [[CalendarView alloc] initWithPosition:10.0 y:10.0];
[self.view addSubview:calendarView];
</pre>
So, it's all, you should see the calendar view. <br>
This component was created for iPhone/iPod resolution, for iPad its works, but it looks really small, if it's necessary, you can play with static constants in the <i>CalendarView.m</i>, and maybe in future, will be done the scaling.
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
<i>Default</i> - there're days, months and years, the user can change months with help swipe gesture or pinch gesture for transitions in the calendar <br>
<i>MonthsAndYears</i> - available months and years <br>
<i>Years</i> - only years <br>
<br>
There are external methods to mimic the swiping behavior in case a different UI is desired. However, these events will be logged with a different event type than swiping. <br>
<br>
There are also some options for display: <br>
<pre>
// Whether the currently selected date should be marked
@property (nonatomic, assign) BOOL shouldMarkSelectedDate;
// Whether today's date should be marked
@property (nonatomic, assign) BOOL shouldMarkToday;
// Whether the month and year headers should be shown
@property (nonatomic, assign) BOOL shouldShowHeaders;
// Preferred weekday start
- (void)setPreferredWeekStartIndex:(NSInteger)index;
</pre>
<i>Date Markers</i> - Default behavior is to mark the currently selected date and not today, but this can be customized to suit your needs. If both are marked and coincide on the same day, it will show up with the current selection color, not today's color.<br>
<i>Headers</i> - Default behavior is to show the headers, but they can also be hidden, in which case everything else will get shifted up accordingly (after a set needs display call). <br>
<i>Preferred Week Start</i> - Default behavior behavior is Monday. Determines what day of the week is in the leftmost column.
## How to use Locale and CalendarIdentifier
It's very simple and useful to create calendar base on your locale and of course your country. 
<pre>
NSLocale *persianLocale = [NSLocale alloc]initWithLocaleIdentifier:@"fa-IR"];
[self.calendarView setLocale:persianLocale];
</pre>
And for using <i>CalendarIdentifier</i> use this property :
<pre>
[self.calendarView setCalendarIdentifier:NSCalendarIdentifierPersian];
</pre>
if you set <i>useVeryShortWeekdaySymbols property</i> to `YES`, use days of week name very short

<pre>
self.calendarView.useVeryShortWeekdaySymbols = YES;
</pre>

## How to select range of date
![English range selection](https://raw.githubusercontent.com/Husseinhj/ios_calendar/feat/range_selection/img/@2x-English%20selection.png)
![Persian range selection](https://raw.githubusercontent.com/Husseinhj/ios_calendar/feat/range_selection/img/@2x-Persian%20selection.png)
If user Long press on items, can select date and for select end of range, Long press on end date.
For get range date use `didSelectRangeForStartDate:endDate` delegate method like this :
<pre>
- (void) didSelectRangeForStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate{ 
    NSLog(@"%s: start date :%@ \n end date : %@",__PRETTY_FUNCTION__,startDate,endDate); 
} 
</pre>

## How to handle changing date event
For this you should use <i>CalendarViewDelegate</i> protocol:
<pre>
@interface ViewController : UIViewController &#60;CalendarViewDelegate&#62;

@end
</pre>
And setup delegate: <br>
<pre>
self.calendarView.calendarDelegate = self;
</pre>

After that you should implement required method <i>didChangeCalendarDate</i>:
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
## How to customize colors
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
// Color of today
@property (nonatomic, strong) UIColor *todayColor;
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
