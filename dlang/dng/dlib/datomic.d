module dng.dlib.datomic;

import core.atomic;

extern (C):
pure:
nothrow:
@nogc:
// int d_atomic_get(const shared int* atomic);
// void d_atomic_set(shared int* atomic, int newVal);
// void d_atomic_inc(shared int* atomic);
// bool d_atomic_dec_n_test(shared int* atomic);
// bool d_atomic_compare_n_exchange(shared int* atomic, int oldVal, int newVal);
// bool d_atomic_compare_n_exchange_full(int* atomic, int oldVal, int newVal, int* preVal);
// int d_atomic_exchange(int* atomic, int newVal);
// int d_atomic_add(shared int* atomic, int val);
// uint d_atomic_and(shared uint* atomic, uint val);
// uint d_atomic_or(shared uint* atomic, uint val);
// uint d_atomic_xor(shared uint* atomic, uint val);

void* d_atomic_ptr_get(const shared void* atomic);
void d_atomic_ptr_set(shared void* atomic, void* newVal);
bool d_atomic_ptr_compare_n_exchange(shared void* atomic, void* oldVal, void* newVal);
bool d_atomic_ptr_compare_n_exchange_full(void* atomic, void* oldVal, void* newVal, void* preVal);
void* d_atomic_ptr_exchange(void* atomic, void* newVal);
ptrdiff_t d_atomic_ptr_add(shared void* atomic, ptrdiff_t val);
size_t d_atomic_ptr_and(shared void* atomic, size_t val);
size_t d_atomic_ptr_or(shared void* atomic, size_t val);
size_t d_atomic_ptr_xor(shared void* atomic, size_t val);

T d_atomic_get(T)(const shared T* atomic) @safe {
	return atomicLoad(*atomic);
}

void d_atomic_set(T)(shared T* atomic, T newVal) @safe {
	atomicStore(*atomic, newVal);
}

void d_atomic_increment(T)(shared T* atomic) @safe {
	atomicFetchAdd(*atomic, 1);
}

bool d_atomic_decrement_n_test(T)(shared T* atomic) @safe {
	return atomicFetchSub(*atomic, 1) == 1;
}

bool d_atomic_compare_n_swap(T)(shared T* atomic, ref T oldVal, T newVal) @safe {
	return cas(atomic, oldVal, newVal);
}

bool d_atomic_compare_n_swap_full(T)(T* atomic, T oldVal, T newVal, T* preVal) @safe {
	*preVal = oldVal;
	return cas(atomic, preVal, newVal);
}

int d_atomic_exchange(int* atomic, int newVal) @safe {
	return atomicExchange(atomic, newVal);
}

int d_atomic_add(shared int* atomic, int val) @safe {
	return atomicFetchAdd(*atomic, val);
}

size_t d_atomic_and(shared size_t* atomic, size_t val) @safe {
	size_t tmp = *atomic;
	atomicOp!"&"(*atomic, val);
	return tmp;
}

size_t d_atomic_or(shared size_t* atomic, size_t val) @safe {
	size_t tmp = *atomic;
	atomicOp!"|"(*atomic, val);
	return tmp;
}

size_t d_atomic_xor(shared size_t* atomic, size_t val) @safe {
	size_t tmp = *atomic;
	atomicOp!"^"(*atomic, val);
	return tmp;
}
