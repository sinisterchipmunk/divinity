#ifndef DIVINITY_H
#define DIVINITY_H

#include "ruby.h"
#include "gl/gl.h"
#include "divinity_macros.h"

extern VALUE rb_cVertex3d;
extern VALUE rb_cVector3d;

extern void divinity_init_opengl();
extern void divinity_init_opengl_frustum();
extern void divinity_init_opengl_octree();
extern void divinity_init_opengl_octree_object_descriptor();
extern void divinity_init_vertex3d();
extern void divinity_init_render_helper();
extern void divinity_init_array();

extern void get_plane_values(VALUE plane, double *a, double *b, double *c, double *d);
extern void set_plane_values(VALUE plane, double a, double b, double c, double d);
extern void get_vertex_values(VALUE vertex, double *x, double *y, double *z);
extern void set_vertex_values(VALUE vertex, double x, double y, double z);

#endif//DIVINITY_H
