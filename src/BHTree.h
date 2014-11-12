#ifndef __BHTREE_H__
#define __BHTREE_H__

#ifndef __STDLIB_H__
#define __STDLIB_H__
#include <stdlib.h>
#endif

#ifndef __STDIO_H__
#define __STDIO_H__
#include <stdio.h>
#endif

#ifndef __XMATH_H__
#define __XMATH_H__
#include <math.h>
#endif

#ifndef __FLOAT_H__
#define __FLOAT_H__
#include <float.h>
#endif

#ifndef __STRING_H__
#define __STRING_H__
#include <string.h>
#endif

#define G_CONSTANT (0.0025)

typedef struct __BODY_T {
  float x,dx;
  float y,dy;
  float m;
} body_t;

typedef struct __POINT_T {
  float x,y;
} point_t;

typedef struct __BOX_T {
  float
    xmin,
    xmax,
    ymin,
    ymax;
} box_t;

typedef struct __BH_NODE_T {
  struct __BH_NODE_T *child[4];
  struct __BH_NODE_T *parent;
  box_t bb;

  char leaf;
  const body_t *body;

  float x;
  float y;
  float m;  
} node_t;

typedef node_t BHTree_t;
typedef body_t BHBody_t;

BHTree_t *BH_create(const box_t *);
void BH_insert(BHTree_t *, const BHBody_t *);
int BH_contains(const BHTree_t *, const BHBody_t *);
point_t BH_force(const BHTree_t *, const BHBody_t *, const float);
void BH_flush(BHTree_t *);
void BH_refresh(BHTree_t *);
void BH_clean(BHTree_t *);

#endif
