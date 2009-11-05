#include "divinity_ext.h"

void divinity_init_opengl()
{
    rb_define_module("OpenGl");

    divinity_init_opengl_frustum();
    divinity_init_opengl_octree();
}
