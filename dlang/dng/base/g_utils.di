module dng.base.g_utils;
extern (C) __gshared @nogc nothrow @safe:

pragma(scanf) void g_set_user_dirs(const gchar* first_dir_type, ...);

/* Returns the smallest power of 2 greater than or equal to n,
 * or 0 if such power does not fit in a size_t
 */
pragma(inline, true) size_t g_nearest_pow(size_t num) {
	size_t n = num - 1;

	assert(num > 0 && num <= G_MAXSIZE / 2);

	n |= n >> 1;
	n |= n >> 2;
	n |= n >> 4;
	n |= n >> 8;
	n |= n >> 16;
	static if (size_t.sizeof == 8) {
		n |= n >> 32;
	}

	return n + 1;
}

void _g_unset_cached_tmp_dir();

bool _g_localtime(time_t time_, tm* tm);

bool g_set_prgname_once(string prog_name);
