#import <objc/Object.h>
#import <time.h>
#import <stdlib.h>
#import <string.h>
#import <stdio.h>
#import "BHTree.h"

#define MAX_VELO (1.75)
#define DAMPING_RADIUS (22.5)
#define THETA (0.75)

#define XMAX (300)
#define XMIN (0)
#define YMAX (300)
#define YMIN (0)

#define MIN_VELO (0.125)
#define STD_VELO (0.05)
#define MIN_MASS (0.05)
#define STD_MASS (0.15)

@interface Simulation:Object
{
  @private
  BHTree_t *tree;
  BHBody_t *bodies;
  int cp;
  int sz;
}

- (id) initWithCapacity:(int)n;
- (void) setUp;
- (void) seedN:(int)n X:(float)x Y:(float)y R:(float)r;
- (void) step;
- (void) tearDown;

@end
