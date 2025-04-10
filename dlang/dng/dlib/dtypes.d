module dlang.dng.dlib.dtypes;

import core.stdc.time;

extern (C):

alias gchar = byte;
alias gshort = short;
alias glong = long;
alias gint = int;
alias gboolean = bool;

alias guchar = ubyte;
alias gushort = ushort;
alias gulong = ulong;
alias guint = uint;

alias gfloat = float;
alias gdouble = double;

alias gpointer = void*;
alias gconstpointer = const void*;

/* Define some mathematical constants that aren't available
 * symbolically in some strict ISO C implementations.
 *
 * Note that the large number of digits used in these definitions
 * doesn't imply that GLib or current computers in general would be
 * able to handle floating point numbers with an accuracy like this.
 * It's mostly an exercise in futility and future proofing. For
 * extended precision floating point support, look somewhere else
 * than GLib. */
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
