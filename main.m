#import <time.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <signal.h>
#import <objc/Object.h>
#import "src/Simulation.h"
#import "src/Simulation+Render.h"
#import "src/Displayer.h"
#import "src/BHTree.h"

char GLOBAL_RUN_FLAG = 0x01;

void
sigint_handler(int signum)
{
  if (SIGINT == signum) {
    GLOBAL_RUN_FLAG = 0x00;
  }
}

#undef __DEBUG_FLAG__
#ifdef __DEBUG_FLAG__
void
test_display(void)
{
  id d = [[Displayer alloc] init];
  [d setUp];
  [d drawRectX:10 Y:25 W:100 H:215];
  [d writeText:"I did." X:40 Y:50];
  [d drawLineX1:10 Y1:25 X2:110 Y2:240];
  [d drawArcX:75 Y:75 W:100 H:100 from:0*64 to:360*64];
  sleep(5);

  [d clear];
  sleep(2);

  [d tearDown];
  [d free];
}

void
test_bhtree(void)
{
  int i;
  body_t *bs = (body_t *) malloc(N_BODIES * sizeof(body_t));
  memset((void *) bs, 0x00, N_BODIES * sizeof(body_t));

  srand(time(NULL));
  for (i=0; i<N_BODIES; ++i) {
    bs[i].x = 200.0 * ((float) rand()/(float) RAND_MAX - 0.5);
    bs[i].y = 200.0 * ((float) rand()/(float) RAND_MAX - 0.5);
    bs[i].m = (float) rand()/(float) RAND_MAX;
  }
  
  box_t bb;
  bb.xmin=-100; bb.xmax=100;
  bb.ymin=-100; bb.ymax=100;

  BHTree_t *bh = BH_create(&bb);
  body_t tb; tb.x = 0; tb.y = 0; tb.m = 1.0;
  point_t dd;
  for (i=0; i<N_BODIES; ++i) {
    BH_insert(bh, &bs[i]);
    BH_refresh(bh);
    dd = BH_force(bh, &tb, 0.25);
    printf("(%f,%f)\n",dd.x,dd.y);
  }
  
  BH_flush(bh);
  BH_refresh(bh);
  BH_clean(bh);

  free(bs);
}
#endif

int
main(int argc, char **argv)
{
  (void) argc;
  (void) argv;
  signal(SIGINT, &sigint_handler);

  Displayer *d = [[Displayer alloc] init];
  Simulation *s = [[Simulation alloc] initWithCapacity:15];
  [d setUp];
  [s setUp];
  
  if ([s respondsTo:@selector(renderOnDisplay:)])
    ;

  [s seedN:15 X:150 Y:150 R:25];

  while (GLOBAL_RUN_FLAG) {
    [s step];
    [d clear];
    /* [s renderTreeOnDisplay:d]; */
    [s renderOnDisplay:d];
    usleep(1.0e6/30.0);
  }

  [s tearDown];
  [d tearDown];
  [d free];
  [s free];
  return 0;
}
