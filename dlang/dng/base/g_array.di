module dng.base.g_array;
extern (C) __gshared @nogc nothrow @safe:

import dng.base.g_types;

struct G_Bytes;

struct G_Array(T) {
	T* data;
	size_t len;
}

struct G_Byte_Array {
	ubyte* data;
	size_t len;
}

struct G_Ptr_Array(T) {
	T** ptr_data;
	size_t len;
}

struct _GRealArray {
	guint8*         data;
	guint           len;
	guint           elt_capacity;
	guint           elt_size;
	guint           zero_terminated : 1;
	guint           clear           : 1;
	gatomicrefcount ref_count;
	GDestroyNotify  clear_func;
}

struct _GRealPtrArray {
	gpointer*       pdata;
	guint           len;
	guint           alloc;
	gatomicrefcount ref_count;
	guint8 null_terminated : 1; /* always either 0 or 1, so it can be added to array lengths */
	GDestroyNotify element_free_func;
}


/* Resizable arrays. remove fills any cleared spot and shortens the
 * arr, while preserving the order. remove_fast will distort the
 * order by moving the last element to the position of the removed.
 */

enum g_array_append_val(a, v) = g_array_append_vals(a, &(v), 1);
enum g_array_prepend_val(a, v) = g_array_prepend_vals(a, &(v), 1);
enum g_array_insert_val(a, i, v) = g_array_insert_vals(a, i, &(v), 1);
enum T g_array_index(G_Array!T a, size_t i) = a.data[i];

G_Array!T* g_array_new(T)(bool null_terminated, bool clear_);

G_Array!T* g_array_new_take(T)(void* data, size_t len, bool clear);

G_Array!T* g_array_new_take_null_terminated(T)(void* data, bool clear);

void* g_array_steal(T)(G_Array!T* arr, size_t* len);

G_Array!T* g_array_sized_new(T)(bool null_terminated, bool clear_, size_t reserved_size);

G_Array!T* g_array_copy(T)(G_Array!T* array);

byte* g_array_free(T)(G_Array!T* arr, bool free_segment);

G_Array!T* g_array_ref(T)(G_Array!T* array);

void g_array_unref(T)(G_Array!T* array);

size_t g_array_get_element_size(T)(G_Array!T* array);

G_Array!T* g_array_append_vals(T)(G_Array!T* arr, const(void)* data, size_t len);

G_Array!T* g_array_prepend_vals(T)(G_Array!T* arr, const(void)* data, size_t len);

G_Array!T* g_array_insert_vals(T)(G_Array!T* arr, size_t index_, const(void)* data, size_t len);

G_Array!T* g_array_set_size(T)(G_Array!T* arr, size_t length);

G_Array!T* g_array_remove_index(T)(G_Array!T* arr, size_t index_);

G_Array!T* g_array_remove_index_fast(T)(G_Array!T* arr, size_t index_);

G_Array!T* g_array_remove_range(T)(G_Array!T* arr, size_t index_, size_t length);

void g_array_sort(T)(G_Array!T* arr, GF_Compare compare_func);

void g_array_sort_with_data(T)(G_Array!T* arr, GF_Data_Compare compare_func, void* user_data);

bool g_array_binary_search(T)(G_Array!T* arr, const(void)* target,
	GF_Compare compare_func, size_t* out_match_index);

void g_array_set_free_func(T)(G_Array!T* arr, GF_Destroy_Notify free_func);

/***
 * Resizable pointer array. This interface is much less complicated
 * than the above. Add appends a pointer. Remove fills any cleared
 * spot and shortens the array. remove_fast will again distort order. */
enum g_ptr_array_index(G_Ptr_Array!T arr, size_t index_) = array.ptr_data[index_];

G_Ptr_Array!T* g_ptr_array_new();

G_Ptr_Array!T* g_ptr_array_new_with_free_func(GF_Destroy_Notify free_func);

G_Ptr_Array!T* g_ptr_array_new_take(void** data, size_t len, GF_Destroy_Notify free_func);

G_Ptr_Array!T* g_ptr_array_new_from_array(void** data, size_t len,
	GF_Copy copy_func, void* copy_func_user_data, GF_Destroy_Notify free_func);

void** g_ptr_array_steal(G_Ptr_Array!T* arr, size_t* len);

G_Ptr_Array!T* g_ptr_array_copy(G_Ptr_Array!T* arr, GF_Copy func, void* user_data);

G_Ptr_Array!T* g_ptr_array_sized_new(size_t reserved_size);

G_Ptr_Array!T* g_ptr_array_new_full(size_t reserved_size, GF_Destroy_Notify free_func);

G_Ptr_Array!T* g_ptr_array_new_null_terminated(size_t reserved_size,
	GF_Destroy_Notify free_func, bool null_terminated);

G_Ptr_Array!T* g_ptr_array_new_take_null_terminated(void** data,
	GF_Destroy_Notify free_func);

G_Ptr_Array!T* g_ptr_array_new_from_null_terminated_array(void** data,
	GF_Copy copy_func, void* copy_func_user_data, GF_Destroy_Notify free_func);

void** g_ptr_array_free(G_Ptr_Array!T* arr, bool free_segment);

G_Ptr_Array!T* g_ptr_array_ref(G_Ptr_Array!T* array);

void g_ptr_array_unref(G_Ptr_Array!T* array);

void g_ptr_array_set_size(G_Ptr_Array!T* arr, gint length);

void* g_ptr_array_remove_index(G_Ptr_Array!T* arr, size_t index_);

void* g_ptr_array_remove_index_fast(G_Ptr_Array!T* arr, size_t index_);

void* g_ptr_array_steal_index(G_Ptr_Array!T* arr, size_t index_);

void* g_ptr_array_steal_index_fast(G_Ptr_Array!T* arr, size_t index_);

bool g_ptr_array_remove(G_Ptr_Array!T* arr, void* data);

bool g_ptr_array_remove_fast(G_Ptr_Array!T* arr, void* data);

G_Ptr_Array!T* g_ptr_array_remove_range(G_Ptr_Array!T* arr, size_t index_, size_t length);

void g_ptr_array_add(G_Ptr_Array!T* arr, void* data);

void g_ptr_array_extend(G_Ptr_Array!T* array_to_extend, G_Ptr_Array!T* arr,
	GF_Copy func, void* user_data);

void g_ptr_array_extend_and_steal(G_Ptr_Array!T* array_to_extend, G_Ptr_Array!T* array);

void g_ptr_array_insert(G_Ptr_Array!T* arr, gint index_, void* data);

void g_ptr_array_sort(G_Ptr_Array!T* arr, GF_Compare compare_func);

void g_ptr_array_sort_with_data(G_Ptr_Array!T* arr, GF_Data_Compare compare_func, void* user_data);

void g_ptr_array_sort_values(G_Ptr_Array!T* arr, GF_Compare compare_func);

void g_ptr_array_sort_values_with_data(G_Ptr_Array!T* arr,
	GF_Data_Compare compare_func, void* user_data);

void g_ptr_array_foreach(G_Ptr_Array!T* arr, GFunc func, void* user_data);

bool g_ptr_array_find(G_Ptr_Array!T* haystack, const(void)* needle, size_t* index_);

bool g_ptr_array_find_with_equal_func(G_Ptr_Array!T* haystack,
	const(void)* needle, GEqualFunc equal_func, size_t* index_);

bool g_ptr_array_is_null_terminated(G_Ptr_Array!T* array);

/* Byte arrays, an array of ubyte.  Implemented as a G_Array,
 * but type-safe.
 */

G_Byte_Array* g_byte_array_new(void);

G_Byte_Array* g_byte_array_new_take(ubyte* data, size_t len);

ubyte* g_byte_array_steal(G_Byte_Array* arr, size_t* len);

G_Byte_Array* g_byte_array_sized_new(size_t reserved_size);

ubyte* g_byte_array_free(G_Byte_Array* arr, bool free_segment);

G_Bytes* g_byte_array_free_to_bytes(G_Byte_Array* array);

G_Byte_Array* g_byte_array_ref(G_Byte_Array* array);

void g_byte_array_unref(G_Byte_Array* array);

G_Byte_Array* g_byte_array_append(G_Byte_Array* arr, const ubyte* data, size_t len);

G_Byte_Array* g_byte_array_prepend(G_Byte_Array* arr, const ubyte* data, size_t len);

G_Byte_Array* g_byte_array_set_size(G_Byte_Array* arr, size_t length);

G_Byte_Array* g_byte_array_remove_index(G_Byte_Array* arr, size_t index_);

G_Byte_Array* g_byte_array_remove_index_fast(G_Byte_Array* arr, size_t index_);

G_Byte_Array* g_byte_array_remove_range(G_Byte_Array* arr, size_t index_, size_t length);

void g_byte_array_sort(G_Byte_Array* arr, GF_Compare compare_func);

void g_byte_array_sort_with_data(G_Byte_Array* arr, GF_Data_Compare compare_func, void* user_data);
