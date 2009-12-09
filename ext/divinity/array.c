#include "divinity.h"

VALUE rb_cNumeric = Qnil;
VALUE rb_mGeometry = Qnil;
VALUE rb_cVertex3d = Qnil;
VALUE rb_cArray = Qnil;

static VALUE rb_fExtractVector3i(VALUE self);

void divinity_init_array()
{
    rb_cNumeric = rb_const_get(rb_cObject, rb_intern("Numeric"));
    rb_mGeometry = rb_const_get(rb_cObject, rb_intern("Geometry"));
    rb_cVertex3d = rb_const_get(rb_mGeometry, rb_intern("Vertex3d"));
    rb_cArray = rb_const_get(rb_cObject, rb_intern("Array"));

    rb_define_method(rb_cArray, "__extract_vector3i!", rb_fExtractVector3i, 0);
}

static VALUE rb_fExtractVector3i(VALUE self)
{
    struct RArray *arr = RARRAY(self);
    VALUE i, r;

    if (arr->len >= 3 && RKIND_OF(*(arr->ptr), rb_cNumeric) && RKIND_OF(*(arr->ptr+1), rb_cNumeric) &&
        RKIND_OF(*(arr->ptr+2), rb_cNumeric))
        return rb_funcall(self, rb_intern("slice!"), 2, INT2FIX(0), INT2FIX(3));
    else if (arr->len >= 1 && RKIND_OF(*(arr->ptr), rb_cVertex3d))
        return rb_funcall(CALL_GETTER(CALL_GETTER(self, "shift"), "to_a"), rb_intern("slice"), 2, INT2FIX(0),
                            INT2FIX(3));
    else if (arr->len >= 1 && RKIND_OF(*(arr->ptr), rb_cArray))
        if (RARRAY(*(arr->ptr))->len == 3 || RARRAY(*(arr->ptr))->len == 4)
            return rb_funcall(CALL_GETTER(self, "shift"), rb_intern("slice"), 2, INT2FIX(0), INT2FIX(3));
        else ;
    else if (arr->len >= 1 && RKIND_OF(*(arr->ptr), rb_cArray) && RARRAY(*(arr->ptr))->len == 1 &&
        RKIND_OF(*(RARRAY(*(arr->ptr))->ptr), rb_cNumeric))
    {
        i = CALL_GETTER(CALL_GETTER(self, "shift"), "first");
        r = rb_ary_new();
        rb_ary_push(r, i);
        rb_ary_push(r, i);
        rb_ary_push(r, i);
        return r;
    }
    else if (arr->len == 1 && RKIND_OF(*(arr->ptr), rb_cNumeric)) // but self[1] and/or self[2] are not    
    {
        i = CALL_GETTER(self, "shift");
        r = rb_ary_new();
        rb_ary_push(r, i);
        rb_ary_push(r, i);
        rb_ary_push(r, i);
        return r;
    }
    else if (arr->len == 0)
    {
        r = rb_ary_new();
        rb_ary_push(r, INT2FIX(0));
        rb_ary_push(r, INT2FIX(0));
        rb_ary_push(r, INT2FIX(0));
        return r;
    }

    rb_raise(rb_const_get(rb_cObject, rb_intern("ArgumentError")), "Could not parse vector coordinates out of %s",
        STR2CSTR(CALL_GETTER(self, "inspect")));

    return Qnil;
}
