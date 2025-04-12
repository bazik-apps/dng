module dng.dlib.dtypes;

import core.stdc.time;
import dng.test.nopromote;

extern (C):

alias DPtr = void*;
alias DConstPtr = const(void)*;

alias DFCompare = int function(DConstPtr a, DConstPtr b);
alias DFDataCompare = int function(DConstPtr a, DConstPtr b, DPtr uData);
alias DFEquals = bool function(DConstPtr a, DConstPtr b);

/***
 * df_data_equals:
 * @a: a value
 * @b: a value to compare with
 * @uData: data provided by the caller
 *
 * Specifies the type of a function used to test two values for
 * equality. The function should return %TRUE if both values are equal
 * and %FALSE otherwise.
 *
 * This is a version of #df_equals which provides a @uData closure from
 * the caller.
 *
 * Returns: %TRUE if @a = @b; %FALSE otherwise */
alias DFDataEquals = bool function(DConstPtr a, DConstPtr b, DPtr uData);

alias DFDestroyNotify = void function(DPtr eData);
alias DFIterList = void function(DPtr eData, DPtr uData);
alias DFNewHash = int function(DConstPtr key);
alias DFIterHash = void function(DPtr key, DPtr value, DPtr uData);

/***
 * GCopyFunc:
 * @src: (not nullable): A pointer to the data which should be copied
 * @data: Additional data
 *
 * A function of this signature is used to copy the node data
 * when doing a deep-copy of a tree.
 *
 * Returns: (not nullable): A pointer to the copy */
alias DFCopy = DPtr function(DConstPtr src, DPtr eData);

/***
 * DFFree:
 * @data: a data pointer
 *
 * Declares a type of function which takes an arbitrary
 * data pointer argument and has no return value.
 * It is not currently used in DLib. */
alias DFFree = void function(DPtr data);

/***
 * DFTranslate:
 * @str: the untranslated string
 * @uData: user data specified when installing the function, e.g.
 *  in d_option_group_set_translate()
 *
 * The type of functions which are used to translate user-visible
 * strings, for <option>--help</option> output.
 *
 * Returns: a translation of the string for the current locale.
 * The returned string is owned by DLib and must not be freed. */
alias DFTranslate = const(char)* function(const(char)* str, DPtr uData);

/* Define some mathematical constants that aren't available
 * symbolically in some strict ISO C implementations.
 *
 * Note that the large number of digits used in these definitions
 * doesn't imply that DLib or current computers in general would be
 * able to handle floating point numbers with an accuracy like this.
 * It's mostly an exercise in futility and future proofing. */
enum G_E = 2.7182818284590452353602874713526624977572470937000;
enum G_LN2 = 0.69314718055994530941723212145817656807550013436026;
enum G_LN10 = 2.3025850929940456840179914546843642076011014886288;
enum G_PI = 3.1415926535897932384626433832795028841971693993751;
enum G_PI_2 = 1.5707963267948966192313216916397514420985846996876;
enum G_PI_4 = 0.78539816339744830961566084581987572104929234984378;
enum G_SQRT2 = 1.4142135623730950488016887242096980785696718753769;

/* Basic bit swapping templates */
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
	union GFloatIEEE754 {
		float v_float;
		struct mpn {
			uint mantissa : 23;
			uint biased_exponent : 8;
			uint sign : 1;
		}
	}

	union GDoubleIEEE754 {
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
	union GFloatIEEE754 {
		float v_float;
		struct mpn {
			uint sign : 1;
			uint biased_exponent : 8;
			uint mantissa : 23;
		}
	}

	union GDoubleIEEE754 {
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

alias DRefCount = int;
alias DAtomicRefCount = int; // should be accessed only using atomics
