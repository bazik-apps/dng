module dlang.dng.dlib.dtypes;

import core.stdc.time;

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

/* Portable endian checks and conversions
 *
 * glibconfig.h defines G_BYTE_ORDER which expands to one of
 * the below macros. */
enum G_LITTLE_ENDIAN = 1234;
enum G_BIG_ENDIAN = 4321;
enum G_PDP_ENDIAN = 3412; /* unused, need specific PDP check */

/* Basic bit swapping functions */
enum ushort GUINT16_SWAP_LE_BE_CONSTANT(ushort val) = (val >> 8) | (val << 8);

// dfmt off
enum uint GUINT32_SWAP_LE_BE_CONSTANT(uint val) =
	((val & 0x000000ffU) << 24) |
	((val & 0x0000ff00U) <<  8) |
	((val & 0x00ff0000U) >>  8) |
	((val & 0xff000000U) >> 24);

enum ulong GUINT64_SWAP_LE_BE_CONSTANT(ulong val) =
	((val & 0x00000000000000ffUL) << 56) |
	((val & 0x000000000000ff00UL) << 40) |
	((val & 0x0000000000ff0000UL) << 24) |
	((val & 0x00000000ff000000UL) <<  8) |
	((val & 0x000000ff00000000UL) >>  8) |
	((val & 0x0000ff0000000000UL) >> 24) |
	((val & 0x00ff000000000000UL) >> 40) |
	((val & 0xff00000000000000UL) >> 56);
// dfmt on
