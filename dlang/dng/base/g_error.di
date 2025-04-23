module dng.base.g_error;
extern (C) __gshared @nogc nothrow @safe:

import core.stdc.stdarg: va_list;
import dng.base.g_quark: G_Quark;

/***
 * G_Error:
 * @domain: error domain, e.g. %G_FILE_ERROR
 * @err_code: error err_code, e.g. %G_FILE_ERROR_NOENT
 * @message: human-readable informative error message
 *
 * The `G_Error` structure contains information about
 * an error that has occurred. */
struct G_Error {
	G_Quark domain;
	int err_code;
	string message;
}

/***
 * G_DEFINE_EXTENDED_ERROR:
 * @ErrorType: name to return a #G_Quark for
 * @error_type: prefix for the function name
 *
 * A convenience macro which defines two functions. First, returning
 * the #G_Quark for the extended error type @ErrorType; it is called
 * `error_type_quark()`. Second, returning the private data from a
 * passed #G_Error; it is called `error_type_get_private()`.
 *
 * For this macro to work, a type named `ErrorTypePrivate` should be
 * defined, `error_type_private_init()`, `error_type_private_copy()`
 * and `error_type_private_clear()` functions need to be either
 * declared or defined. The functions should be similar to
 * #GErrorInitFunc, #GErrorCopyFunc and #GErrorClearFunc,
 * respectively, but they should receive the private data type instead
 * of #G_Error.
 *
 * See [Extended #G_Error Domains](error-reporting.html#extended-gerror-domains) for an example. */
// template G_DEFINE_EXTENDED_ERROR(ErrorType, error_type)                              {
// 	static inline ErrorType##Private* error_type##_get_private(const G_Error* error) {
// 		/* Copied from gtype.c (STRUCT_ALIGNMENT and ALIGN_STRUCT macros). */
// 		const size_t sa = 2 * sizeof(size_t);
// 		const size_t as = (sizeof(ErrorType##Private) + (sa - 1)) & -sa;
// 		g_return_val_if_fail(error != NULL, NULL);
// 		g_return_val_if_fail(error.domain == error_type##_quark(), NULL);
// 		return (ErrorType##Private*)(((guint8*)error) - as);
// 	}

// 	static void g_error_with_##error_type##_private_init(G_Error* error) {
// 		ErrorType##Private* priv = error_type##_get_private(error);
// 		error_type##_private_init(priv);
// 	}

// 	static void g_error_with_##error_type##_private_copy(
// 		const G_Error* src_error, G_Error* dest_error
// 	) {
// 		const ErrorType##Private* src_priv  = error_type##_get_private(src_error);
// 		ErrorType##Private*       dest_priv = error_type##_get_private(dest_error);
// 		error_type##_private_copy(src_priv, dest_priv);
// 	}

// 	static void g_error_with_##error_type##_private_clear(G_Error* error) {
// 		ErrorType##Private* priv = error_type##_get_private(error);
// 		error_type##_private_clear(priv);
// 	}

// 	G_Quark error_type##_quark(void) {
// 		static G_Quark q;
// 		static size_t  initialized = 0;

// 		if (g_once_init_enter(&initialized)) {
// 			q = g_error_domain_register_static(
// 				#ErrorType,
// 				sizeof(ErrorType##Private),
// 				g_error_with_##error_type##_private_init,
// 				g_error_with_##error_type##_private_copy,
// 				g_error_with_##error_type##_private_clear
// 			);
// 			g_once_init_leave(&initialized, 1);
// 		}

// 		return q;
// 	}
// }

/***
 * GErrorInitFunc:
 * @error: extended error
 *
 * Specifies the type of function which is called just after an
 * extended error instance is created and its fields filled. It should
 * only initialize the fields in the private data, which can be
 * received with the generated `*_get_private()` function.
 *
 * Normally, it is better to use G_DEFINE_EXTENDED_ERROR(), as it
 * already takes care of getting the private data from @error. */
alias GErrorInitFunc = void function(G_Error* error);

/***
 * GErrorCopyFunc:
 * @src_error: source extended error
 * @dest_error: destination extended error
 *
 * Specifies the type of function which is called when an extended
 * error instance is copied. It is passed the pointer to the
 * destination error and source error, and should copy only the fields
 * of the private data from @src_error to @dest_error.
 *
 * Normally, it is better to use G_DEFINE_EXTENDED_ERROR(), as it
 * already takes care of getting the private data from @src_error and
 * @dest_error. */
alias GErrorCopyFunc = void function(const G_Error* src_error, G_Error* dest_error);

/***
 * GErrorClearFunc:
 * @error: extended error to clear
 *
 * Specifies the type of function which is called when an extended
 * error instance is freed. It is passed the error pointer about to be
 * freed, and should free the error's private data fields.
 *
 * Normally, it is better to use G_DEFINE_EXTENDED_ERROR(), as it
 * already takes care of getting the private data from @error. */
alias GErrorClearFunc = void function(G_Error* error);

//dfmt off
G_Quark g_error_domain_register_static(
	const char*     error_type_name,
	size_t           error_type_private_size,
	GErrorInitFunc  error_type_init,
	GErrorCopyFunc  error_type_copy,
	GErrorClearFunc error_type_clear
);

G_Quark g_error_domain_register(
	const char*     error_type_name,
	size_t           error_type_private_size,
	GErrorInitFunc  error_type_init,
	GErrorCopyFunc  error_type_copy,
	GErrorClearFunc error_type_clear
);
//dfmt on

pragma(printf) G_Error* g_error_new(G_Quark domain, int err_code, const(char)* format, ...);

G_Error* g_error_new_literal(G_Quark domain, int err_code, string message);

pragma(printf) G_Error* g_error_new_valist(G_Quark domain, int err_code, const(char)* format, va_list args);

void g_error_free(G_Error* error);

G_Error* g_error_copy(const G_Error* error);

bool g_error_matches(const G_Error* error, G_Quark domain, int err_code);

/***
 * if (err) *err = g_error_new(domain, err_code, format, ...), also has
 * some sanity checks. */
pragma(printf) void g_set_error(G_Error** err, G_Quark domain, int err_code, const(char)* format, ...);

void g_set_error_literal(G_Error** err, G_Quark domain, int err_code, string message);

/***
 * if (dest) *dest = src; also has some sanity checks. */
void g_propagate_error(G_Error** dest, G_Error* src);

/***
 * if (err && *err) { g_error_free(*err); *err = NULL; } */
void g_clear_error(G_Error** err);

/***
 * if (err) prefix the formatted string to the .message */
pragma(printf) void g_prefix_error(G_Error** err, const(char)* format, ...);

/***
 * if (err) prefix the string to the .message */
void g_prefix_error_literal(G_Error** err, string prefix);

/***
 * g_propagate_error then g_error_prefix on dest */
pragma(printf) void g_propagate_prefixed_error(G_Error** dest, G_Error* src, const(char)* format, ...);
