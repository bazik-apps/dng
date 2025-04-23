module dlang.dng.test.slicing;
extern (C) __gshared nothrow:

struct GArray(T) {
	T* data;
	size_t len;
}

T g_array_index(T)(GArray!T a, size_t i) {
	return a.data[i];
}

GArray!T g_array_new(T)() {
	return GArray!T([0,1,2,3,4].ptr, 5);
}

void main() {
	import core.stdc.stdio: printf;

	auto g_arr = g_array_new!int();
	auto value_at_2 = g_array_index!int(g_arr,2);
	printf("value_at_2 = %d\n",value_at_2);

	//int* elem1 = 5;
	int[10] arr = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
	size_t len = 6;
	int[6] slice = cast(int[6])(arr.ptr)[0 .. 6];
	foreach (i, element; slice) {
		printf("arr[%ld] = %d\n", i, element);
	}
}
