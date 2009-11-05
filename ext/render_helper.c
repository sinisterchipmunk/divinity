#include "divinity_ext.h"

static VALUE rb_mHelpers = Qnil;
static VALUE rb_mRenderHelper = Qnil;

static VALUE rb_fRenderCube(VALUE self, VALUE position, VALUE width, VALUE height, VALUE depth);
static VALUE rb_fOrtho(VALUE self, VALUE w, VALUE h);

extern void divinity_init_render_helper()
{
    rb_mHelpers = rb_define_module("Helpers");
    rb_mRenderHelper = rb_define_module_under(rb_mHelpers, "RenderHelper");

    rb_define_method(rb_mRenderHelper, "render_cube", rb_fRenderCube, 4);
    rb_define_method(rb_mRenderHelper, "__ortho", rb_fOrtho, 2);
}

static VALUE rb_fOrtho(VALUE self, VALUE w, VALUE h)
{
    double width = NUM2DBL(w), height = NUM2DBL(h);
    glDisable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
      glLoadIdentity();
      //#We swap Y and HEIGHT here because most GUI development
      //#works top-down, UNLIKE OpenGL. This reverses it.
      //#                |--Y--|, |height|
      glOrtho(0, width, height,  0,       -1, 1);
      glMatrixMode(GL_MODELVIEW);
      glEnable(GL_SCISSOR_TEST);
      glPushMatrix();
        glLoadIdentity();
        rb_yield(Qnil);
        glMatrixMode(GL_PROJECTION);
      glPopMatrix();
      glDisable(GL_SCISSOR_TEST);
      glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
    glEnable(GL_DEPTH_TEST);
}

static VALUE rb_fRenderCube(VALUE self, VALUE position, VALUE w, VALUE h, VALUE d)
{
    double px, py, pz, width, height, depth;
    px = NUM2DBL(CALL_GETTER(position, "x"));
    py = NUM2DBL(CALL_GETTER(position, "y"));
    pz = NUM2DBL(CALL_GETTER(position, "z"));
    width = NUM2DBL(w);
    height = NUM2DBL(h);
    depth = NUM2DBL(d);

    glTranslated(px, py, pz);
    glDisable(GL_TEXTURE_2D);
    glBegin(GL_QUADS);
      //# LEFT
      glVertex3f(-width, -height, -depth);
      glVertex3f(-width, -height,  depth);
      glVertex3f(-width,  height,  depth);
      glVertex3f(-width,  height, -depth);
      //# RIGHT
      glVertex3f( width, -height, -depth);
      glVertex3f( width, -height,  depth);
      glVertex3f( width,  height,  depth);
      glVertex3f( width,  height, -depth);
      //# TOP
      glVertex3f(-width, -height, -depth);
      glVertex3f(-width, -height,  depth);
      glVertex3f( width, -height,  depth);
      glVertex3f( width, -height, -depth);
      //# BOTTOM
      glVertex3f(-width,  height, -depth);
      glVertex3f(-width,  height,  depth);
      glVertex3f( width,  height,  depth);
      glVertex3f( width,  height, -depth);
      //# FRONT
      glVertex3f(-width, -height,  depth);
      glVertex3f(-width,  height,  depth);
      glVertex3f( width,  height,  depth);
      glVertex3f( width, -height,  depth);
      //# BACK
      glVertex3f(-width, -height, -depth);
      glVertex3f(-width,  height, -depth);
      glVertex3f( width,  height, -depth);
      glVertex3f( width, -height, -depth);
    glEnd();
    glEnable(GL_TEXTURE_2D);
    glTranslatef(-px, -py, -pz);
    return Qnil;
}
