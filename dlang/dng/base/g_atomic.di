module dng.base.g_atomic;
extern (C) __gshared @nogc nothrow @safe:

import core.atomic;

T d_atomic_get(T)(const shared T* atomic) {
	return atomicLoad(*atomic);
}

void d_atomic_set(T)(shared T* atomic, T newVal) {
	atomicStore(*atomic, newVal);
}

void d_atomic_increment(T)(shared T* atomic) {
	atomicFetchAdd(*atomic, 1);
}

bool d_atomic_decrement_n_test(T)(shared T* atomic) {
	return atomicFetchSub(*atomic, 1) == 1;
}

bool d_atomic_compare_n_swap(T)(shared T* atomic, ref T oldVal, T newVal) {
	return cas(atomic, oldVal, newVal);
}

bool d_atomic_compare_n_swap_full(T)(T* atomic, T oldVal, T newVal, T* preVal) {
	*preVal = oldVal;
	return cas(atomic, preVal, newVal);
}

T d_atomic_exchange(T)(T* atomic, T newVal) {
	return atomicExchange(atomic, newVal);
}

T d_atomic_add(T)(shared T* atomic, T val) {
	return atomicFetchAdd(*atomic, val);
}

T d_atomic_and(T)(shared T* atomic, T val) {
	T tmp = *atomic;
	atomicOp!"&"(*atomic, val);
	return tmp;
}

T d_atomic_or(T)(shared T* atomic, T val) {
	T tmp = *atomic;
	atomicOp!"|"(*atomic, val);
	return tmp;
}

T d_atomic_xor(T)(shared T* atomic, T val) {
	T tmp = *atomic;
	atomicOp!"^"(*atomic, val);
	return tmp;
}
