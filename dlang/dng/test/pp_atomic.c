#include <string.h>

#define	FALSE	(0)
#define	TRUE	(!FALSE)
#define cast(type) (type)

typedef int            bool;

typedef unsigned int   uint;

typedef signed long    ptrdiff_t;
typedef unsigned long  size_t;


int(d_atomic_int_get)(const volatile int* atomic) {
	return ({
		_Static_assert(sizeof *(atomic) == sizeof(int), "Expression evaluates to false");
		int gaig_temp;
		(void)(0 ? *(atomic) ^ *(atomic) : 1);
		__atomic_load((int*)(atomic), &gaig_temp, 5);
		(int) gaig_temp;
	});
}


void(d_atomic_int_set)(volatile int* atomic, int newVal) {
	({
		_Static_assert(sizeof *(atomic) == sizeof(int), "Expression evaluates to false");
		int gais_temp = (int)(newVal);
		(void)(0 ? *(atomic) ^ (newVal) : 1);
		__atomic_store((int*)(atomic), &gais_temp, 5);
	});
}


void(d_atomic_int_inc)(volatile int* atomic) {
	({
		_Static_assert(sizeof *(atomic) == sizeof(int), "Expression evaluates to false");
		(void)(0 ? *(atomic) ^ *(atomic) : 1);
		(void)__atomic_fetch_add((atomic), 1, 5);
	});
}


bool(d_atomic_int_dec_n_test)(volatile int* atomic) {
	return ({
		_Static_assert(sizeof *(atomic) == sizeof(int), "Expression evaluates to false");
		(void)(0 ? *(atomic) ^ *(atomic) : 1);
		__atomic_fetch_sub((atomic), 1, 5) == 1;
	});
}


bool(d_atomic_int_compare_n_swap)(volatile int* atomic, int oldVal, int newVal) {
	return ({
		__typeof__(*(atomic)) gaicae_oldVal = (oldVal);
		_Static_assert(sizeof *(atomic) == sizeof(int), "Expression evaluates to false");
		(void)(0 ? *(atomic) ^ (newVal) ^ (oldVal) : 1);
		__atomic_compare_exchange_n((atomic), &gaicae_oldVal, (newVal), FALSE, 5, 5) ? TRUE : FALSE;
	});
}


bool(d_atomic_int_compare_n_swap_full)(
	int* atomic, int oldVal, int newVal, int* preVal
) {
	return ({
		_Static_assert(sizeof *(atomic) == sizeof(int), "Expression evaluates to false");
		_Static_assert(sizeof *(preVal) == sizeof(int), "Expression evaluates to false");
		(void)(0 ? *(atomic) ^ (newVal) ^ (oldVal) ^ *(preVal) : 1);
		*(preVal) = (oldVal);
		__atomic_compare_exchange_n((atomic), (preVal), (newVal), FALSE, 5, 5) ? TRUE : FALSE;
	});
}


int(d_atomic_int_exchange)(int* atomic, int newVal) {
	return ({
		_Static_assert(sizeof *(atomic) == sizeof(int), "Expression evaluates to false");
		(void)(0 ? *(atomic) ^ (newVal) : 1);
		(int) __atomic_exchange_n((atomic), (newVal), 5);
	});
}


int(d_atomic_int_add)(volatile int* atomic, int val) {
	return ({
		_Static_assert(sizeof *(atomic) == sizeof(int), "Expression evaluates to false");
		(void)(0 ? *(atomic) ^ (val) : 1);
		(int) __atomic_fetch_add((atomic), (val), 5);
	});
}


uint(d_atomic_int_and)(volatile uint* atomic, uint val) {
	return ({
		_Static_assert(sizeof *(atomic) == sizeof(int), "Expression evaluates to false");
		(void)(0 ? *(atomic) ^ (val) : 1);
		(uint) __atomic_fetch_and((atomic), (val), 5);
	});
}


uint(d_atomic_int_or)(volatile uint* atomic, uint val) {
	return ({
		_Static_assert(sizeof *(atomic) == sizeof(int), "Expression evaluates to false");
		(void)(0 ? *(atomic) ^ (val) : 1);
		(uint) __atomic_fetch_or((atomic), (val), 5);
	});
}


uint(d_atomic_int_xor)(volatile uint* atomic, uint val) {
	return ({
		_Static_assert(sizeof *(atomic) == sizeof(int), "Expression evaluates to false");
		(void)(0 ? *(atomic) ^ (val) : 1);
		(uint) __atomic_fetch_xor((atomic), (val), 5);
	});
}


void*(d_atomic_pointer_get)(const volatile void* atomic) {
	return ({
		_Static_assert(
			sizeof *((void**)atomic) == sizeof(void*), "Expression evaluates to false"
		);
		__typeof__(*((void**)atomic)) gapg_temp_newVal;
		__typeof__((void**)atomic)    gapg_temp_atomic = ((void**)atomic);
		__atomic_load(gapg_temp_atomic, &gapg_temp_newVal, 5);
		gapg_temp_newVal;
	});
}


void(d_atomic_pointer_set)(volatile void* atomic, void* newVal) {
	({
		_Static_assert(
			sizeof *((void**)atomic) == sizeof(void*), "Expression evaluates to false"
		);
		__typeof__((void**)atomic)    gaps_temp_atomic = ((void**)atomic);
		__typeof__(*((void**)atomic)) gaps_temp_newVal = (newVal);
		(void)(0 ? (void*) * ((void**)atomic) : NULL);
		__atomic_store(gaps_temp_atomic, &gaps_temp_newVal, 5);
	});
}


bool(d_atomic_pointer_compare_n_swap)(volatile void* atomic, void* oldVal, void* newVal) {
	return ({
		_Static_assert(
			sizeof(cast(__typeof__(*((void**)atomic)))(oldVal)) == sizeof(void*),
			"Expression evaluates to false"
		);
		__typeof__(*((void**)atomic)) gapcae_oldVal = (oldVal);
		_Static_assert(
			sizeof *((void**)atomic) == sizeof(void*), "Expression evaluates to false"
		);
		(void)(0 ? (void*) * ((void**)atomic) : NULL);
		__atomic_compare_exchange_n(((void**)atomic), &gapcae_oldVal, (newVal), FALSE, 5, 5)
			? TRUE
			: FALSE;
	});
}


bool(d_atomic_pointer_compare_n_swap_full)(
	void* atomic, void* oldVal, void* newVal, void* preVal
) {
	return ({
		_Static_assert(
			sizeof *((void**)atomic) == sizeof(void*), "Expression evaluates to false"
		);
		_Static_assert(
			sizeof *((void**)preVal) == sizeof(void*), "Expression evaluates to false"
		);
		(void)(0 ? (void*) * ((void**)atomic) : NULL);
		(void)(0 ? (void*) * ((void**)preVal) : NULL);
		*((void**)preVal) = (oldVal);
		__atomic_compare_exchange_n(((void**)atomic), ((void**)preVal), (newVal), FALSE, 5, 5)
			? TRUE
			: FALSE;
	});
}


void*(d_atomic_pointer_exchange)(void* atomic, void* newVal) {
	return ({
		_Static_assert(
			sizeof *((void**)atomic) == sizeof(void*), "Expression evaluates to false"
		);
		(void)(0 ? (void*) * ((void**)atomic) : NULL);
		(void*) __atomic_exchange_n(((void**)atomic), (newVal), 5);
	});
}


ptrdiff_t(d_atomic_pointer_add)(volatile void* atomic, ptrdiff_t val) {
	return ({
		_Static_assert(
			sizeof *((void**)atomic) == sizeof(void*), "Expression evaluates to false"
		);
		(void)(0 ? (void*) * ((void**)atomic) : NULL);
		(void)(0 ? (val) ^ (val) : 1);
		(ptrdiff_t) __atomic_fetch_add(((void**)atomic), (val), 5);
	});
}


size_t(d_atomic_pointer_and)(volatile void* atomic, size_t val) {
	return ({
		size_t* gapa_atomic = (size_t*)((void**)atomic);
		_Static_assert(
			sizeof *((void**)atomic) == sizeof(void*), "Expression evaluates to false"
		);
		_Static_assert(
			sizeof *((void**)atomic) == sizeof(size_t), "Expression evaluates to false"
		);
		(void)(0 ? (void*) * ((void**)atomic) : NULL);
		(void)(0 ? (val) ^ (val) : 1);
		(size_t) __atomic_fetch_and(gapa_atomic, (val), 5);
	});
}


size_t(d_atomic_pointer_or)(volatile void* atomic, size_t val) {
	return ({
		size_t* gapo_atomic = (size_t*)((void**)atomic);
		_Static_assert(
			sizeof *((void**)atomic) == sizeof(void*), "Expression evaluates to false"
		);
		_Static_assert(
			sizeof *((void**)atomic) == sizeof(size_t), "Expression evaluates to false"
		);
		(void)(0 ? (void*) * ((void**)atomic) : NULL);
		(void)(0 ? (val) ^ (val) : 1);
		(size_t) __atomic_fetch_or(gapo_atomic, (val), 5);
	});
}


size_t(d_atomic_pointer_xor)(volatile void* atomic, size_t val) {
	return ({
		size_t* gapx_atomic = (size_t*)((void**)atomic);
		_Static_assert(
			sizeof *((void**)atomic) == sizeof(void*), "Expression evaluates to false"
		);
		_Static_assert(
			sizeof *((void**)atomic) == sizeof(size_t), "Expression evaluates to false"
		);
		(void)(0 ? (void*) * ((void**)atomic) : NULL);
		(void)(0 ? (val) ^ (val) : 1);
		(size_t) __atomic_fetch_xor(gapx_atomic, (val), 5);
	});
}


int d_atomic_int_exchange_n_add(volatile int* atomic, int val) {
	return (d_atomic_int_add)((int*)atomic, val);
}
