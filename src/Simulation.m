#import "Simulation.h"

static
float
stdnorm(void)
{
  float v=0.0;
  int i;
  for (i=0; i<12; ++i) {
    v += (float)rand()/(float)RAND_MAX;
  }
  return v - 6.0;
}

@implementation Simulation

- (id) init
{
  self = [self initWithCapacity:100];
  return self;
}

- (id) initWithCapacity:(int) n
{
  self = [super init];
  if (self) {
    self->cp = n;
    self->sz = 0;
  }
  return self;
}

- (void) setUp
{
  box_t bb; bb.xmin=XMIN; bb.xmax=XMAX; bb.ymin=YMIN; bb.ymax=YMAX;
  self->bodies = (BHBody_t *) malloc(self->cp * sizeof(BHBody_t));
  memset((void*) self->bodies, 0x00, self->cp * sizeof(BHBody_t));
  self->tree = BH_create(&bb);
}

- (void) seedN:(int)n X:(float)x Y:(float)y R:(float)r
{
  int i,j;
  float wt,nrm;
  float dx,dy;
  BHBody_t *b;
  srand(time(NULL));
  for (i=0; i<n; ++i) {
    self->sz = self->sz + 1;
    j = self->sz % self->cp;
    b = &self->bodies[j];

    wt = STD_VELO * stdnorm();
    if (wt < 0)
      wt = -1.0 * wt;
    wt += MIN_VELO;

    b->m = STD_MASS * stdnorm();
    if (b->m < 0)
      b->m *= -1.0;
    b->m += MIN_MASS;
    b->m = exp(b->m);

    b->x = r * stdnorm() + x;
    b->y = r * stdnorm() + y;

    dy = b->y - y;
    dx = b->x - x;
    nrm = sqrt(dx*dx + dy*dy);

    b->dx = -1.0 * (dy / nrm) * wt;
    b->dy =  1.0 * (dx / nrm) * wt;
  }
}

- (void) step
{
  float dx,dy,dst,mgn;
  float damp;
  int i,n = self->sz;
  BHBody_t *b;
  point_t dd;
  BH_flush(self->tree);

  for (i=0; i<n; ++i) {
    b = &self->bodies[i];
    BH_insert(self->tree, b);
  }

  BH_refresh(self->tree);
  for (i=0; i<n; ++i) {
    b = &self->bodies[i];
    dd = BH_force(self->tree, b, THETA);

    dx = b->x - self->tree->x;
    dy = b->y - self->tree->y;
    dst = sqrt(dx*dx + dy*dy);

    damp = pow(2.0, floor(dst / DAMPING_RADIUS));
    if (damp < 1.0) damp = 1.0;

    b->x = b->x + b->dx;
    b->y = b->y + b->dy;
    b->dx = b->dx + dd.x;
    b->dy = b->dy + dd.y;

    mgn = sqrt(b->dx*b->dx + b->dy*b->dy);
    if (mgn > MAX_VELO) {
      b->dx *= MAX_VELO / mgn;
      b->dy *= MAX_VELO / mgn;
    }
  }
}

- (void) tearDown
{
  if (NULL != self->tree) {
    BH_clean(self->tree);
    self->tree = NULL;
  }
  if (NULL != self->bodies) {
    free(self->bodies);
    self->bodies = NULL;
  }
}

- (void) free
{
  [super free];
}

@end
