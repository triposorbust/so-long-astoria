#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <X11/Xlib.h>
#import <X11/Xutil.h>
#import <X11/Xos.h>
#import <objc/Object.h>

@interface Displayer : Object
{
  @private
  Display *dis;
  Window win;
  GC gc;
  int screen;
}

- (void) setUp;
- (void) drawLineX1:(int)x1 Y1:(int)y1 X2:(int)x2 Y2:(int)y2;
- (void) writeText:(const char *)str X:(int)x Y:(int)y;
- (void) drawRectX:(int)x Y:(int)y W:(int)w H:(int)h;
- (void) drawArcX:(int)x Y:(int)y W:(int)w H:(int)h from:(int)r0 to:(int)r1;
- (void) clear;
- (void) tearDown;

@end
