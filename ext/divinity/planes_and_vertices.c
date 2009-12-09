#include "divinity.h"

void get_plane_values(VALUE plane, double *a, double *b, double *c, double *d)
{
    *a = NUM2DBL(CALL_GETTER(plane, "a"));
    *b = NUM2DBL(CALL_GETTER(plane, "b"));
    *c = NUM2DBL(CALL_GETTER(plane, "c"));
    *d = NUM2DBL(CALL_GETTER(plane, "d"));
}

void set_plane_values(VALUE plane, double a, double b, double c, double d)
{
    CALL_SETTER(plane, "a=", rb_float_new(a));
    CALL_SETTER(plane, "b=", rb_float_new(b));
    CALL_SETTER(plane, "c=", rb_float_new(c));
    CALL_SETTER(plane, "d=", rb_float_new(d));
}

void get_vertex_values(VALUE vertex, double *x, double *y, double *z)
{
    if (rb_funcall(vertex, rb_intern("kind_of?"), 1, rb_const_get(rb_cObject, rb_intern("Array"))) == Qtrue)
    {
        *x = NUM2DBL(*(RARRAY(vertex)->ptr));
        *y = NUM2DBL(*(RARRAY(vertex)->ptr+1));
        *z = NUM2DBL(*(RARRAY(vertex)->ptr+2));
    }
    else
    {
        *x = NUM2DBL(CALL_GETTER(vertex, "x"));
        *y = NUM2DBL(CALL_GETTER(vertex, "y"));
        *z = NUM2DBL(CALL_GETTER(vertex, "z"));
    }
}

void set_vertex_values(VALUE vertex, double x, double y, double z)
{
    CALL_SETTER(vertex, "x=", x);
    CALL_SETTER(vertex, "y=", y);
    CALL_SETTER(vertex, "z=", z);
}
