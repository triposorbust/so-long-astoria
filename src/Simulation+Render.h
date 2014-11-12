#import <objc/Object.h>
#import <stdlib.h>
#import <stdio.h>
#import "Simulation.h"
#import "Displayer.h"

#define POINT_RADIUS (2)

@interface Simulation (Render)

- (void) renderOnDisplay:(Displayer *)d;
- (void) renderTreeOnDisplay:(Displayer *)d;

@end
