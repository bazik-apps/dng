module dng.base.g_alloca;
extern (C) __gshared @nogc nothrow @safe:

import core.stdc.stdlib: alloca;
import core.stdc.string: memset;

/***
 * g_alloca:
 * @size: number of bytes to allocate.
 *
 * Allocates @size bytes on the stack; these bytes will be freed when the current
 * stack frame is cleaned up. This macro essentially just wraps the alloca()
 * function present on most UNIX variants.
 * Thus it provides the same advantages and pitfalls as alloca():
 *
 * - alloca() is very fast, as on most systems it's implemented by just adjusting
 *   the stack pointer register.
 *
 * - It doesn't cause any memory fragmentation, within its scope, separate alloca()
 *   blocks just build up and are released together at function end.
 *
 * - Allocation sizes have to fit into the current stack frame. For instance in a
 *   threaded environment on Linux, the per-thread stack size is limited to 2 Megabytes,
 *   so be sparse with alloca() uses.
 *
 * - Allocation failure due to insufficient stack space is not indicated with a %NULL
 *   return like e.g. with malloc(). Instead, most systems probably handle it the same
 *   way as out of stack space situations from infinite function recursion, i.e.
 *   with a segmentation fault.
 *
 * - Allowing @size to be specified by an untrusted party would allow for them
 *   to trigger a segmentation fault by specifying a large size, leading to a
 *   denial of service vulnerability. @size must always be entirely under the
 *   control of the program.
 *
 * - Special care has to be taken when mixing alloca() with GNU C variable sized arrays.
 *   Stack space allocated with alloca() in the same scope as a variable sized array
 *   will be freed together with the variable sized array upon exit of that scope, and
 *   not upon exit of the enclosing function scope.
 *
 * Returns: space for @size bytes, allocated on the stack */
alias g_alloca = alloca;

/***
 * g_alloca0:
 * @size: number of bytes to allocate.
 *
 * Wraps g_alloca() and initializes allocated memory to zeroes.
 * If @size is `0` it returns %NULL.
 *
 * Note that the @size argument will be evaluated multiple times.
 *
 * Returns: (nullable) (transfer full): space for @size bytes, allocated on the stack */
enum void* g_alloca0(size_t size) = size == 0 ? null : memset(g_alloca(size), 0, size);

/***
 * g_newa:
 * @struct_type: Type of memory chunks to be allocated
 * @n_structs: Number of chunks to be allocated
 *
 * Wraps g_alloca() in a more typesafe manner.
 *
 * As mentioned in the documentation for g_alloca(), @n_structs must always be
 * entirely under the control of the program, or you may introduce a denial of
 * service vulnerability. In addition, the multiplication of @struct_type by
 * @n_structs is not checked, so an overflow may lead to a remote code execution
 * vulnerability.
 *
 * Returns: Pointer to stack space for @n_structs chunks of type @struct_type */
enum T* g_newa(T, size_t num) = cast(T*)g_alloca(T.sizeof * num);

/***
 * g_newa0:
 * @struct_type: the type of the elements to allocate.
 * @n_structs: the number of elements to allocate.
 *
 * Wraps g_alloca0() in a more typesafe manner.
 *
 * Returns: (nullable) (transfer full): Pointer to stack space for @n_structs
 *   chunks of type @struct_type */
enum T* g_newa0(T, size_t num) = cast(T*)g_alloca0(T.sizeof * num);
