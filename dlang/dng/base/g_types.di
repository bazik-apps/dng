module dng.base.g_types;
extern (C) __gshared @nogc nothrow @safe:

import core.stdc.config: c_long;

alias GF_Compare = int function(const(void)* a, const(void)* b);
alias GF_Data_Compare = int function(const(void)* a, const(void)* b, void* user_data);
alias GF_Equals = bool function(const(void)* a, const(void)* b);

/***
 * GF_Data_Equals:
 * @a: a value
 * @b: a value to compare with
 * @user_data: user data provided by the caller
 *
 * Specifies the type of a function used to test two values for
 * equality. The function should return %TRUE if both values are equal
 * and %FALSE otherwise.
 *
 * This is a version of #GF_Equals which provides a @user_data closure from
 * the caller.
 *
 * Returns: %TRUE if @a = @b; %FALSE otherwise */
alias GF_Data_Equals = bool function(const(void)* a, const(void)* b, void* user_data);

alias GF_Destroy_Notify = void function(void* data);
alias GF_Iter_List = void function(void* data, void* user_data);
alias GF_New_Hash = uint function(const(void)* key);
alias GF_Iter_Hash = void function(void* key, void* value, void* user_data);

/***
 * GF_Copy:
 * @src: (not nullable): A pointer to the data which should be copied
 * @data: Additional data
 *
 * A function of this signature is used to copy the node data
 * when doing a deep-copy of a tree.
 *
 * Returns: (not nullable): A pointer to the copy */
alias GF_Copy = void* function(const(void)* src, void* data);

/***
 * GF_Translate:
 * @str: the untranslated string
 * @data: user data specified when installing the function, e.g.
 *  in g_option_group_set_translate_func()
 *
 * The type of functions which are used to translate user-visible
 * strings, for <option>--help</option> output.
 *
 * Returns: a translation of the string for the current locale.
 *  The returned string is owned by GLib and must not be freed. */
alias GF_Translate = string function(string str, void* data);

/***
 * Define some mathematical constants that aren_t available
 * symbolically in some strict ISO C implementations.
 *
 * Note that the large number of digits used in these definitions
 * doesn_t imply that GLib or current computers in general would be
 * able to handle floating point numbers with an accuracy like this.
 * It_s mostly an exercise in futility and future proofing. For
 * extended precision floating point support, look somewhere else
 * than GLib. */
enum G_E = 2.7182818284590452353602874713526624977572470937000;
enum G_LN2 = 0.69314718055994530941723212145817656807550013436026;
enum G_LN10 = 2.3025850929940456840179914546843642076011014886288;
enum G_PI = 3.1415926535897932384626433832795028841971693993751;
enum G_PI_2 = 1.5707963267948966192313216916397514420985846996876;
enum G_PI_4 = 0.78539816339744830961566084581987572104929234984378;
enum G_SQRT2 = 1.4142135623730950488016887242096980785696718753769;

/***
 * Portable endian checks and conversions */
enum G_LITTLE_ENDIAN = 1234;
enum G_BIG_ENDIAN = 4321;
enum G_PDP_ENDIAN = 3412; // unused, need specific PDP check

/***
 * Basic bit swapping templates */
//dfmt off
template SWAP_LE_BE(alias val) if (typeof(val).sizeof == 2) {
	enum typeof(val) SWAP_LE_BE = cast(typeof(val))(
		cast(typeof(val))(val << 8) |
		cast(typeof(val))(val >> 8)
	);
}

template SWAP_LE_BE(alias val) if (typeof(val).sizeof == 4) {
	enum typeof(val) SWAP_LE_BE = cast(typeof(val))(
		((val & 0x000000ff) << 24) |
		((val & 0x0000ff00) <<  8) |
		((val & 0x00ff0000) >>  8) |
		((val & 0xff000000) >> 24)
	);
}

template SWAP_LE_BE(alias val) if (typeof(val).sizeof == 8) {
	enum typeof(val) SWAP_LE_BE = cast(typeof(val))(
		((val & 0x00000000000000ffL) << 56) |
		((val & 0x000000000000ff00L) << 40) |
		((val & 0x0000000000ff0000L) << 24) |
		((val & 0x00000000ff000000L) <<  8) |
		((val & 0x000000ff00000000L) >>  8) |
		((val & 0x0000ff0000000000L) >> 24) |
		((val & 0x00ff000000000000L) >> 40) |
		((val & 0xff00000000000000L) >> 56)
	);
}
// dfmt on

static pragma(inline, true) bool g_uint32_checked_add(uint* dest, uint a, uint b) {
	*dest = a + b;
	return *dest >= a;
}

static pragma(inline, true) bool g_uint32_checked_mul(uint* dest, uint a, uint b) {
	*dest = a * b;
	return !a || *dest / a == b;
}

static pragma(inline, true) bool g_uint64_checked_add(ulong* dest, ulong a, ulong b) {
	*dest = a + b;
	return *dest >= a;
}

static pragma(inline, true) bool g_uint64_checked_mul(ulong* dest, ulong a, ulong b) {
	*dest = a * b;
	return !a || *dest / a == b;
}

static pragma(inline, true) bool g_size_checked_add(size_t* dest, size_t a, size_t b) {
	*dest = a + b;
	return *dest >= a;
}

static pragma(inline, true) bool g_size_checked_mul(size_t* dest, size_t a, size_t b) {
	*dest = a * b;
	return !a || *dest / a == b;
}

/* IEEE Standard 754 Single Precision Storage Format (float):
 *
 *        31 30           23 22            0
 * +--------+---------------+---------------+
 * | s 1bit | e[30:23] 8bit | f[22:0] 23bit |
 * +--------+---------------+---------------+
 * B0------------------->B1------->B2-->B3-->
 *
 * IEEE Standard 754 Double Precision Storage Format (double):
 *
 *        63 62            52 51            32   31            0
 * +--------+----------------+----------------+ +---------------+
 * | s 1bit | e[62:52] 11bit | f[51:32] 20bit | | f[31:0] 32bit |
 * +--------+----------------+----------------+ +---------------+
 * B0--------------->B1---------->B2--->B3---->  B4->B5->B6->B7-> */

/***
 * subtract from biased_exponent to form base2 exponent (normal numbers) */
enum G_IEEE754_FLOAT_BIAS = 127;
enum G_IEEE754_DOUBLE_BIAS = 1023;

/***
 * multiply with base2 exponent to get base10 exponent (normal numbers) */
enum G_LOG_2_BASE_10 = 0.30102999566398119521;

version (LittleEndian) {
	union G_Float_IEEE754 {
		float v_float;
		struct mpn {
			uint mantissa : 23;
			uint biased_exponent : 8;
			uint sign : 1;
		}
	}

	union G_Double_IEEE754 {
		double v_double;
		struct mpn {
			uint mantissa_low : 32;
			uint mantissa_high : 20;
			uint biased_exponent : 11;
			uint sign : 1;
		}
	}
}
else version (BigEndian) {
	union G_Float_IEEE754 {
		float v_float;
		struct mpn {
			uint sign : 1;
			uint biased_exponent : 8;
			uint mantissa : 23;
		}
	}

	union G_Double_IEEE754 {
		double v_double;
		struct mpn {
			uint sign : 1;
			uint biased_exponent : 11;
			uint mantissa_high : 20;
			uint mantissa_low : 32;
		}
	}
}
else {
	pragma(msg, "unknown ENDIAN type");
	static assert(0);
}

enum string G_DEPRECATED_FOR(f) = "Use '" ~ __traits(fullyQualifiedName, f) ~ "' instead";

alias G_Refcount = shared int; // atomic
