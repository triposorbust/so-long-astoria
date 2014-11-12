#import "Displayer.h"

@interface Displayer ()

@property Display *dis;
@property Window   win;
@property GC        gc;
@property int   screen;

@end

@implementation Displayer

@synthesize dis;
@synthesize win;
@synthesize gc;
@synthesize screen;

- (id) init
{
  self = [super init];
  if (self) {
    [self setDis:XOpenDisplay(NULL)];
    [self setScreen:DefaultScreen([self dis])];
    [self setWin:
            XCreateSimpleWindow([self dis],
                                RootWindow([self dis], [self screen]),
                                0, 0, 300, 300, 0,
                                BlackPixel([self dis], [self screen]),
                                WhitePixel([self dis], [self screen]))];

    XSetStandardProperties([self dis], [self win],
                           "Forager", "F.",
                           0L, NULL, 0, NULL);

    XSelectInput([self dis], [self win], StructureNotifyMask | ExposureMask);
    [self setGc:XCreateGC([self dis], [self win], 0, 0)];

    XSetBackground([self dis], [self gc], WhitePixel([self dis], [self screen]));
    XSetForeground([self dis], [self gc], BlackPixel([self dis], [self screen]));
  }
  return self;
}

- (void) setUp
{
  XEvent e;
  XClearWindow([self dis], [self win]);
  XMapRaised([self dis], [self win]);

  while (1) {
    XNextEvent([self dis], &e);
    if (e.type == MapNotify)
      break;
  }
  XFlush([self dis]);
}

- (void) drawArcX:(int)x Y:(int)y W:(int)w H:(int)h from:(int)r0 to:(int)r1
{
  XDrawArc([self dis], [self win], [self gc], x, y, w, h, r0, r1);
  XFlush([self dis]);
}

- (void) clear
{
  XClearWindow([self dis], [self win]);
  XFlush([self dis]);
}

- (void) drawRectX:(int)x Y:(int)y W:(int)w H:(int)h
{
  XDrawRectangle([self dis], [self win], [self gc], x, y, w, h);
  XFlush([self dis]);
}

- (void) drawLineX1:(int)x1 Y1:(int)y1 X2:(int)x2 Y2:(int)y2
{
  XDrawLine([self dis], [self win], [self gc], x1, y1, x2, y2);
  XFlush([self dis]);
}

- (void) writeText:(const char *)str X:(int)x Y:(int)y
{
  XDrawString([self dis], [self win], [self gc], x, y, str, strlen(str));
  XFlush([self dis]);
}

- (void) tearDown
{
  XFreeGC([self dis], [self gc]);
  XDestroyWindow([self dis], [self win]);
  XCloseDisplay([self dis]);
}

@end
