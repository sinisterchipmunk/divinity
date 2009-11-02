#include "divinity_ext.h"

static void update_boundary(VALUE self, int current_octree_depth, struct RArray *objects);
static void subdivide(VALUE self, int current_octree_depth);
static void create_child(VALUE self, int current_depth, int mx, int my, int mz);
static void delegate_objects(VALUE self, struct RArray *children, struct RArray *objects);
static void get_bounding_box_size(VALUE box, double *bb_size);

static VALUE rb_fOpenGl_Octree_validate(VALUE self);
static VALUE rb_fOpenGl_Octree_render(VALUE self);
static VALUE rb_fOpenGl_Octree_update(int argc, VALUE *argv, VALUE self);

static VALUE rb_cOctree = Qnil;
static VALUE rb_cFrustum = Qnil;
static VALUE rb_cVector3d = Qnil;
static VALUE NORMAL_VIEW_VECTOR = Qnil, NORMAL_UP_VECTOR = Qnil, NORMAL_RIGHT_VECTOR = Qnil;

void divinity_init_opengl_octree()
{
    VALUE rb_mOpenGl = rb_const_get(rb_cObject, rb_intern("OpenGl"));
    rb_cOctree = rb_define_class_under(rb_mOpenGl, "Octree", rb_cObject);
    rb_cFrustum = rb_define_class_under(rb_mOpenGl, "Frustum", rb_cObject);
    rb_cVector3d = rb_const_get(rb_const_get(rb_cObject, rb_intern("Geometry")), rb_intern("Vector3d"));

    rb_define_method(rb_cOctree, "validate!", rb_fOpenGl_Octree_validate, 0);
    rb_define_method(rb_cOctree, "render", rb_fOpenGl_Octree_render, 0);
    rb_define_method(rb_cOctree, "update", rb_fOpenGl_Octree_update, -1);

    divinity_init_opengl_octree_object_descriptor();
}

static VALUE rb_fOpenGl_Octree_update(int argc, VALUE *argv, VALUE self)
{
    VALUE delta, scene;
    struct RArray *objects = RARRAY(CALL_GETTER(self, "objects"));
    long i;
    if (rb_scan_args(argc, argv, "11", &delta, &scene) == 1)
        scene = Qnil; // default
    if (CALL_GETTER(self, "valid?") != Qtrue)
        CALL_GETTER(self, "validate!");
    for (i = 0; i < objects->len; i++)
        rb_funcall(*(objects->ptr+i), rb_intern("update"), 2, delta, scene);
    return Qnil;
}

static VALUE rb_fOpenGl_Octree_render(VALUE self)
{
    VALUE GL = rb_const_get(rb_cObject, rb_intern("Gl"));
    VALUE bounding_box = rb_ivar_get(self, rb_intern("@octree_bounding_box"));
    if (rb_funcall(bounding_box, rb_intern("empty?"), 0) == Qtrue) return Qnil;
    if (rb_funcall(self, rb_intern("valid?"), 0) == Qfalse) rb_funcall(self, rb_intern("validate!"), 0);
    VALUE visibility = rb_funcall(self, rb_intern("cube_visible?"), 1, bounding_box);
    if (visibility == Qfalse) return Qnil;
    struct RArray *objects = RARRAY(rb_funcall(self, rb_intern("objects"), 0)),
                  *children = RARRAY(rb_funcall(self, rb_intern("children"), 0));
    long i;

    if (ruby_debug != Qfalse)
    {
        VALUE size = rb_funcall(self, rb_intern("size"), 0);
        VALUE position = rb_funcall(self, rb_intern("position"), 0);

        glPushAttrib(GL_CURRENT_BIT | GL_POLYGON_BIT);
        glColor4f(1, 1, 0, 1);
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        rb_funcall(self, rb_intern("render_cube"), 4, position,
                    rb_funcall(size, rb_intern("x"), 0),
                    rb_funcall(size, rb_intern("y"), 0),
                    rb_funcall(size, rb_intern("z"), 0));
        glPopAttrib();
    }

    if (visibility == Qtrue) //full visibility -- no need to continue testing, just render all objects
        for (i = 0; i < objects->len; i++) rb_funcall(*(objects->ptr+i), rb_intern("render_without_frustum_check"), 0);
    else //visibility == :partial
    {
        if (children->len > 0) // render child octrees, if any
            for (i = 0; i < children->len; i++) rb_funcall(*(children->ptr+i), rb_intern("render"), 0);
        else  // render children if no child octrees
            for (i = 0; i < objects->len; i++) rb_funcall(*(objects->ptr+i), rb_intern("render"), 0);
    }
    return Qnil;
}

/* potentially generates bounding boxes for each object in this scene; this has to be done during every validation,
   because the object's transformations might just be what's causing this validation to commence. */
static VALUE rb_fOpenGl_Octree_validate(VALUE self)
{
    const VALUE max_octree_depth = rb_const_get(rb_cOctree, rb_intern("MAX_OCTREE_DEPTH"));
    const VALUE object_threshold = rb_const_get(rb_cOctree, rb_intern("THRESHOLD"));

    long i;
    struct RArray *children = RARRAY(rb_funcall(self, rb_intern("children"),0));
    struct RArray *objects  = RARRAY(rb_funcall(self, rb_intern("objects"),0));
    int current_octree_depth= NUM2INT(rb_funcall(self,rb_intern("depth"),0));

    if (NIL_P(NORMAL_VIEW_VECTOR) || NIL_P(NORMAL_UP_VECTOR) || NIL_P(NORMAL_RIGHT_VECTOR))
    {
        NORMAL_VIEW_VECTOR = rb_funcall(rb_cVector3d, rb_intern("new"), 3, INT2NUM(0), INT2NUM(0), INT2NUM(-1));
        NORMAL_UP_VECTOR   = rb_funcall(rb_cVector3d, rb_intern("new"), 3, INT2NUM(0), INT2NUM(1), INT2NUM(0));
        NORMAL_RIGHT_VECTOR= rb_funcall(rb_cVector3d, rb_intern("new"), 3, INT2NUM(1), INT2NUM(0), INT2NUM(0));

        rb_ivar_set(self, rb_intern("normal_view_vector"), NORMAL_VIEW_VECTOR);
        rb_ivar_set(self, rb_intern("normal_up_vector"), NORMAL_UP_VECTOR);
        rb_ivar_set(self, rb_intern("normal_right_vector"), NORMAL_RIGHT_VECTOR);
    }

    // update boundary!
    update_boundary(self, current_octree_depth, objects);

    // subdivide! if children.empty? and objects.length > THRESHOLD and depth < MAX_OCTREE_DEPTH
    if (children->len == 0 && objects->len > object_threshold && current_octree_depth < max_octree_depth)
        subdivide(self, current_octree_depth);

    // delegate_objects!
    delegate_objects(self, children, objects);

    // children.each { |c| c.validate! }
    for (i = 0; i < children->len; i++)
        rb_funcall(*(children->ptr+i), rb_intern("validate!"), 0);
    

    //@valid = true
    rb_ivar_set(self, rb_intern("@valid"), Qtrue);

    return self;
}

/* Called by self#validate! after subdividing (where necessary), unless objects.empty?. Objects are sorted based on
   the quadrant of this octree they appear in. This is based off of position, not size of bounding box. Because of
   this, it is possible for the borders of this octree to overlap the borders of another after #update_boundary!
   resizes this octree to accomodate object bounding boxes. */
static void delegate_objects(VALUE self, struct RArray *children, struct RArray *objects)
{
    long i, j;
    VALUE objpos;

    for (i = 0; i < objects->len; i++)
    {
        objpos = rb_funcall(*(objects->ptr+i), rb_intern("position"), 0);
        for (j = 0; j < children->len; j++)
        {
            if (rb_funcall(*(children->ptr+j), rb_intern("contains?"), 1, objpos))
            {
                rb_funcall(*(children->ptr+j), rb_intern("<<"), 1, *(objects->ptr+i));
                break;
            }
        }
    }
}

/*
  self#validate! calls this when # of objects exceeds threshold AND depth < MAX_OCTREE_DEPTH AND children.empty?
  This method creates 8 child octrees, then positions and sizes them to their maximum allowed sizes. These sizes
  are used to delegate objects into the child octrees; after delegation, the octrees will be resized
  based on the objects they contain.
*/
static void subdivide(VALUE self, int current_octree_depth)
{
    create_child(self, current_octree_depth, -1, -1, -1); // TOP    LEFT  REAR
    create_child(self, current_octree_depth,  1, -1, -1); // TOP    RIGHT REAR
    create_child(self, current_octree_depth, -1, -1,  1); // TOP    LEFT  FRONT
    create_child(self, current_octree_depth,  1, -1,  1); // TOP    RIGHT FRONT
    create_child(self, current_octree_depth, -1,  1, -1); // BOTTOM LEFT  REAR
    create_child(self, current_octree_depth,  1,  1, -1); // BOTTOM RIGHT REAR
    create_child(self, current_octree_depth, -1,  1,  1); // BOTTOM LEFT  FRONT
    create_child(self, current_octree_depth,  1,  1,  1); // BOTTOM RIGHT FRONT
}

/* Creates a child at the specified location (all arguments should be either -1 or 1) within this octree, and then
   sizes it to fill one entire quadrant of this octree. */
static void create_child(VALUE self, int current_depth, int mx, int my, int mz)
{
    VALUE size = rb_ivar_get(self, rb_intern("@size")),
          posi = rb_ivar_get(self, rb_intern("@position"));
    float sx = NUM2DBL(rb_funcall(size, rb_intern("x"), 0)) / 2,
          sy = NUM2DBL(rb_funcall(size, rb_intern("y"), 0)) / 2,
          sz = NUM2DBL(rb_funcall(size, rb_intern("z"), 0)) / 2;
    float  x = NUM2DBL(rb_funcall(posi, rb_intern("x"), 0)) + mx*sx,
           y = NUM2DBL(rb_funcall(posi, rb_intern("y"), 0)) + my*sy,
           z = NUM2DBL(rb_funcall(posi, rb_intern("z"), 0)) + mz*sz;

    VALUE child = rb_funcall(rb_cOctree, rb_intern("new"), 3, rb_funcall(self, rb_intern("engine"), 0),
                  INT2NUM(current_depth + 1), self);
    rb_funcall(rb_funcall(child, rb_intern("position"), 0), rb_intern("assign!"), 3, rb_float_new(x), rb_float_new(y),
                rb_float_new(z));
    rb_funcall(rb_funcall(child, rb_intern("size"), 0), rb_intern("assign!"), 3, rb_float_new(sx), rb_float_new(sy),
                rb_float_new(sz));
    rb_funcall(rb_cFrustum, rb_intern("bounding_box"), 8,
        rb_ivar_get(child, rb_intern("@octree_bounding_box")),
        rb_float_new(sx),
        rb_float_new(sy),
        rb_float_new(sz),
        posi, NORMAL_VIEW_VECTOR, NORMAL_UP_VECTOR, NORMAL_RIGHT_VECTOR
    );

    rb_funcall(rb_funcall(self, rb_intern("children"), 0), rb_intern("<<"), 1, child);
}

/* This is the first method called from Octree#validate! and is responsible for setting the center point of the octree,
   as well as calculating its minimum boundaries. It is NOT responsible for setting the positions or sizes of child
   octrees, because they will set their own dimensions based on the objects that are delegated to them. */
static void update_boundary(VALUE self, int current_octree_depth, struct RArray *objects)
{
    double pos[] = {0,0,0}, max[] = {0,0,0}, min[] = {0,0,0};
    double cur[] = {0,0,0};
    double bb_size[3];
    double swap;
    long i;
    VALUE bb;
    VALUE position = rb_ivar_get(self, rb_intern("@position"));
    VALUE size = rb_ivar_get(self, rb_intern("@size"));
    struct RArray *objpos;

    /** REMOVE THIS CONDITION to allow all children to resize themselves (probably a little more efficient that way) **/
    if (current_octree_depth == 0)
    {
        //find the centerpoint as well as the maximum x, y, z bounds, based on the bounding box for each object in this
        //octree
        for (i = 0; i < objects->len; i++)
        {
            objpos = RARRAY(rb_funcall(rb_funcall(*(objects->ptr+i), rb_intern("position"),0), rb_intern("to_a"),0));
            cur[0] = NUM2DBL(*objpos->ptr); cur[1] = NUM2DBL(*(objpos->ptr+1)); cur[2] = NUM2DBL(*(objpos->ptr+2));
            bb = rb_funcall(*(objects->ptr+i), rb_intern("bounding_box"), 0);
            get_bounding_box_size(bb, bb_size);
            if (i == 0) // first pass
            {
                min[0] = cur[0] - bb_size[0]; min[1] = cur[1] - bb_size[1]; min[2] = cur[2] - bb_size[2];
                max[0] = cur[0] + bb_size[0]; max[1] = cur[1] + bb_size[1]; max[2] = cur[2] + bb_size[2];
            }
            else
            {
                min[0] = MIN(min[0], cur[0] - bb_size[0]);
                min[1] = MIN(min[1], cur[1] - bb_size[1]);
                min[2] = MIN(min[2], cur[2] - bb_size[2]);
                max[0] = MAX(max[0], cur[0] + bb_size[0]);
                max[1] = MAX(max[1], cur[1] + bb_size[1]);
                max[2] = MAX(max[2], cur[2] + bb_size[2]);
            }
        }

        if (objects->len > 0)
        {
            if (min[0] > max[0]) { swap = min[0]; min[0] = max[0]; max[0] = swap; }
            if (min[1] > max[1]) { swap = min[1]; min[1] = max[1]; max[1] = swap; }
            if (min[2] > max[2]) { swap = min[2]; min[2] = max[2]; max[2] = swap; }
            //we only want half the total size, so we divide by 2
            cur[0] = (max[0] - min[0]) / 2;
            cur[1] = (max[1] - min[1]) / 2;
            cur[2] = (max[2] - min[2]) / 2;
            pos[0] = cur[0] + min[0];
            pos[1] = cur[1] + min[1];
            pos[2] = cur[2] + min[2];
        }
        else cur[0] = cur[1] = cur[2] = 0;
        rb_funcall(size, rb_intern("assign!"), 3, rb_float_new(cur[0]), rb_float_new(cur[1]), rb_float_new(cur[2]));
        rb_funcall(position, rb_intern("assign!"), 3, rb_float_new(pos[0]), rb_float_new(pos[1]), rb_float_new(pos[2]));
        rb_funcall(rb_cFrustum, rb_intern("bounding_box"), 8,
            rb_ivar_get(self, rb_intern("@octree_bounding_box")),
            rb_funcall(size, rb_intern("x"), 0),
            rb_funcall(size, rb_intern("y"), 0),
            rb_funcall(size, rb_intern("z"), 0),
            position, NORMAL_VIEW_VECTOR, NORMAL_UP_VECTOR, NORMAL_RIGHT_VECTOR
        );
    }
}

/** Computes the minimum and maximum extents of the specified bounding box, and stores the difference
    (width, height and depth) in *size.  **/
static void get_bounding_box_size(VALUE box, double *size)
{
    double lx = 0, ly = 0, lz = 0, rx = 0, ry = 0, rz = 0, vx, vy, vz, swap;
    struct RArray *arr = RARRAY(box);
    struct RArray *v;
    long i;

    for (i = 0; i < arr->len; i++)
    {
        v = RARRAY(rb_funcall(*(arr->ptr+i), rb_intern("to_a"), 0));
        vx = NUM2DBL(*(v->ptr));
        vy = NUM2DBL(*(v->ptr+1));
        vz = NUM2DBL(*(v->ptr+2));

        if (i == 0) // first pass
        {
            lx = rx = vx;
            ly = ry = vy;
            lz = rz = vz;
        }
        else
        {
            if (lx > vx) lx = vx;
            if (ly > vy) ly = vy;
            if (lz > vz) lz = vz;
            if (rx < vx) rx = vx;
            if (ry < vy) ry = vy;
            if (rz < vz) rz = vz;
        }
    }

    if (lx > rx) { swap = lx; lx = rx; rx = swap; }
    if (ly > ry) { swap = ly; ly = ry; ry = swap; }
    if (lz > rz) { swap = lz; lz = rz; rz = swap; }

    size[0] = rx - lx;
    size[1] = ry - ly;
    size[2] = rz - lz;
}
