module dng.dlib.alloca;

import core.stdc.stdlib: alloca;
import core.stdc.string: memset;

extern (C):
/***
 * d_alloca:
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
alias d_alloca = alloca;

/***
 * d_alloca0:
 * @size: number of bytes to allocate.
 *
 * Wraps alloca() and initializes allocated memory to zeroes.
 * If @size is `0` it returns %NULL.
 *
 * Note that the @size argument will be evaluated multiple times.
 *
 * Returns: space for @size bytes, allocated on the stack */
enum void* d_alloca0(size_t size) = size == 0 ? null : memset(alloca(size), 0, size);

/***
 * d_newa:
 * @T: Type of memory chunks to be allocated
 * @n: Number of chunks to be allocated
 *
 * Wraps alloca() in a more typesafe manner.
 *
 * As mentioned in the documentation for d_alloca(), @n must always be
 * entirely under the control of the program, or you may introduce a denial of
 * service vulnerability. In addition, the multiplication of @T by
 * @n is not checked, so an overflow may lead to a remote code execution
 * vulnerability.
 *
 * Returns: Pointer to stack space for @n chunks of type @T */
enum d_newa(T, size_t n) = cast(T*)alloca(T.sizeof * n);

/***
 * d_newa0:
 * @T: the type of the elements to allocate.
 * @n: the number of elements to allocate.
 *
 * Wraps d_alloca0() in a more typesafe manner.
 *
 * Returns: Pointer to stack space for @n chunks of type @T */
enum d_newa0(T, size_t n) = cast(T*)d_alloca0(T.sizeof * n);
