#include "divinity.h"

static VALUE rb_mOpenGl = Qnil;
static VALUE rb_cFrustum = Qnil;

static VALUE rb_f_update(int argc, VALUE *argv, VALUE self);
static VALUE rb_f_render(VALUE self);
static VALUE rb_f_render_without_frustum_check(VALUE self);
static VALUE rb_f_buffer(VALUE self);

void divinity_init_opengl_octree_object_descriptor()
{
    rb_mOpenGl  = rb_const_get(rb_cObject, rb_intern("OpenGl"));
    rb_cFrustum = rb_define_class_under(rb_mOpenGl, "Frustum", rb_cObject);//rb_const_get(rb_mOpenGl, rb_intern("Frustum"));
    VALUE rb_cOctree = rb_const_get(rb_mOpenGl, rb_intern("Octree"));
    VALUE rb_cObjectDescriptor = rb_define_class_under(rb_cOctree, "ObjectDescriptor", rb_cObject);

    rb_define_method(rb_cObjectDescriptor, "update", rb_f_update, -1);
    rb_define_method(rb_cObjectDescriptor, "render", rb_f_render, 0);
    rb_define_method(rb_cObjectDescriptor, "render_without_frustum_check", rb_f_render_without_frustum_check, 0);
    rb_define_method(rb_cObjectDescriptor, "buffer!", rb_f_buffer, 0);
}

static VALUE rb_f_update(int argc, VALUE *argv, VALUE self)
{
    VALUE delta, scene;
    if (rb_scan_args(argc, argv, "11", &delta, &scene) == 1)
        scene = Qnil; // default
    VALUE object = CALL_GETTER(self, "object");
    VALUE pos   = CALL_GETTER(self, "position"),   right  = CALL_GETTER(self, "right"),
          view  = CALL_GETTER(self, "view"),       up     = CALL_GETTER(self, "up"),
          size  = CALL_GETTER(self, "size");
    VALUE opos  = CALL_GETTER(object, "position"), oright = CALL_GETTER(object, "right"),
          oview = CALL_GETTER(object, "view"),     oup    = CALL_GETTER(object, "up"),
          osize = CALL_GETTER(object, "size");

    if (rb_respond_to(object, rb_intern("update")))
        rb_funcall(object, rb_intern("update"), 2, delta, scene);

    /* If the object's orientation or size has changed in any way, its bounding box needs to be regenerated. Also,
        we need to see if the octree is still valid, and invalidate it if it no longer contains the object. */
    if (NEQUAL(pos, opos) || NEQUAL(right, oright) || NEQUAL(view, oview) || NEQUAL(up, oup) || NEQUAL(size, osize))
    {// if the octree still contains this position, then there's no reason to invalidate it, because it'd be identical.
        if (rb_funcall(CALL_GETTER(self, "octree"), rb_intern("contains?"), 1, pos) != Qfalse)
            rb_funcall(object, rb_intern("invalidate!"), 0);
        return rb_funcall(self, rb_intern("buffer!"), 0);
    }
    return Qnil;
}

static VALUE rb_f_render(VALUE self)
{
    if (rb_funcall(CALL_GETTER(self, "octree"), rb_intern("cube_visible?"), 1, CALL_GETTER(self, "bounding_box"))
        != Qfalse)
    {
        return rb_funcall(CALL_GETTER(self, "object"), rb_intern("render"), 0);
    }
    return Qnil;
}

static VALUE rb_f_render_without_frustum_check(VALUE self)
{
    return rb_funcall(CALL_GETTER(self, "object"), rb_intern("render"), 0);
}

// This is likely a CPU-intensive method and should not be called every frame.
static VALUE rb_f_buffer(VALUE self)
{
    VALUE object = CALL_GETTER(self, "object");
    VALUE position = CALL_GETTER(self, "position"),
          right = CALL_GETTER(self, "right"),
          view = CALL_GETTER(self, "view"),
          up = CALL_GETTER(self, "up"),
          size = CALL_GETTER(self, "size");
    VALUE opos = CALL_GETTER(object, "position"),
          oright = CALL_GETTER(object, "right"),
          oview = CALL_GETTER(object, "view"),
          oup = CALL_GETTER(object, "up"),
          osize = CALL_GETTER(object, "size");

    // If the object size is not of Vector3d type, then we need to convert it to one. Yeah, this instantiates
    // another object more-or-less unnecessarily; not quite sure what to do about that yet.
    if (rb_obj_is_kind_of(osize, rb_cVector3d) != Qtrue)
        osize = rb_funcall(rb_cVector3d, rb_intern("new"), 1, osize);

    rb_funcall(position, rb_intern("assign!"), 1, opos);
    rb_funcall(right,    rb_intern("assign!"), 1, oright);
    rb_funcall(view,     rb_intern("assign!"), 1, oview);
    rb_funcall(up,       rb_intern("assign!"), 1, oup);
    rb_funcall(size,     rb_intern("assign!"), 1, osize);

    return rb_funcall(rb_cFrustum, rb_intern("bounding_box"), 8,
                CALL_GETTER(self, "bounding_box"), CALL_GETTER(size, "x"), CALL_GETTER(size, "y"),
                CALL_GETTER(size, "z"), position, view, up, right);
}
