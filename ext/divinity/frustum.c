#include "divinity.h"

VALUE rb_cFrustum = Qnil;

static VALUE rb_fUpdate(VALUE self);
static VALUE rb_fCubeVisible(VALUE self, VALUE c);
static VALUE rb_fPolyVisible(VALUE self, VALUE verts);
static VALUE rb_fSphereVisible(VALUE self, VALUE vradius, VALUE vx, VALUE vy, VALUE vz);
static VALUE rb_fPointVisible(VALUE self, VALUE vx, VALUE vy, VALUE vz);

void divinity_init_opengl_frustum()
{
    VALUE rb_mOpenGl = rb_const_get(rb_cObject, rb_intern("OpenGl"));

    rb_cFrustum = rb_define_class_under(rb_mOpenGl, "Frustum", rb_cObject);

    rb_define_method(rb_cFrustum, "update!", rb_fUpdate, 0);
    rb_define_method(rb_cFrustum, "__cube_visible?", rb_fCubeVisible, 1);
    rb_define_method(rb_cFrustum, "__poly_visible?", rb_fPolyVisible, -2);
    rb_define_method(rb_cFrustum, "__sphere_visible?", rb_fSphereVisible, 4);
    rb_define_method(rb_cFrustum, "__point_visible?", rb_fPointVisible, 4);
}

static VALUE rb_fPointVisible(VALUE self, VALUE vx, VALUE vy, VALUE vz)
{
    double x = NUM2DBL(vx), y = NUM2DBL(vy), z = NUM2DBL(vz);
    double a, b, c, d;
    long i;
    struct RArray *planes = RARRAY(CALL_GETTER(CALL_GETTER(self, "planes"), "values"));

    for (i = 0; i < planes->len; i++)
    {
        get_plane_values(*(planes->ptr+i), &a, &b, &c, &d);
        if (a*x + b*y + c*z + d <= 0) return Qfalse;
    }
    return Qtrue;
}

static VALUE rb_fSphereVisible(VALUE self, VALUE vradius, VALUE vx, VALUE vy, VALUE vz)
{
    double radius = NUM2DBL(vradius), x = NUM2DBL(vx), y = NUM2DBL(vy), z = NUM2DBL(vz), dx;
    double a, b, c, d;
    int cx = 0;
    long i;
    struct RArray *planes = RARRAY(CALL_GETTER(CALL_GETTER(self, "planes"), "values"));

    for (i = 0; i < planes->len; i++)
    {
        get_plane_values(*(planes->ptr+i), &a, &b, &c, &d);
        if ((dx = a*x + b*y + c*z + d) <= -radius) return Qfalse;
        if (dx > radius) cx += 1;
    }

    if (cx == 6) return Qtrue;
    return ID2SYM(rb_intern("partial"));    
}

static VALUE rb_fPolyVisible(VALUE self, VALUE verts)
{
    struct RArray *vertices = RARRAY(verts);
    struct RArray *planes = RARRAY(CALL_GETTER(CALL_GETTER(self, "planes"), "values"));
    double a, b, c, d, x, y, z;
    int n;
    long i, j;

    for (i = 0; i < planes->len; i++)
    {
        n = 0;
        get_plane_values(*(planes->ptr+i), &a, &b, &c, &d);
        for (j = 0; j < vertices->len; j++)
        {
            get_vertex_values(*(vertices->ptr+j), &x, &y, &z);
            if (a * x + b * y + c * z + d > 0) { n += 1; break; }
        }
        if (n == 0) return Qfalse;
    }
    return Qtrue;
}

static VALUE rb_fCubeVisible(VALUE self, VALUE corns)
{
    struct RArray *corners = RARRAY(corns);
    struct RArray *planes = RARRAY(CALL_GETTER(CALL_GETTER(self, "planes"), "values"));
    int within = 0, n;
    long i, j;
    double x, y, z, a, b, c, d;
    //for each plane in the frustum...
    for (i = 0; i < planes->len; i++)
    {
        // ... test each corner of the bounding box, incrementing c if it's in the frustum
        n = 0;
        get_plane_values(*(planes->ptr+i), &a, &b, &c, &d);
        for (j = 0; j < corners->len; j++)
        {
            get_vertex_values(*(corners->ptr+j), &x, &y, &z);
            if (a * x + b * y + c * z + d > 0) n += 1;
        }
        if (n == 0) return Qfalse;
        if (n == corners->len) within += 1;
    }
    if (within == planes->len) //box is completely inside frustum
        return Qtrue;
    return ID2SYM(rb_intern("partial")); // box is partially inside frustum
}

/* Updating the Frustum is EXPENSIVE and should only be done when necessary -- but must be done
   every time the matrix changes! (When the camera is moved, rotated, or whatever.) */
static VALUE rb_fUpdate(VALUE self)
{
    double proj[16], modl[16], clip[16];
    glGetDoublev(GL_PROJECTION_MATRIX, proj);
    glGetDoublev(GL_MODELVIEW_MATRIX, modl);
    VALUE right  = CALL_GETTER(self, "right"),  left = CALL_GETTER(self, "left"),
          bottom = CALL_GETTER(self, "bottom"), top  = CALL_GETTER(self, "top"),
         _far    = CALL_GETTER(self, "far"),    _near = CALL_GETTER(self, "near");

    /*
    ## Brutally ripped from my old C++ code, then reformatted to match the new Ruby classes. Math hasn't changed.
    # I'm not huge on math, and TBH I don't really have a firm understanding of what's happening here. Somehow,
    # we are waving a magic wand and extracting the 6 planes which will represent the edges of the
    # camera's viewable area. I'll let someone who's familiar with matrices explain how that happens.
    # In any case, it works, and I have a lot of other things to do, so I just copy and paste it from
    # one 3D app to the next.
    */

    clip[ 0] = modl[ 0] * proj[ 0] + modl[ 1] * proj[ 4] + modl[ 2] * proj[ 8] + modl[ 3] * proj[12];
    clip[ 1] = modl[ 0] * proj[ 1] + modl[ 1] * proj[ 5] + modl[ 2] * proj[ 9] + modl[ 3] * proj[13];
    clip[ 2] = modl[ 0] * proj[ 2] + modl[ 1] * proj[ 6] + modl[ 2] * proj[10] + modl[ 3] * proj[14];
    clip[ 3] = modl[ 0] * proj[ 3] + modl[ 1] * proj[ 7] + modl[ 2] * proj[11] + modl[ 3] * proj[15];

    clip[ 4] = modl[ 4] * proj[ 0] + modl[ 5] * proj[ 4] + modl[ 6] * proj[ 8] + modl[ 7] * proj[12];
    clip[ 5] = modl[ 4] * proj[ 1] + modl[ 5] * proj[ 5] + modl[ 6] * proj[ 9] + modl[ 7] * proj[13];
    clip[ 6] = modl[ 4] * proj[ 2] + modl[ 5] * proj[ 6] + modl[ 6] * proj[10] + modl[ 7] * proj[14];
    clip[ 7] = modl[ 4] * proj[ 3] + modl[ 5] * proj[ 7] + modl[ 6] * proj[11] + modl[ 7] * proj[15];

    clip[ 8] = modl[ 8] * proj[ 0] + modl[ 9] * proj[ 4] + modl[10] * proj[ 8] + modl[11] * proj[12];
    clip[ 9] = modl[ 8] * proj[ 1] + modl[ 9] * proj[ 5] + modl[10] * proj[ 9] + modl[11] * proj[13];
    clip[10] = modl[ 8] * proj[ 2] + modl[ 9] * proj[ 6] + modl[10] * proj[10] + modl[11] * proj[14];
    clip[11] = modl[ 8] * proj[ 3] + modl[ 9] * proj[ 7] + modl[10] * proj[11] + modl[11] * proj[15];

    clip[12] = modl[12] * proj[ 0] + modl[13] * proj[ 4] + modl[14] * proj[ 8] + modl[15] * proj[12];
    clip[13] = modl[12] * proj[ 1] + modl[13] * proj[ 5] + modl[14] * proj[ 9] + modl[15] * proj[13];
    clip[14] = modl[12] * proj[ 2] + modl[13] * proj[ 6] + modl[14] * proj[10] + modl[15] * proj[14];
    clip[15] = modl[12] * proj[ 3] + modl[13] * proj[ 7] + modl[14] * proj[11] + modl[15] * proj[15];

    set_plane_values(right, clip[3] - clip[0], clip[7] - clip[4], clip[11] - clip[8],  clip[15] - clip[12]);
    set_plane_values(left,  clip[3] + clip[0], clip[7] + clip[4], clip[11] + clip[8],  clip[15] + clip[12]);
    set_plane_values(bottom,clip[3] + clip[1], clip[7] + clip[5], clip[11] + clip[9],  clip[15] + clip[13]);
    set_plane_values(top,   clip[3] - clip[0], clip[7] - clip[4], clip[11] - clip[8],  clip[15] - clip[12]);
    set_plane_values(_far,  clip[3] - clip[2], clip[7] - clip[6], clip[11] - clip[10], clip[15] - clip[14]);
    set_plane_values(_near, clip[3] + clip[2], clip[7] + clip[6], clip[11] + clip[10], clip[15] + clip[14]);

    CALL_GETTER(self, "normalize_planes!");

    return self;
}

