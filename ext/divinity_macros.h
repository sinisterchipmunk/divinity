#ifndef DIVINITY_MACROS_H
#define DIVINITY_MACROS_H

#ifndef MIN
#define MIN(a, b) (a > b ? b : a)
#endif//MAX

#ifndef MAX
#define MAX(a, b) (a > b ? a : b)
#endif//MAX

#ifndef CALL_GETTER
#define CALL_GETTER(a, b) (rb_funcall(a, rb_intern(b), 0))
#endif//CALL_GETTER

#ifndef CALL_SETTER
#define CALL_SETTER(a, b, c) (rb_funcall(a, rb_intern(b), 1, c))
#endif//CALL_SETTER

#ifndef NEQUAL
#define NEQUAL(a, b) ((rb_funcall(a, rb_intern("=="), 1, b)) == Qfalse)
#endif//NEQUAL

#ifndef EQUAL
#define EQUAL(a, b) ((rb_funcall(a, rb_intern("=="), 1, b)) == Qtrue)
#endif//EQUAL

#endif//DIVINITY_MACROS_H
