#import "Simulation+Render.h"

#define N_BRANCH (4)

@implementation Simulation (Render)

- (void) renderTree:(BHTree_t *)node onDisplay:(Displayer *)d
{
  int i;
  if (! node->leaf)
    for (i=0; i<N_BRANCH; ++i)
      [self renderTree:node->child[i] onDisplay:d];

  box_t bb = node->bb;
  [d drawLineX1:bb.xmin Y1:bb.ymin X2:bb.xmax Y2:bb.ymin];
  [d drawLineX1:bb.xmin Y1:bb.ymax X2:bb.xmax Y2:bb.ymax];
  [d drawLineX1:bb.xmin Y1:bb.ymin X2:bb.xmin Y2:bb.ymax];
  [d drawLineX1:bb.xmax Y1:bb.ymin X2:bb.xmax Y2:bb.ymax];
}

- (void) renderOnDisplay:(Displayer *)d
{
  BHBody_t *b;
  int i,n=self->sz;
  for (i=0; i<n; ++i) {
    b = &self->bodies[i];
    [d drawArcX:b->x
              Y:b->y
              W:POINT_RADIUS
              H:POINT_RADIUS
           from:0*64
             to:360*64];
    [d drawLineX1:b->x
               Y1:b->y
               X2:b->x - 5*b->dx
               Y2:b->y - 5*b->dy];
  }
}

- (void) renderTreeOnDisplay:(Displayer *)d
{
  if (self->tree) {
    [self renderTree:self->tree onDisplay:d];
  }
}

@end
