#ifndef __BHTREE_H__
#include "BHTree.h"
#endif

#define N_BRANCH (4)

typedef enum __DIRECTION_T
  {
    NORTHWEST=0,
    NORTHEAST=1,
    SOUTHWEST=2,
    SOUTHEAST=3
  } direction_t;

static
direction_t
direction(const point_t *mp, const body_t *b)
{
  direction_t ret;
  if (mp->x <= b->x)
    if (mp->y <= b->y)
      ret = SOUTHEAST;
    else
      ret = NORTHEAST;
  else
    if (mp->y <= b->y)
      ret = SOUTHWEST;
    else
      ret = NORTHWEST;
  return ret;
}

static
int
contains(const box_t *bb, const body_t *b)
{
  const int xin = (bb->xmin <= b->x) & (b->x <= bb->xmax);
  const int yin = (bb->ymin <= b->y) & (b->y <= bb->ymax);
  return xin & yin;
}

int
BH_contains(const BHTree_t *t, const BHBody_t *b)
{
  return contains(&t->bb, b);
}

static
node_t *
create_node(const box_t *bb, const node_t *par)
{
  node_t *node = (node_t *) malloc(sizeof(node_t));
  memset((void *) node, 0x00, sizeof(node_t));
  node->leaf = 0x01;

  if (bb)
    memcpy((void *) &(node->bb),
           (const void *) bb,
           sizeof(box_t));
  node->parent = (node_t *) par;

  return node;
}

BHTree_t *
BH_create(const box_t *bb)
{
  return create_node(bb, NULL);
}

static
void
partition(node_t *node)
{
  box_t *bb = &(node->bb);
  const float xmid = (bb->xmax + bb->xmin) / 2.0;
  const float ymid = (bb->ymax + bb->ymin) / 2.0;
  box_t temp;

  temp.xmin = bb->xmin; temp.xmax = xmid; /* WEST  */
  temp.ymin = bb->ymin; temp.ymax = ymid; /* NORTH */
  node->child[NORTHWEST] = create_node(&temp, node);

  temp.ymin = ymid; temp.ymax = bb->ymax; /* SOUTH */
  node->child[SOUTHWEST] = create_node(&temp, node);

  temp.xmin = xmid; temp.xmax = bb->xmax; /* EAST  */
  node->child[SOUTHEAST] = create_node(&temp, node);

  temp.ymin = bb->ymin; temp.ymax = ymid; /* NORTH */
  node->child[NORTHEAST] = create_node(&temp, node);

  node->leaf = 0x00;
  return;
}

static void push_down(node_t *, const body_t *);
static void push_up  (node_t *, const body_t *);

static
void
insert(node_t *node, const body_t *body)
{
  const body_t *temp;

  if (! contains(&node->bb, body)) {
    push_up(node, body);
  } else {
    if (node->leaf) {
      if (NULL == node->body) {
        node->body = body;
      } else {
        temp = node->body;
        node->body = NULL;
        partition(node);
        
        push_down(node, temp);
        push_down(node, body);
      }
    } else {
      push_down(node, body);
    }
  }
}

static
void
push_down(node_t *node, const body_t *body)
{
  direction_t dir;
  point_t mid;
  mid.x = (node->bb.xmax + node->bb.xmin) / 2.0;
  mid.y = (node->bb.ymax + node->bb.ymin) / 2.0;

  dir = direction(&mid, body);
  if (node->child[dir]) {
    insert(node->child[dir], body);
  }
}

static
void
push_up(node_t *node, const body_t *body)
{
  if (node->parent) {
    insert(node->parent, body);
  }
}

void
BH_insert(BHTree_t *node, const BHBody_t *body)
{
  insert(node, body);
}

void
BH_clean(BHTree_t *node)
{
  int i;
  if (node) {
    if (! node->leaf)
      for (i=0; i<N_BRANCH; ++i)
        BH_clean(node->child[i]);
    free(node);
  }
}

void
BH_flush(BHTree_t *node)
{
  int i;
  if (node->leaf) {
    node->body = NULL;
  } else {
    for (i=0; i<N_BRANCH; ++i)
      BH_flush(node->child[i]);

    node->x = 0.0;
    node->y = 0.0;
    node->m = 0.0;
  }
}

void
BH_refresh(BHTree_t *node)
{
  float sm = 0.0;
  float wt;
  int i;

  if (node->leaf) {
    if (node->body) {
      node->x = node->body->x;
      node->y = node->body->y;
      node->m = node->body->m;
    }
  } else {
    for (i=0; i<N_BRANCH; ++i) {
      BH_refresh(node->child[i]);
      sm += node->child[i]->m;
    }

    if (sm > 0.0) {
      for (i=0; i<N_BRANCH; ++i) {
        wt = node->child[i]->m / sm;
        node->x += wt * node->child[i]->x;
        node->y += wt * node->child[i]->y;
      }
    }
    node->m = sm;
  }
}

static
float
distance(const point_t *p, const body_t *b)
{
  const float dx = p->x - b->x;
  const float dy = p->y - b->y;
  return sqrt(dx*dx + dy*dy);
}

point_t
BH_force(const BHTree_t *node, const BHBody_t *body, const float theta)
{
  point_t dd,cm,temp;
  const box_t *bb = &node->bb;
  float dim = ((bb->xmax-bb->xmin) + (bb->ymax-bb->ymin)) / 2.0;
  float dst,mgn;
  int i;

  cm.x = node->x;
  cm.y = node->y;
  dd.x = 0.0;
  dd.y = 0.0;

  dst = distance(&cm, body);
  if (dst == 0.0) dst = FLT_EPSILON;
  if (dst/dim >= theta || (node->leaf && NULL != node->body)) {
    mgn = G_CONSTANT * (body->m * node->m) / (dst*dst);
    dd.x = (mgn/(dst * body->m)) * (cm.x - body->x);
    dd.y = (mgn/(dst * body->m)) * (cm.y - body->y);
  } else if (0x00 == node->leaf) {
    for (i=0; i<N_BRANCH; ++i) {
      temp = BH_force(node->child[i], body, theta);
      dd.x += temp.x;
      dd.y += temp.y;
    }
  }

  return dd;
}
