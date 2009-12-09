#include "divinity.h"

static VALUE rb_mGeometry = Qnil;
VALUE rb_cVertex3d = Qnil;
VALUE rb_cVector3d = Qnil;

static VALUE rb_fInitialize(VALUE self, VALUE args);
static VALUE rb_fArrayAccessor(VALUE self, VALUE index);
static VALUE rb_fEquals(VALUE self, VALUE v);
static VALUE rb_fAssign(VALUE self, VALUE args);
static VALUE rb_fEqualMagnitude(VALUE self, VALUE target);

void divinity_init_vertex3d()
{
    rb_mGeometry = rb_define_module("Geometry");
    rb_cVector3d = rb_define_class_under(rb_mGeometry, "Vector3d", rb_cObject);
    rb_define_class_under(rb_mGeometry, "Vertex3d", rb_cVector3d);

    // Vertex3d has been removed and replaced with Vector3d, but since they both filled the same role, we can just make
    // them both point to the same class.
    rb_cVertex3d = rb_cVector3d;


    rb_define_method(rb_cVertex3d, "initialize", rb_fInitialize, -2);
    rb_define_method(rb_cVertex3d, "[]", rb_fArrayAccessor, 1);
    rb_define_method(rb_cVertex3d, "==", rb_fEquals, -2);
    rb_define_method(rb_cVertex3d, "assign!", rb_fAssign, -2);
    rb_define_method(rb_cVertex3d, "equal_magnitude?", rb_fEqualMagnitude, 1);

    rb_define_alias(rb_cVertex3d, "magnitude_equal?", "equal_magnitude?");
}

static VALUE rb_fInitialize(VALUE self, VALUE args)
{
    return rb_fAssign(self, args);
}

/* ====== */

/* ====== */

static VALUE rb_fEqualMagnitude(VALUE self, VALUE target)
{
    return rb_funcall(CALL_GETTER(self, "magnitude"), rb_intern("=="), 1, CALL_GETTER(target, "magnitude"));
}

static VALUE rb_fAssign(VALUE self, VALUE args)
{
    args = CALL_GETTER(args, "extract_vector3i!");
    rb_ivar_set(self, rb_intern("@x"), rb_funcall(args, rb_intern("[]"), 1, INT2FIX(0)));
    rb_ivar_set(self, rb_intern("@y"), rb_funcall(args, rb_intern("[]"), 1, INT2FIX(1)));
    rb_ivar_set(self, rb_intern("@z"), rb_funcall(args, rb_intern("[]"), 1, INT2FIX(2)));
    return self;
}

static VALUE rb_fArrayAccessor(VALUE self, VALUE index)
{
    debug_puts("3A");
    rb_funcall(rb_cObject, rb_intern("puts"), 1, CALL_GETTER(index, "class"));
    printf("%d\n", NUM2INT(index));
    int i = FIX2INT(index);
    switch(i)
    {
        case 0: return CALL_GETTER(self, "x");
        case 1: return CALL_GETTER(self, "y");
        case 2: return CALL_GETTER(self, "z");
        default: rb_raise(rb_const_get(rb_cObject, rb_intern("ArgumentError")), "Index %d out of range 0..2", i);
    }
    debug_puts("3");
    return Qnil;
}

static VALUE rb_fEquals(VALUE self, VALUE v)
{
    v = rb_funcall(v, rb_intern("extract_vector3i!"), 0);
    VALUE vx = rb_funcall(v, rb_intern("[]"), 1, INT2FIX(0)), vy = rb_funcall(v, rb_intern("[]"), 1, INT2FIX(1)),
          vz = rb_funcall(v, rb_intern("[]"), 1, INT2FIX(2));
    VALUE sx = CALL_GETTER(self, "x"), sy = CALL_GETTER(self, "y"), sz = CALL_GETTER(self, "z");

    if (NUM2DBL(vx) == NUM2DBL(sx) && NUM2DBL(vy) == NUM2DBL(sy) && NUM2DBL(vz) == NUM2DBL(sz))
        return Qtrue;

    return Qfalse;
}
