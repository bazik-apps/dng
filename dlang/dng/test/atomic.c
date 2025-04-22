#define glib_typeof(t) __typeof__(t)
#define G_STATIC_ASSERT(expr) _Static_assert (expr, "Expression evaluates to false")
#define G_GNUC_EXTENSION

typedef char           gchar;
typedef short          gshort;
typedef long           glong;
typedef int            gint;
typedef gint           gboolean;

typedef unsigned char  guchar;
typedef unsigned short gushort;
typedef unsigned long  gulong;
typedef unsigned int   guint;

typedef float          gfloat;
typedef double         gdouble;

typedef void*          gpointer;
typedef const void*    gconstpointer;

typedef signed long    gintptr;
typedef unsigned long  guintptr;

typedef signed long    gssize;
typedef unsigned long  gsize;

gint                   g_atomic_int_get(const volatile gint* atomic);
void                   g_atomic_int_set(volatile gint* atomic, gint newval);
void                   g_atomic_int_inc(volatile gint* atomic);
gboolean               g_atomic_int_dec_and_test(volatile gint* atomic);
gboolean g_atomic_int_compare_and_exchange(volatile gint* atomic, gint oldval, gint newval);
gboolean
			g_atomic_int_compare_and_exchange_full(gint* atomic, gint oldval, gint newval, gint* preval);
gint  g_atomic_int_exchange(gint* atomic, gint newval);
gint  g_atomic_int_add(volatile gint* atomic, gint val);
guint g_atomic_int_and(volatile guint* atomic, guint val);
guint g_atomic_int_xor(volatile guint* atomic, guint val);

gpointer g_atomic_pointer_get(const volatile void* atomic);
void     g_atomic_pointer_set(volatile void* atomic, gpointer newval);
gboolean
g_atomic_pointer_compare_and_exchange(volatile void* atomic, gpointer oldval, gpointer newval);
gboolean g_atomic_pointer_compare_and_exchange_full(
	void* atomic, gpointer oldval, gpointer newval, void* preval
);
gpointer g_atomic_pointer_exchange(void* atomic, gpointer newval);
gintptr  g_atomic_pointer_add(volatile void* atomic, gssize val);
guintptr g_atomic_pointer_and(volatile void* atomic, gsize val);
guintptr g_atomic_pointer_or(volatile void* atomic, gsize val);
guintptr g_atomic_pointer_xor(volatile void* atomic, gsize val);

#if defined(G_ATOMIC_LOCK_FREE)

	/* We prefer the new C11-style atomic extension of GCC if available */
	#if defined(__ATOMIC_SEQ_CST)

		#define g_atomic_int_get(atomic)                                  \
			(G_GNUC_EXTENSION({                                             \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));            \
				gint gaig_temp;                                               \
				(void)(0 ? *(atomic) ^ *(atomic) : 1);                        \
				__atomic_load((gint*)(atomic), &gaig_temp, __ATOMIC_SEQ_CST); \
				(gint) gaig_temp;                                             \
			}))
		#define g_atomic_int_set(atomic, newval)                           \
			(G_GNUC_EXTENSION({                                              \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));             \
				gint gais_temp = (gint)(newval);                               \
				(void)(0 ? *(atomic) ^ (newval) : 1);                          \
				__atomic_store((gint*)(atomic), &gais_temp, __ATOMIC_SEQ_CST); \
			}))

		#define g_atomic_pointer_get(atomic)                                      \
			(G_GNUC_EXTENSION({                                                     \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer));                \
				glib_typeof(*(atomic)) gapg_temp_newval;                              \
				glib_typeof((atomic)) gapg_temp_atomic = (atomic);                    \
				__atomic_load(gapg_temp_atomic, &gapg_temp_newval, __ATOMIC_SEQ_CST); \
				gapg_temp_newval;                                                     \
			}))
		#define g_atomic_pointer_set(atomic, newval)                               \
			(G_GNUC_EXTENSION({                                                      \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer));                 \
				glib_typeof((atomic)) gaps_temp_atomic  = (atomic);                    \
				glib_typeof(*(atomic)) gaps_temp_newval = (newval);                    \
				(void)(0 ? (gpointer) * (atomic) : NULL);                              \
				__atomic_store(gaps_temp_atomic, &gaps_temp_newval, __ATOMIC_SEQ_CST); \
			}))

		#define g_atomic_int_inc(atomic)                             \
			(G_GNUC_EXTENSION({                                        \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));       \
				(void)(0 ? *(atomic) ^ *(atomic) : 1);                   \
				(void)__atomic_fetch_add((atomic), 1, __ATOMIC_SEQ_CST); \
			}))
		#define g_atomic_int_dec_and_test(atomic)                   \
			(G_GNUC_EXTENSION({                                       \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));      \
				(void)(0 ? *(atomic) ^ *(atomic) : 1);                  \
				__atomic_fetch_sub((atomic), 1, __ATOMIC_SEQ_CST) == 1; \
			}))
		#define g_atomic_int_compare_and_exchange(atomic, oldval, newval)                   \
			(G_GNUC_EXTENSION({                                                               \
				glib_typeof(*(atomic)) gaicae_oldval = (oldval);                                \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));                              \
				(void)(0 ? *(atomic) ^ (newval) ^ (oldval) : 1);                                \
				__atomic_compare_exchange_n(                                                    \
					(atomic), &gaicae_oldval, (newval), FALSE, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST \
				)                                                                               \
					? TRUE                                                                        \
					: FALSE;                                                                      \
			}))
		#define g_atomic_int_compare_and_exchange_full(atomic, oldval, newval, preval) \
			(G_GNUC_EXTENSION({                                                          \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));                         \
				G_STATIC_ASSERT(sizeof *(preval) == sizeof(gint));                         \
				(void)(0 ? *(atomic) ^ (newval) ^ (oldval) ^ *(preval) : 1);               \
				*(preval) = (oldval);                                                      \
				__atomic_compare_exchange_n(                                               \
					(atomic), (preval), (newval), FALSE, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST  \
				)                                                                          \
					? TRUE                                                                   \
					: FALSE;                                                                 \
			}))
		#define g_atomic_int_exchange(atomic, newval)                         \
			(G_GNUC_EXTENSION({                                                 \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));                \
				(void)(0 ? *(atomic) ^ (newval) : 1);                             \
				(gint) __atomic_exchange_n((atomic), (newval), __ATOMIC_SEQ_CST); \
			}))
		#define g_atomic_int_add(atomic, val)                             \
			(G_GNUC_EXTENSION({                                             \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));            \
				(void)(0 ? *(atomic) ^ (val) : 1);                            \
				(gint) __atomic_fetch_add((atomic), (val), __ATOMIC_SEQ_CST); \
			}))
		#define g_atomic_int_and(atomic, val)                              \
			(G_GNUC_EXTENSION({                                              \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));             \
				(void)(0 ? *(atomic) ^ (val) : 1);                             \
				(guint) __atomic_fetch_and((atomic), (val), __ATOMIC_SEQ_CST); \
			}))
		#define g_atomic_int_or(atomic, val)                              \
			(G_GNUC_EXTENSION({                                             \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));            \
				(void)(0 ? *(atomic) ^ (val) : 1);                            \
				(guint) __atomic_fetch_or((atomic), (val), __ATOMIC_SEQ_CST); \
			}))
		#define g_atomic_int_xor(atomic, val)                              \
			(G_GNUC_EXTENSION({                                              \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));             \
				(void)(0 ? *(atomic) ^ (val) : 1);                             \
				(guint) __atomic_fetch_xor((atomic), (val), __ATOMIC_SEQ_CST); \
			}))

		#define g_atomic_pointer_compare_and_exchange(atomic, oldval, newval)               \
			(G_GNUC_EXTENSION({                                                               \
				G_STATIC_ASSERT(                                                                \
					sizeof(static_cast<glib_typeof(*(atomic))>((oldval))) == sizeof(gpointer)     \
				);                                                                              \
				glib_typeof(*(atomic)) gapcae_oldval = (oldval);                                \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer));                          \
				(void)(0 ? (gpointer) * (atomic) : NULL);                                       \
				__atomic_compare_exchange_n(                                                    \
					(atomic), &gapcae_oldval, (newval), FALSE, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST \
				)                                                                               \
					? TRUE                                                                        \
					: FALSE;                                                                      \
			}))
		#define g_atomic_pointer_compare_and_exchange_full(atomic, oldval, newval, preval) \
			(G_GNUC_EXTENSION({                                                              \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer));                         \
				G_STATIC_ASSERT(sizeof *(preval) == sizeof(gpointer));                         \
				(void)(0 ? (gpointer) * (atomic) : NULL);                                      \
				(void)(0 ? (gpointer) * (preval) : NULL);                                      \
				*(preval) = (oldval);                                                          \
				__atomic_compare_exchange_n(                                                   \
					(atomic), (preval), (newval), FALSE, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST      \
				)                                                                              \
					? TRUE                                                                       \
					: FALSE;                                                                     \
			}))
		#define g_atomic_pointer_exchange(atomic, newval)                         \
			(G_GNUC_EXTENSION({                                                     \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer));                \
				(void)(0 ? (gpointer) * (atomic) : NULL);                             \
				(gpointer) __atomic_exchange_n((atomic), (newval), __ATOMIC_SEQ_CST); \
			}))
		#define g_atomic_pointer_add(atomic, val)                            \
			(G_GNUC_EXTENSION({                                                \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer));           \
				(void)(0 ? (gpointer) * (atomic) : NULL);                        \
				(void)(0 ? (val) ^ (val) : 1);                                   \
				(gintptr) __atomic_fetch_add((atomic), (val), __ATOMIC_SEQ_CST); \
			}))
		#define g_atomic_pointer_and(atomic, val)                                \
			(G_GNUC_EXTENSION({                                                    \
				guintptr* gapa_atomic = (guintptr*)(atomic);                         \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer));               \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(guintptr));               \
				(void)(0 ? (gpointer) * (atomic) : NULL);                            \
				(void)(0 ? (val) ^ (val) : 1);                                       \
				(guintptr) __atomic_fetch_and(gapa_atomic, (val), __ATOMIC_SEQ_CST); \
			}))
		#define g_atomic_pointer_or(atomic, val)                                \
			(G_GNUC_EXTENSION({                                                   \
				guintptr* gapo_atomic = (guintptr*)(atomic);                        \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer));              \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(guintptr));              \
				(void)(0 ? (gpointer) * (atomic) : NULL);                           \
				(void)(0 ? (val) ^ (val) : 1);                                      \
				(guintptr) __atomic_fetch_or(gapo_atomic, (val), __ATOMIC_SEQ_CST); \
			}))
		#define g_atomic_pointer_xor(atomic, val)                                \
			(G_GNUC_EXTENSION({                                                    \
				guintptr* gapx_atomic = (guintptr*)(atomic);                         \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer));               \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(guintptr));               \
				(void)(0 ? (gpointer) * (atomic) : NULL);                            \
				(void)(0 ? (val) ^ (val) : 1);                                       \
				(guintptr) __atomic_fetch_xor(gapx_atomic, (val), __ATOMIC_SEQ_CST); \
			}))

	#else /* defined(__ATOMIC_SEQ_CST) */

		/* We want to achieve __ATOMIC_SEQ_CST semantics here. See
	   * https://en.cppreference.com/w/c/atomic/memory_order#Constants. For load
	   * operations, that means performing an *acquire*:
	   * > A load operation with this memory order performs the acquire operation on
	   * > the affected memory location: no reads or writes in the current thread can
	   * > be reordered before this load. All writes in other threads that release
	   * > the same atomic variable are visible in the current thread.
	   *
	   * “no reads or writes in the current thread can be reordered before this load”
	   * is implemented using a compiler barrier (a no-op `__asm__` section) to
	   * prevent instruction reordering. Writes in other threads are synchronised
	   * using `__sync_synchronize()`. It’s unclear from the GCC documentation whether
	   * `__sync_synchronize()` acts as a compiler barrier, hence our explicit use of
	   * one.
	   *
	   * For store operations, `__ATOMIC_SEQ_CST` means performing a *release*:
	   * > A store operation with this memory order performs the release operation:
	   * > no reads or writes in the current thread can be reordered after this store.
	   * > All writes in the current thread are visible in other threads that acquire
	   * > the same atomic variable (see Release-Acquire ordering below) and writes
	   * > that carry a dependency into the atomic variable become visible in other
	   * > threads that consume the same atomic (see Release-Consume ordering below).
	   *
	   * “no reads or writes in the current thread can be reordered after this store”
	   * is implemented using a compiler barrier to prevent instruction reordering.
	   * “All writes in the current thread are visible in other threads” is implemented
	   * using `__sync_synchronize()`; similarly for “writes that carry a dependency”.
	   */
		#define g_atomic_int_get(atomic)                       \
			(G_GNUC_EXTENSION({                                  \
				gint gaig_result;                                  \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint)); \
				(void)(0 ? *(atomic) ^ *(atomic) : 1);             \
				gaig_result = (gint) * (atomic);                   \
				__sync_synchronize();                              \
				__asm__ __volatile__("" : : : "memory");           \
				gaig_result;                                       \
			}))
		#define g_atomic_int_set(atomic, newval)               \
			(G_GNUC_EXTENSION({                                  \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint)); \
				(void)(0 ? *(atomic) ^ (newval) : 1);              \
				__sync_synchronize();                              \
				__asm__ __volatile__("" : : : "memory");           \
				*(atomic) = (newval);                              \
			}))
		#define g_atomic_pointer_get(atomic)                       \
			(G_GNUC_EXTENSION({                                      \
				gpointer gapg_result;                                  \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer)); \
				gapg_result = (gpointer) * (atomic);                   \
				__sync_synchronize();                                  \
				__asm__ __volatile__("" : : : "memory");               \
				gapg_result;                                           \
			}))
		#define g_atomic_pointer_set(atomic, newval)                \
			(G_GNUC_EXTENSION({                                       \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer));  \
				(void)(0 ? (gpointer) * (atomic) : NULL);               \
				__sync_synchronize();                                   \
				__asm__ __volatile__("" : : : "memory");                \
				*(atomic) = (glib_typeof(*(atomic)))(guintptr)(newval); \
			}))

		#define g_atomic_int_inc(atomic)                       \
			(G_GNUC_EXTENSION({                                  \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint)); \
				(void)(0 ? *(atomic) ^ *(atomic) : 1);             \
				(void)__sync_fetch_and_add((atomic), 1);           \
			}))
		#define g_atomic_int_dec_and_test(atomic)              \
			(G_GNUC_EXTENSION({                                  \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint)); \
				(void)(0 ? *(atomic) ^ *(atomic) : 1);             \
				__sync_fetch_and_sub((atomic), 1) == 1;            \
			}))
		#define g_atomic_int_compare_and_exchange(atomic, oldval, newval)              \
			(G_GNUC_EXTENSION({                                                          \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));                         \
				(void)(0 ? *(atomic) ^ (newval) ^ (oldval) : 1);                           \
				__sync_bool_compare_and_swap((atomic), (oldval), (newval)) ? TRUE : FALSE; \
			}))
		#define g_atomic_int_compare_and_exchange_full(atomic, oldval, newval, preval) \
			(G_GNUC_EXTENSION({                                                          \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint));                         \
				G_STATIC_ASSERT(sizeof *(preval) == sizeof(gint));                         \
				(void)(0 ? *(atomic) ^ (newval) ^ (oldval) ^ *(preval) : 1);               \
				*(preval) = __sync_val_compare_and_swap((atomic), (oldval), (newval));     \
				(*(preval) == (oldval)) ? TRUE : FALSE;                                    \
			}))
		#define g_atomic_int_exchange(atomic, newval)          \
			(G_GNUC_EXTENSION({                                  \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint)); \
				(void)(0 ? *(atomic) ^ (newval) : 1);              \
				(gint) __sync_swap((atomic), (newval));            \
			}))
		#define g_atomic_int_add(atomic, val)                  \
			(G_GNUC_EXTENSION({                                  \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint)); \
				(void)(0 ? *(atomic) ^ (val) : 1);                 \
				(gint) __sync_fetch_and_add((atomic), (val));      \
			}))
		#define g_atomic_int_and(atomic, val)                  \
			(G_GNUC_EXTENSION({                                  \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint)); \
				(void)(0 ? *(atomic) ^ (val) : 1);                 \
				(guint) __sync_fetch_and_and((atomic), (val));     \
			}))
		#define g_atomic_int_or(atomic, val)                   \
			(G_GNUC_EXTENSION({                                  \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint)); \
				(void)(0 ? *(atomic) ^ (val) : 1);                 \
				(guint) __sync_fetch_and_or((atomic), (val));      \
			}))
		#define g_atomic_int_xor(atomic, val)                  \
			(G_GNUC_EXTENSION({                                  \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gint)); \
				(void)(0 ? *(atomic) ^ (val) : 1);                 \
				(guint) __sync_fetch_and_xor((atomic), (val));     \
			}))

		#define g_atomic_pointer_compare_and_exchange(atomic, oldval, newval)          \
			(G_GNUC_EXTENSION({                                                          \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer));                     \
				(void)(0 ? (gpointer) * (atomic) : NULL);                                  \
				__sync_bool_compare_and_swap((atomic), (oldval), (newval)) ? TRUE : FALSE; \
			}))
		#define g_atomic_pointer_compare_and_exchange_full(atomic, oldval, newval, preval) \
			(G_GNUC_EXTENSION({                                                              \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer));                         \
				G_STATIC_ASSERT(sizeof *(preval) == sizeof(gpointer));                         \
				(void)(0 ? (gpointer) * (atomic) : NULL);                                      \
				(void)(0 ? (gpointer) * (preval) : NULL);                                      \
				*(preval) = __sync_val_compare_and_swap((atomic), (oldval), (newval));         \
				(*(preval) == (oldval)) ? TRUE : FALSE;                                        \
			}))
		#define g_atomic_pointer_exchange(atomic, newval)          \
			(G_GNUC_EXTENSION({                                      \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer)); \
				(void)(0 ? (gpointer) * (atomic) : NULL);              \
				(gpointer) __sync_swap((atomic), (newval));            \
			}))
		#define g_atomic_pointer_add(atomic, val)                  \
			(G_GNUC_EXTENSION({                                      \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer)); \
				(void)(0 ? (gpointer) * (atomic) : NULL);              \
				(void)(0 ? (val) ^ (val) : 1);                         \
				(gintptr) __sync_fetch_and_add((atomic), (val));       \
			}))
		#define g_atomic_pointer_and(atomic, val)                  \
			(G_GNUC_EXTENSION({                                      \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer)); \
				(void)(0 ? (gpointer) * (atomic) : NULL);              \
				(void)(0 ? (val) ^ (val) : 1);                         \
				(guintptr) __sync_fetch_and_and((atomic), (val));      \
			}))
		#define g_atomic_pointer_or(atomic, val)                   \
			(G_GNUC_EXTENSION({                                      \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer)); \
				(void)(0 ? (gpointer) * (atomic) : NULL);              \
				(void)(0 ? (val) ^ (val) : 1);                         \
				(guintptr) __sync_fetch_and_or((atomic), (val));       \
			}))
		#define g_atomic_pointer_xor(atomic, val)                  \
			(G_GNUC_EXTENSION({                                      \
				G_STATIC_ASSERT(sizeof *(atomic) == sizeof(gpointer)); \
				(void)(0 ? (gpointer) * (atomic) : NULL);              \
				(void)(0 ? (val) ^ (val) : 1);                         \
				(guintptr) __sync_fetch_and_xor((atomic), (val));      \
			}))

	#endif /* !defined(__ATOMIC_SEQ_CST) */

#else    /* defined(G_ATOMIC_LOCK_FREE) */

	#define g_atomic_int_get(atomic)         (g_atomic_int_get((gint*)(atomic)))
	#define g_atomic_int_set(atomic, newval) (g_atomic_int_set((gint*)(atomic), (gint)(newval)))
	#define g_atomic_int_compare_and_exchange(atomic, oldval, newval)          \
		(g_atomic_int_compare_and_exchange((gint*)(atomic), (oldval), (newval)))
	#define g_atomic_int_compare_and_exchange_full(atomic, oldval, newval, preval) \
		(g_atomic_int_compare_and_exchange_full((gint*)(atomic), (oldval), (newval), (gint*)(preval)))
	#define g_atomic_int_exchange(atomic, newval) (g_atomic_int_exchange((gint*)(atomic), (newval)))
	#define g_atomic_int_add(atomic, val)         (g_atomic_int_add((gint*)(atomic), (val)))
	#define g_atomic_int_and(atomic, val)         (g_atomic_int_and((guint*)(atomic), (val)))
	#define g_atomic_int_or(atomic, val)          (g_atomic_int_or((guint*)(atomic), (val)))
	#define g_atomic_int_xor(atomic, val)         (g_atomic_int_xor((guint*)(atomic), (val)))
	#define g_atomic_int_inc(atomic)              (g_atomic_int_inc((gint*)(atomic)))
	#define g_atomic_int_dec_and_test(atomic)     (g_atomic_int_dec_and_test((gint*)(atomic)))

	/* The (void *) cast in the middle *looks* redundant, because
   * g_atomic_pointer_get returns void * already, but it's to silence
   * -Werror=bad-function-cast when we're doing something like:
   * guintptr a, b; ...; a = g_atomic_pointer_get (&b);
   * which would otherwise be assigning the void * result of
   * g_atomic_pointer_get directly to the pointer-sized but
   * non-pointer-typed result. */
	#define g_atomic_pointer_get(atomic)                                     \
		(glib_typeof(*(atomic)))(void*)((g_atomic_pointer_get)((void*)atomic))

	#define g_atomic_pointer_set(atomic, newval) (g_atomic_pointer_set((atomic), (gpointer)(newval)))

	#define g_atomic_pointer_compare_and_exchange(atomic, oldval, newval)                       \
		(g_atomic_pointer_compare_and_exchange((atomic), (gpointer)(oldval), (gpointer)(newval)))
	#define g_atomic_pointer_compare_and_exchange_full(atomic, oldval, newval, prevval) \
		(g_atomic_pointer_compare_and_exchange_full(                                      \
			(atomic), (gpointer)(oldval), (gpointer)(newval), (prevval)                     \
		))
	#define g_atomic_pointer_exchange(atomic, newval)           \
		(g_atomic_pointer_exchange((atomic), (gpointer)(newval)))
	#define g_atomic_pointer_add(atomic, val) (g_atomic_pointer_add((atomic), (gssize)(val)))
	#define g_atomic_pointer_and(atomic, val) (g_atomic_pointer_and((atomic), (gsize)(val)))
	#define g_atomic_pointer_or(atomic, val)  (g_atomic_pointer_or((atomic), (gsize)(val)))
	#define g_atomic_pointer_xor(atomic, val) (g_atomic_pointer_xor((atomic), (gsize)(val)))

#endif /* defined(G_ATOMIC_LOCK_FREE) */

/***
 * G_ATOMIC_LOCK_FREE:
 *
 * This macro is defined if the atomic operations of GLib are
 * implemented using real hardware atomic operations.  This means that
 * the GLib atomic API can be used between processes and safely mixed
 * with other (hardware) atomic APIs.
 *
 * If this macro is not defined, the atomic operations may be
 * emulated using a mutex.  In that case, the GLib atomic operations are
 * only atomic relative to themselves and within a single process. */

/* NOTE CAREFULLY:
 *
 * This file is the lowest-level part of GLib.
 *
 * Other lowlevel parts of GLib (threads, slice allocator, g_malloc,
 * messages, etc) call into these functions and macros to get work done.
 *
 * As such, these functions can not call back into any part of GLib
 * without risking recursion.
 */

#ifdef G_ATOMIC_LOCK_FREE

/* if G_ATOMIC_LOCK_FREE was defined by `meson configure` then we MUST
 * implement the atomic operations in a lock-free manner.
 */

	#if defined(__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4)

/**
 * g_atomic_int_get:
 * @atomic: a pointer to a #gint or #guint
 *
 * Gets the current value of @atomic.
 *
 * This call acts as a full compiler and hardware
 * memory barrier (before the get).
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * Returns: the value of the integer
 *
 * Since: 2.4
 **/
gint(g_atomic_int_get)(const volatile gint* atomic) {
	return g_atomic_int_get(atomic);
}

/**
 * g_atomic_int_set:
 * @atomic: a pointer to a #gint or #guint
 * @newval: a new value to store
 *
 * Sets the value of @atomic to @newval.
 *
 * This call acts as a full compiler and hardware
 * memory barrier (after the set).
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * Since: 2.4
 */
void(g_atomic_int_set)(volatile gint* atomic, gint newval) {
	g_atomic_int_set(atomic, newval);
}

/**
 * g_atomic_int_inc:
 * @atomic: a pointer to a #gint or #guint
 *
 * Increments the value of @atomic by 1.
 *
 * Think of this operation as an atomic version of `{ *atomic += 1; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * Since: 2.4
 **/
void(g_atomic_int_inc)(volatile gint* atomic) {
	g_atomic_int_inc(atomic);
}

/**
 * g_atomic_int_dec_and_test:
 * @atomic: a pointer to a #gint or #guint
 *
 * Decrements the value of @atomic by 1.
 *
 * Think of this operation as an atomic version of
 * `{ *atomic -= 1; return (*atomic == 0); }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * Returns: %TRUE if the resultant value is zero
 *
 * Since: 2.4
 **/
gboolean(g_atomic_int_dec_and_test)(volatile gint* atomic) {
	return g_atomic_int_dec_and_test(atomic);
}

/**
 * g_atomic_int_compare_and_exchange:
 * @atomic: a pointer to a #gint or #guint
 * @oldval: the value to compare with
 * @newval: the value to conditionally replace with
 *
 * Compares @atomic to @oldval and, if equal, sets it to @newval.
 * If @atomic was not equal to @oldval then no change occurs.
 *
 * This compare and exchange is done atomically.
 *
 * Think of this operation as an atomic version of
 * `{ if (*atomic == oldval) { *atomic = newval; return TRUE; } else return FALSE; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * Returns: %TRUE if the exchange took place
 *
 * Since: 2.4
 **/
gboolean(g_atomic_int_compare_and_exchange)(volatile gint* atomic, gint oldval, gint newval) {
	return g_atomic_int_compare_and_exchange(atomic, oldval, newval);
}

/**
 * g_atomic_int_compare_and_exchange_full:
 * @atomic: a pointer to a #gint or #guint
 * @oldval: the value to compare with
 * @newval: the value to conditionally replace with
 * @preval: (out): the contents of @atomic before this operation
 *
 * Compares @atomic to @oldval and, if equal, sets it to @newval.
 * If @atomic was not equal to @oldval then no change occurs.
 * In any case the value of @atomic before this operation is stored in @preval.
 *
 * This compare and exchange is done atomically.
 *
 * Think of this operation as an atomic version of
 * `{ *preval = *atomic; if (*atomic == oldval) { *atomic = newval; return TRUE; } else return
 *FALSE; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * See also g_atomic_int_compare_and_exchange()
 *
 * Returns: %TRUE if the exchange took place
 *
 * Since: 2.74
 **/
gboolean(g_atomic_int_compare_and_exchange_full)(
	gint* atomic, gint oldval, gint newval, gint* preval
) {
	return g_atomic_int_compare_and_exchange_full(atomic, oldval, newval, preval);
}

/**
 * g_atomic_int_exchange:
 * @atomic: a pointer to a #gint or #guint
 * @newval: the value to replace with
 *
 * Sets the @atomic to @newval and returns the old value from @atomic.
 *
 * This exchange is done atomically.
 *
 * Think of this operation as an atomic version of
 * `{ tmp = *atomic; *atomic = val; return tmp; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * Returns: the value of @atomic before the exchange, signed
 *
 * Since: 2.74
 **/
gint(g_atomic_int_exchange)(gint* atomic, gint newval) {
	return g_atomic_int_exchange(atomic, newval);
}

/**
 * g_atomic_int_add:
 * @atomic: a pointer to a #gint or #guint
 * @val: the value to add
 *
 * Atomically adds @val to the value of @atomic.
 *
 * Think of this operation as an atomic version of
 * `{ tmp = *atomic; *atomic += val; return tmp; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * Before version 2.30, this function did not return a value
 * (but g_atomic_int_exchange_and_add() did, and had the same meaning).
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * Returns: the value of @atomic before the add, signed
 *
 * Since: 2.4
 **/
gint(g_atomic_int_add)(volatile gint* atomic, gint val) {
	return g_atomic_int_add(atomic, val);
}

/**
 * g_atomic_int_and:
 * @atomic: a pointer to a #gint or #guint
 * @val: the value to 'and'
 *
 * Performs an atomic bitwise 'and' of the value of @atomic and @val,
 * storing the result back in @atomic.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * Think of this operation as an atomic version of
 * `{ tmp = *atomic; *atomic &= val; return tmp; }`.
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * Returns: the value of @atomic before the operation, unsigned
 *
 * Since: 2.30
 **/
guint(g_atomic_int_and)(volatile guint* atomic, guint val) {
	return g_atomic_int_and(atomic, val);
}

/**
 * g_atomic_int_or:
 * @atomic: a pointer to a #gint or #guint
 * @val: the value to 'or'
 *
 * Performs an atomic bitwise 'or' of the value of @atomic and @val,
 * storing the result back in @atomic.
 *
 * Think of this operation as an atomic version of
 * `{ tmp = *atomic; *atomic |= val; return tmp; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * Returns: the value of @atomic before the operation, unsigned
 *
 * Since: 2.30
 **/
guint(g_atomic_int_or)(volatile guint* atomic, guint val) {
	return g_atomic_int_or(atomic, val);
}

/**
 * g_atomic_int_xor:
 * @atomic: a pointer to a #gint or #guint
 * @val: the value to 'xor'
 *
 * Performs an atomic bitwise 'xor' of the value of @atomic and @val,
 * storing the result back in @atomic.
 *
 * Think of this operation as an atomic version of
 * `{ tmp = *atomic; *atomic ^= val; return tmp; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * Returns: the value of @atomic before the operation, unsigned
 *
 * Since: 2.30
 **/
guint(g_atomic_int_xor)(volatile guint* atomic, guint val) {
	return g_atomic_int_xor(atomic, val);
}

/**
 * g_atomic_pointer_get:
 * @atomic: (not nullable): a pointer to a #gpointer-sized value
 *
 * Gets the current value of @atomic.
 *
 * This call acts as a full compiler and hardware
 * memory barrier (before the get).
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * Returns: the value of the pointer
 *
 * Since: 2.4
 **/
gpointer(g_atomic_pointer_get)(const volatile void* atomic) {
	return g_atomic_pointer_get((gpointer*)atomic);
}

/**
 * g_atomic_pointer_set:
 * @atomic: (not nullable): a pointer to a #gpointer-sized value
 * @newval: a new value to store
 *
 * Sets the value of @atomic to @newval.
 *
 * This call acts as a full compiler and hardware
 * memory barrier (after the set).
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * Since: 2.4
 **/
void(g_atomic_pointer_set)(volatile void* atomic, gpointer newval) {
	g_atomic_pointer_set((gpointer*)atomic, newval);
}

/**
 * g_atomic_pointer_compare_and_exchange:
 * @atomic: (not nullable): a pointer to a #gpointer-sized value
 * @oldval: the value to compare with
 * @newval: the value to conditionally replace with
 *
 * Compares @atomic to @oldval and, if equal, sets it to @newval.
 * If @atomic was not equal to @oldval then no change occurs.
 *
 * This compare and exchange is done atomically.
 *
 * Think of this operation as an atomic version of
 * `{ if (*atomic == oldval) { *atomic = newval; return TRUE; } else return FALSE; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * Returns: %TRUE if the exchange took place
 *
 * Since: 2.4
 **/
gboolean(g_atomic_pointer_compare_and_exchange)(
	volatile void* atomic, gpointer oldval, gpointer newval
) {
	return g_atomic_pointer_compare_and_exchange((gpointer*)atomic, oldval, newval);
}

/**
 * g_atomic_pointer_compare_and_exchange_full:
 * @atomic: (not nullable): a pointer to a #gpointer-sized value
 * @oldval: the value to compare with
 * @newval: the value to conditionally replace with
 * @preval: (not nullable) (out): the contents of @atomic before this operation
 *
 * Compares @atomic to @oldval and, if equal, sets it to @newval.
 * If @atomic was not equal to @oldval then no change occurs.
 * In any case the value of @atomic before this operation is stored in @preval.
 *
 * This compare and exchange is done atomically.
 *
 * Think of this operation as an atomic version of
 * `{ *preval = *atomic; if (*atomic == oldval) { *atomic = newval; return TRUE; } else return
 *FALSE; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * See also g_atomic_pointer_compare_and_exchange()
 *
 * Returns: %TRUE if the exchange took place
 *
 * Since: 2.74
 **/
gboolean(g_atomic_pointer_compare_and_exchange_full)(
	void* atomic, gpointer oldval, gpointer newval, void* preval
) {
	return g_atomic_pointer_compare_and_exchange_full(
		(gpointer*)atomic, oldval, newval, (gpointer*)preval
	);
}

/**
 * g_atomic_pointer_exchange:
 * @atomic: a pointer to a #gpointer-sized value
 * @newval: the value to replace with
 *
 * Sets the @atomic to @newval and returns the old value from @atomic.
 *
 * This exchange is done atomically.
 *
 * Think of this operation as an atomic version of
 * `{ tmp = *atomic; *atomic = val; return tmp; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * Returns: the value of @atomic before the exchange
 *
 * Since: 2.74
 **/
gpointer(g_atomic_pointer_exchange)(void* atomic, gpointer newval) {
	return g_atomic_pointer_exchange((gpointer*)atomic, newval);
}

/**
 * g_atomic_pointer_add:
 * @atomic: (not nullable): a pointer to a #gpointer-sized value
 * @val: the value to add
 *
 * Atomically adds @val to the value of @atomic.
 *
 * Think of this operation as an atomic version of
 * `{ tmp = *atomic; *atomic += val; return tmp; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * In GLib 2.80, the return type was changed from #gssize to #gintptr to add
 * support for platforms with 128-bit pointers. This should not affect existing
 * code.
 *
 * Returns: the value of @atomic before the add, signed
 *
 * Since: 2.30
 **/
gintptr(g_atomic_pointer_add)(volatile void* atomic, gssize val) {
	return g_atomic_pointer_add((gpointer*)atomic, val);
}

/**
 * g_atomic_pointer_and:
 * @atomic: (not nullable): a pointer to a #gpointer-sized value
 * @val: the value to 'and'
 *
 * Performs an atomic bitwise 'and' of the value of @atomic and @val,
 * storing the result back in @atomic.
 *
 * Think of this operation as an atomic version of
 * `{ tmp = *atomic; *atomic &= val; return tmp; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * In GLib 2.80, the return type was changed from #gsize to #guintptr to add
 * support for platforms with 128-bit pointers. This should not affect existing
 * code.
 *
 * Returns: the value of @atomic before the operation, unsigned
 *
 * Since: 2.30
 **/
guintptr(g_atomic_pointer_and)(volatile void* atomic, gsize val) {
	return g_atomic_pointer_and((gpointer*)atomic, val);
}

/**
 * g_atomic_pointer_or:
 * @atomic: (not nullable): a pointer to a #gpointer-sized value
 * @val: the value to 'or'
 *
 * Performs an atomic bitwise 'or' of the value of @atomic and @val,
 * storing the result back in @atomic.
 *
 * Think of this operation as an atomic version of
 * `{ tmp = *atomic; *atomic |= val; return tmp; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * In GLib 2.80, the return type was changed from #gsize to #guintptr to add
 * support for platforms with 128-bit pointers. This should not affect existing
 * code.
 *
 * Returns: the value of @atomic before the operation, unsigned
 *
 * Since: 2.30
 **/
guintptr(g_atomic_pointer_or)(volatile void* atomic, gsize val) {
	return g_atomic_pointer_or((gpointer*)atomic, val);
}

/**
 * g_atomic_pointer_xor:
 * @atomic: (not nullable): a pointer to a #gpointer-sized value
 * @val: the value to 'xor'
 *
 * Performs an atomic bitwise 'xor' of the value of @atomic and @val,
 * storing the result back in @atomic.
 *
 * Think of this operation as an atomic version of
 * `{ tmp = *atomic; *atomic ^= val; return tmp; }`.
 *
 * This call acts as a full compiler and hardware memory barrier.
 *
 * While @atomic has a `volatile` qualifier, this is a historical artifact and
 * the pointer passed to it should not be `volatile`.
 *
 * In GLib 2.80, the return type was changed from #gsize to #guintptr to add
 * support for platforms with 128-bit pointers. This should not affect existing
 * code.
 *
 * Returns: the value of @atomic before the operation, unsigned
 *
 * Since: 2.30
 **/
guintptr(g_atomic_pointer_xor)(volatile void* atomic, gsize val) {
	return g_atomic_pointer_xor((gpointer*)atomic, val);
}

	#elif defined(G_PLATFORM_WIN32)

		#include <windows.h>
		#if !defined(_M_AMD64) && !defined(_M_IA64) && !defined(_M_X64) \
			&& !(defined _MSC_VER && _MSC_VER <= 1200)
			#define InterlockedAnd _InterlockedAnd
			#define InterlockedOr  _InterlockedOr
			#define InterlockedXor _InterlockedXor
		#endif

		#if !defined(_MSC_VER) || _MSC_VER <= 1200
			#include "gmessages.h"

/* Inlined versions for older compiler */
static LONG _gInterlockedAnd(volatile guint* atomic, guint val) {
	LONG i, j;

	j = *atomic;
	do {
		i = j;
		j = InterlockedCompareExchange(atomic, i & val, i);
	} while (i != j);

	return j;
}

			#define InterlockedAnd(a, b) _gInterlockedAnd(a, b)

static LONG _gInterlockedOr(volatile guint* atomic, guint val) {
	LONG i, j;

	j = *atomic;
	do {
		i = j;
		j = InterlockedCompareExchange(atomic, i | val, i);
	} while (i != j);

	return j;
}

			#define InterlockedOr(a, b)  _gInterlockedOr(a, b)

static LONG _gInterlockedXor(volatile guint* atomic, guint val) {
	LONG i, j;

	j = *atomic;
	do {
		i = j;
		j = InterlockedCompareExchange(atomic, i ^ val, i);
	} while (i != j);

	return j;
}

			#define InterlockedXor(a, b) _gInterlockedXor(a, b)
		#endif

/*
 * http://msdn.microsoft.com/en-us/library/ms684122(v=vs.85).aspx
 */
gint(g_atomic_int_get)(const volatile gint* atomic) {
	MemoryBarrier();
	return *atomic;
}

void(g_atomic_int_set)(volatile gint* atomic, gint newval) {
	*atomic = newval;
	MemoryBarrier();
}

void(g_atomic_int_inc)(volatile gint* atomic) {
	InterlockedIncrement(atomic);
}

gboolean(g_atomic_int_dec_and_test)(volatile gint* atomic) {
	return InterlockedDecrement(atomic) == 0;
}

gboolean(g_atomic_int_compare_and_exchange)(volatile gint* atomic, gint oldval, gint newval) {
	return InterlockedCompareExchange(atomic, newval, oldval) == oldval;
}

gboolean(g_atomic_int_compare_and_exchange_full)(
	gint* atomic, gint oldval, gint newval, gint* preval
) {
	*preval = InterlockedCompareExchange(atomic, newval, oldval);
	return *preval == oldval;
}

gint(g_atomic_int_exchange)(gint* atomic, gint newval) {
	return InterlockedExchange(atomic, newval);
}

gint(g_atomic_int_add)(volatile gint* atomic, gint val) {
	return InterlockedExchangeAdd(atomic, val);
}

guint(g_atomic_int_and)(volatile guint* atomic, guint val) {
	return InterlockedAnd(atomic, val);
}

guint(g_atomic_int_or)(volatile guint* atomic, guint val) {
	return InterlockedOr(atomic, val);
}

guint(g_atomic_int_xor)(volatile guint* atomic, guint val) {
	return InterlockedXor(atomic, val);
}

gpointer(g_atomic_pointer_get)(const volatile void* atomic) {
	const gpointer* ptr = atomic;

	MemoryBarrier();
	return *ptr;
}

void(g_atomic_pointer_set)(volatile void* atomic, gpointer newval) {
	gpointer* ptr = atomic;

	*ptr          = newval;
	MemoryBarrier();
}

gboolean(g_atomic_pointer_compare_and_exchange)(
	volatile void* atomic, gpointer oldval, gpointer newval
) {
	return InterlockedCompareExchangePointer(atomic, newval, oldval) == oldval;
}

gboolean(g_atomic_pointer_compare_and_exchange_full)(
	void* atomic, gpointer oldval, gpointer newval, void* preval
) {
	gpointer* pre = preval;

	*pre          = InterlockedCompareExchangePointer(atomic, newval, oldval);

	return *pre == oldval;
}

gpointer(g_atomic_pointer_exchange)(void* atomic, gpointer newval) {
	return InterlockedExchangePointer(atomic, newval);
}

gintptr(g_atomic_pointer_add)(volatile void* atomic, gssize val) {
		#if GLIB_SIZEOF_VOID_P == 8
	return InterlockedExchangeAdd64(atomic, val);
		#else
	return InterlockedExchangeAdd(atomic, val);
		#endif
}

guintptr(g_atomic_pointer_and)(volatile void* atomic, gsize val) {
		#if GLIB_SIZEOF_VOID_P == 8
	return InterlockedAnd64(atomic, val);
		#else
	return InterlockedAnd(atomic, val);
		#endif
}

guintptr(g_atomic_pointer_or)(volatile void* atomic, gsize val) {
		#if GLIB_SIZEOF_VOID_P == 8
	return InterlockedOr64(atomic, val);
		#else
	return InterlockedOr(atomic, val);
		#endif
}

guintptr(g_atomic_pointer_xor)(volatile void* atomic, gsize val) {
		#if GLIB_SIZEOF_VOID_P == 8
	return InterlockedXor64(atomic, val);
		#else
	return InterlockedXor(atomic, val);
		#endif
}
	#else

		/* This error occurs when `meson configure` decided that we should be capable
	   * of lock-free atomics but we find at compile-time that we are not.
	   */
		#error G_ATOMIC_LOCK_FREE defined, but incapable of lock-free atomics.

	#endif /* defined (__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4) */

#else    /* G_ATOMIC_LOCK_FREE */

	/* We are not permitted to call into any GLib functions from here, so we
   * can not use GMutex.
   *
   * Fortunately, we already take care of the Windows case above, and all
   * non-Windows platforms on which glib runs have pthreads.  Use those.
   */
	#include <pthread.h>

static pthread_mutex_t g_atomic_lock = PTHREAD_MUTEX_INITIALIZER;

gint(g_atomic_int_get)(const volatile gint* atomic) {
	gint value;

	pthread_mutex_lock(&g_atomic_lock);
	value = *atomic;
	pthread_mutex_unlock(&g_atomic_lock);

	return value;
}

void(g_atomic_int_set)(volatile gint* atomic, gint value) {
	pthread_mutex_lock(&g_atomic_lock);
	*atomic = value;
	pthread_mutex_unlock(&g_atomic_lock);
}

void(g_atomic_int_inc)(volatile gint* atomic) {
	pthread_mutex_lock(&g_atomic_lock);
	(*atomic)++;
	pthread_mutex_unlock(&g_atomic_lock);
}

gboolean(g_atomic_int_dec_and_test)(volatile gint* atomic) {
	gboolean is_zero;

	pthread_mutex_lock(&g_atomic_lock);
	is_zero = --(*atomic) == 0;
	pthread_mutex_unlock(&g_atomic_lock);

	return is_zero;
}

gboolean(g_atomic_int_compare_and_exchange)(volatile gint* atomic, gint oldval, gint newval) {
	gboolean success;

	pthread_mutex_lock(&g_atomic_lock);

	if ((success = (*atomic == oldval))) {
		*atomic = newval;
	}

	pthread_mutex_unlock(&g_atomic_lock);

	return success;
}

gboolean(g_atomic_int_compare_and_exchange_full)(
	gint* atomic, gint oldval, gint newval, gint* preval
) {
	gboolean success;

	pthread_mutex_lock(&g_atomic_lock);

	*preval = *atomic;

	if ((success = (*atomic == oldval))) {
		*atomic = newval;
	}

	pthread_mutex_unlock(&g_atomic_lock);

	return success;
}

gint(g_atomic_int_exchange)(gint* atomic, gint newval) {
	gint* ptr = atomic;
	gint  oldval;

	pthread_mutex_lock(&g_atomic_lock);
	oldval = *ptr;
	*ptr   = newval;
	pthread_mutex_unlock(&g_atomic_lock);

	return oldval;
}

gint(g_atomic_int_add)(volatile gint* atomic, gint val) {
	gint oldval;

	pthread_mutex_lock(&g_atomic_lock);
	oldval  = *atomic;
	*atomic = oldval + val;
	pthread_mutex_unlock(&g_atomic_lock);

	return oldval;
}

guint(g_atomic_int_and)(volatile guint* atomic, guint val) {
	guint oldval;

	pthread_mutex_lock(&g_atomic_lock);
	oldval  = *atomic;
	*atomic = oldval & val;
	pthread_mutex_unlock(&g_atomic_lock);

	return oldval;
}

guint(g_atomic_int_or)(volatile guint* atomic, guint val) {
	guint oldval;

	pthread_mutex_lock(&g_atomic_lock);
	oldval  = *atomic;
	*atomic = oldval | val;
	pthread_mutex_unlock(&g_atomic_lock);

	return oldval;
}

guint(g_atomic_int_xor)(volatile guint* atomic, guint val) {
	guint oldval;

	pthread_mutex_lock(&g_atomic_lock);
	oldval  = *atomic;
	*atomic = oldval ^ val;
	pthread_mutex_unlock(&g_atomic_lock);

	return oldval;
}

gpointer(g_atomic_pointer_get)(const volatile void* atomic) {
	const gpointer* ptr = atomic;
	gpointer        value;

	pthread_mutex_lock(&g_atomic_lock);
	value = *ptr;
	pthread_mutex_unlock(&g_atomic_lock);

	return value;
}

void(g_atomic_pointer_set)(volatile void* atomic, gpointer newval) {
	gpointer* ptr = atomic;

	pthread_mutex_lock(&g_atomic_lock);
	*ptr = newval;
	pthread_mutex_unlock(&g_atomic_lock);
}

gboolean(g_atomic_pointer_compare_and_exchange)(
	volatile void* atomic, gpointer oldval, gpointer newval
) {
	gpointer* ptr = atomic;
	gboolean  success;

	pthread_mutex_lock(&g_atomic_lock);

	if ((success = (*ptr == oldval))) {
		*ptr = newval;
	}

	pthread_mutex_unlock(&g_atomic_lock);

	return success;
}

gboolean(g_atomic_pointer_compare_and_exchange_full)(
	void* atomic, gpointer oldval, gpointer newval, void* preval
) {
	gpointer* ptr = atomic;
	gpointer* pre = preval;
	gboolean  success;

	pthread_mutex_lock(&g_atomic_lock);

	*pre = *ptr;
	if ((success = (*ptr == oldval))) {
		*ptr = newval;
	}

	pthread_mutex_unlock(&g_atomic_lock);

	return success;
}

gpointer(g_atomic_pointer_exchange)(void* atomic, gpointer newval) {
	gpointer* ptr = atomic;
	gpointer  oldval;

	pthread_mutex_lock(&g_atomic_lock);
	oldval = *ptr;
	*ptr   = newval;
	pthread_mutex_unlock(&g_atomic_lock);

	return oldval;
}

gintptr(g_atomic_pointer_add)(volatile void* atomic, gssize val) {
	gintptr* ptr = atomic;
	gintptr  oldval;

	pthread_mutex_lock(&g_atomic_lock);
	oldval = *ptr;
	*ptr   = oldval + val;
	pthread_mutex_unlock(&g_atomic_lock);

	return oldval;
}

guintptr(g_atomic_pointer_and)(volatile void* atomic, gsize val) {
	guintptr* ptr = atomic;
	guintptr  oldval;

	pthread_mutex_lock(&g_atomic_lock);
	oldval = *ptr;
	*ptr   = oldval & val;
	pthread_mutex_unlock(&g_atomic_lock);

	return oldval;
}

guintptr(g_atomic_pointer_or)(volatile void* atomic, gsize val) {
	guintptr* ptr = atomic;
	guintptr  oldval;

	pthread_mutex_lock(&g_atomic_lock);
	oldval = *ptr;
	*ptr   = oldval | val;
	pthread_mutex_unlock(&g_atomic_lock);

	return oldval;
}

guintptr(g_atomic_pointer_xor)(volatile void* atomic, gsize val) {
	guintptr* ptr = atomic;
	guintptr  oldval;

	pthread_mutex_lock(&g_atomic_lock);
	oldval = *ptr;
	*ptr   = oldval ^ val;
	pthread_mutex_unlock(&g_atomic_lock);

	return oldval;
}

#endif

/**
 * g_atomic_int_exchange_and_add:
 * @atomic: a pointer to a #gint
 * @val: the value to add
 *
 * This function existed before g_atomic_int_add() returned the prior
 * value of the integer (which it now does).  It is retained only for
 * compatibility reasons.  Don't use this function in new code.
 *
 * Returns: the value of @atomic before the add, signed
 * Since: 2.4
 * Deprecated: 2.30: Use g_atomic_int_add() instead.
 **/
gint g_atomic_int_exchange_and_add(volatile gint* atomic, gint val) {
	return (g_atomic_int_add)((gint*)atomic, val);
}
