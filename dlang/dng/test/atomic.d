module dlang.dng.test.atomic;

import core.internal.atomic;
import core.internal.attributes: betterC;
import core.internal.traits: hasUnsharedIndirections;

pragma(inline, true): // LDC

enum MemoryOrder {
	raw = 0,
	acq = 2,
	rel = 3,
	acq_rel = 4,
	seq = 5,
}

T atomicLoad(MemoryOrder ms = MemoryOrder.seq, T)(auto ref return scope const T val) pure nothrow @nogc @trusted
	if (!is(T == shared U, U) && !is(T == shared inout U, U) && !is(T == shared const U, U)) {
	return core.internal.atomic.atomicLoad!ms(cast(T*)&val);
}

T atomicLoad(MemoryOrder ms = MemoryOrder.seq, T)(auto ref return scope shared const T val) pure nothrow @nogc @trusted
	if (!hasUnsharedIndirections!T) {
	import core.internal.traits: hasUnsharedIndirections;

	static assert(!hasUnsharedIndirections!T, "Copying `" ~ shared(const(T))
			.stringof ~ "` would violate shared.");

	return atomicLoad!ms(*cast(T*)&val);
}

TailShared!T atomicLoad(MemoryOrder ms = MemoryOrder.seq, T)(auto ref shared const T val) pure nothrow @nogc @trusted
	if (hasUnsharedIndirections!T) {
	return core.internal.atomic.atomicLoad!ms(cast(TailShared!T*)&val);
}

void atomicStore(MemoryOrder ms = MemoryOrder.seq, T, V)(ref T val, V newval) pure nothrow @nogc @trusted
	if (!is(T == shared) && !is(V == shared)) {
	import core.internal.traits: hasElaborateCopyConstructor;

	static assert(!hasElaborateCopyConstructor!T,
		"`T` may not have an elaborate copy: atomic operations override regular copying semantics.");

	version (LDC) {
		import core.internal.traits: Unqual;

		static if (is(Unqual!T == Unqual!V)) {
			alias arg = newval;
		}
		else {
			T arg;
			arg = newval;
		}
	}
	else {
		T arg = newval;
	}

	core.internal.atomic.atomicStore!ms(&val, arg);
}

void atomicStore(MemoryOrder ms = MemoryOrder.seq, T, V)(ref shared T val, V newval) pure nothrow @nogc @trusted
	if (!is(T == class)) {
	static if (is(V == shared U, U))
		alias Thunk = U;
	else {
		import core.internal.traits: hasUnsharedIndirections;

		static assert(!hasUnsharedIndirections!V,
			"Copying argument `" ~ V.stringof ~ " newval` to `" ~ shared(T)
				.stringof ~ " here` would violate shared.");
		alias Thunk = V;
	}
	atomicStore!ms(*cast(T*)&val, *cast(Thunk*)&newval);
}

void atomicStore(MemoryOrder ms = MemoryOrder.seq, T, V)(ref shared T val, auto ref shared V newval) pure nothrow @nogc @trusted
	if (is(T == class)) {
	static assert(is(V : T),
		"Can't assign `newval` of type `shared " ~ V.stringof ~ "` to `shared " ~ T.stringof ~ "`.");

	core.internal.atomic.atomicStore!ms(cast(T*)&val, cast(V)newval);
}

T atomicFetchAdd(MemoryOrder ms = MemoryOrder.seq, T)(ref return scope T val, size_t mod) pure nothrow @nogc @trusted
	if ((__traits(isIntegral, T) || is(T == U*, U)) && !is(T == shared))
in (atomicValueIsProperlyAligned(val)) {
	static if (is(T == U*, U))
		return cast(T)core.internal.atomic.atomicFetchAdd!ms(cast(size_t*)&val, mod * U.sizeof);
	else
		return core.internal.atomic.atomicFetchAdd!ms(&val, cast(T)mod);
}

T atomicFetchAdd(MemoryOrder ms = MemoryOrder.seq, T)(ref return scope shared T val, size_t mod) pure nothrow @nogc @trusted
	if (__traits(isIntegral, T) || is(T == U*, U))
in (atomicValueIsProperlyAligned(val)) {
	return atomicFetchAdd!ms(*cast(T*)&val, mod);
}

T atomicFetchSub(MemoryOrder ms = MemoryOrder.seq, T)(ref return scope T val, size_t mod) pure nothrow @nogc @trusted
	if ((__traits(isIntegral, T) || is(T == U*, U)) && !is(T == shared))
in (atomicValueIsProperlyAligned(val)) {
	static if (is(T == U*, U))
		return cast(T)core.internal.atomic.atomicFetchSub!ms(cast(size_t*)&val, mod * U.sizeof);
	else
		return core.internal.atomic.atomicFetchSub!ms(&val, cast(T)mod);
}

T atomicFetchSub(MemoryOrder ms = MemoryOrder.seq, T)(ref return scope shared T val, size_t mod) pure nothrow @nogc @trusted
	if (__traits(isIntegral, T) || is(T == U*, U))
in (atomicValueIsProperlyAligned(val)) {
	return atomicFetchSub!ms(*cast(T*)&val, mod);
}

T atomicExchange(MemoryOrder ms = MemoryOrder.seq, T, V)(T* here, V exchangeWith) pure nothrow @nogc @trusted
	if (!is(T == shared) && !is(V == shared))
in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
	T arg = exchangeWith;

	return core.internal.atomic.atomicExchange!ms(here, arg);
}

TailShared!T atomicExchange(MemoryOrder ms = MemoryOrder.seq, T, V)(shared(T)* here, V exchangeWith) pure nothrow @nogc @trusted
	if (!is(T == class) && !is(T == interface))
in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
	static if (is(V == shared U, U))
		alias Thunk = U;
	else {
		import core.internal.traits: hasUnsharedIndirections;

		static assert(!hasUnsharedIndirections!V,
			"Copying `exchangeWith` of type `" ~ V.stringof ~ "` to `" ~ shared(T)
				.stringof ~ "` would violate shared.");
		alias Thunk = V;
	}
	return atomicExchange!ms(cast(T*)here, *cast(Thunk*)&exchangeWith);
}

shared(T) atomicExchange(MemoryOrder ms = MemoryOrder.seq, T, V)(shared(T)* here,
	shared(V) exchangeWith) pure nothrow @nogc @trusted
	if (is(T == class) || is(T == interface))
in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
	static assert(is(V : T), "Can't assign `exchangeWith` of type `" ~ shared(V)
			.stringof ~ "` to `" ~ shared(T).stringof ~ "`.");

	return cast(shared)core.internal.atomic.atomicExchange!ms(cast(T*)here, cast(V)exchangeWith);
}

template cas(MemoryOrder succ = MemoryOrder.seq, MemoryOrder fail = MemoryOrder.seq) {
	bool cas(T, V1, V2)(T* here, V1 ifThis, V2 writeThis) pure nothrow @nogc @trusted
		if (!is(T == shared) && is(T : V1))
	in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
		// resolve implicit conversions
		const T arg1 = ifThis;
		T arg2 = writeThis;

		return atomicCompareExchangeStrongNoResult!(succ, fail)(here, arg1, arg2);
	}

	bool cas(T, V1, V2)(shared(T)* here, V1 ifThis, V2 writeThis) pure nothrow @nogc @trusted
		if (!is(T == class) && (is(T : V1) || is(shared T : V1)))
	in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
		static if (is(V1 == shared U1, U1))
			alias Thunk1 = U1;
		else
			alias Thunk1 = V1;
		static if (is(V2 == shared U2, U2))
			alias Thunk2 = U2;
		else {
			import core.internal.traits: hasUnsharedIndirections;

			static assert(!hasUnsharedIndirections!V2,
				"Copying `" ~ V2.stringof ~ "* writeThis` to `" ~ shared(T)
					.stringof ~ "* here` would violate shared.");
			alias Thunk2 = V2;
		}
		return cas(cast(T*)here, *cast(Thunk1*)&ifThis, *cast(Thunk2*)&writeThis);
	}

	bool cas(T, V1, V2)(shared(T)* here, shared(V1) ifThis, shared(V2) writeThis) pure nothrow @nogc @trusted
		if (is(T == class))
	in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
		return atomicCompareExchangeStrongNoResult!(succ, fail)(cast(T*)here,
			cast(V1)ifThis, cast(V2)writeThis);
	}

	bool cas(T, V)(T* here, T* ifThis, V writeThis) pure nothrow @nogc @trusted
		if (!is(T == shared) && !is(V == shared))
	in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
		// resolve implicit conversions
		T arg1 = writeThis;

		return atomicCompareExchangeStrong!(succ, fail)(here, ifThis, writeThis);
	}

	bool cas(T, V1, V2)(shared(T)* here, V1* ifThis, V2 writeThis) pure nothrow @nogc @trusted
		if (!is(T == class) && (is(T : V1) || is(shared T : V1)))
	in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
		static if (is(V1 == shared U1, U1))
			alias Thunk1 = U1;
		else {
			import core.internal.traits: hasUnsharedIndirections;

			static assert(!hasUnsharedIndirections!V1, "Copying `" ~ shared(T)
					.stringof ~ "* here` to `" ~ V1.stringof ~ "* ifThis` would violate shared.");
			alias Thunk1 = V1;
		}
		static if (is(V2 == shared U2, U2))
			alias Thunk2 = U2;
		else {
			import core.internal.traits: hasUnsharedIndirections;

			static assert(!hasUnsharedIndirections!V2,
				"Copying `" ~ V2.stringof ~ "* writeThis` to `" ~ shared(T)
					.stringof ~ "* here` would violate shared.");
			alias Thunk2 = V2;
		}
		static assert(is(T : Thunk1), "Mismatching types for `here` and `ifThis`: `" ~ shared(T)
				.stringof ~ "` and `" ~ V1.stringof ~ "`.");
		return cas(cast(T*)here, cast(Thunk1*)ifThis, *cast(Thunk2*)&writeThis);
	}

	bool cas(T, V)(shared(T)* here, shared(T)* ifThis, shared(V) writeThis) pure nothrow @nogc @trusted
		if (is(T == class))
	in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
		return atomicCompareExchangeStrong!(succ, fail)(cast(T*)here,
			cast(T*)ifThis, cast(V)writeThis);
	}
}

bool casWeak(MemoryOrder succ = MemoryOrder.seq, MemoryOrder fail = MemoryOrder.seq, T, V1, V2)(
	T* here, V1 ifThis, V2 writeThis) pure nothrow @nogc @trusted
	if (!is(T == shared) && is(T : V1))
in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
	// resolve implicit conversions
	T arg1 = ifThis;
	T arg2 = writeThis;

	static if (__traits(isFloating, T)) {
		alias IntTy = IntForFloat!T;
		return atomicCompareExchangeWeakNoResult!(succ, fail)(cast(IntTy*)here,
			*cast(IntTy*)&arg1, *cast(IntTy*)&arg2);
	}
	else
		return atomicCompareExchangeWeakNoResult!(succ, fail)(here, arg1, arg2);
}

bool casWeak(MemoryOrder succ = MemoryOrder.seq, MemoryOrder fail = MemoryOrder.seq, T, V1, V2)(
	shared(T)* here, V1 ifThis, V2 writeThis) pure nothrow @nogc @trusted
	if (!is(T == class) && (is(T : V1) || is(shared T : V1)))
in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
	static if (is(V1 == shared U1, U1))
		alias Thunk1 = U1;
	else
		alias Thunk1 = V1;
	static if (is(V2 == shared U2, U2))
		alias Thunk2 = U2;
	else {
		import core.internal.traits: hasUnsharedIndirections;

		static assert(!hasUnsharedIndirections!V2,
			"Copying `" ~ V2.stringof ~ "* writeThis` to `" ~ shared(T)
				.stringof ~ "* here` would violate shared.");
		alias Thunk2 = V2;
	}
	return casWeak!(succ, fail)(cast(T*)here, *cast(Thunk1*)&ifThis, *cast(Thunk2*)&writeThis);
}

bool casWeak(MemoryOrder succ = MemoryOrder.seq, MemoryOrder fail = MemoryOrder.seq, T, V1, V2)(
	shared(T)* here, shared(V1) ifThis, shared(V2) writeThis) pure nothrow @nogc @trusted
	if (is(T == class))
in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
	return atomicCompareExchangeWeakNoResult!(succ, fail)(cast(T*)here,
		cast(V1)ifThis, cast(V2)writeThis);
}

bool casWeak(MemoryOrder succ = MemoryOrder.seq, MemoryOrder fail = MemoryOrder.seq, T, V)(
	T* here, T* ifThis, V writeThis) pure nothrow @nogc @trusted
	if (!is(T == shared S, S) && !is(V == shared U, U))
in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
	T arg1 = writeThis;

	static if (__traits(isFloating, T)) {
		alias IntTy = IntForFloat!T;
		return atomicCompareExchangeWeak!(succ, fail)(cast(IntTy*)here,
			cast(IntTy*)ifThis, *cast(IntTy*)&writeThis);
	}
	else
		return atomicCompareExchangeWeak!(succ, fail)(here, ifThis, writeThis);
}

bool casWeak(MemoryOrder succ = MemoryOrder.seq, MemoryOrder fail = MemoryOrder.seq, T, V1, V2)(
	shared(T)* here, V1* ifThis, V2 writeThis) pure nothrow @nogc @trusted
	if (!is(T == class) && (is(T : V1) || is(shared T : V1)))
in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
	static if (is(V1 == shared U1, U1))
		alias Thunk1 = U1;
	else {
		import core.internal.traits: hasUnsharedIndirections;

		static assert(!hasUnsharedIndirections!V1, "Copying `" ~ shared(T)
				.stringof ~ "* here` to `" ~ V1.stringof ~ "* ifThis` would violate shared.");
		alias Thunk1 = V1;
	}
	static if (is(V2 == shared U2, U2))
		alias Thunk2 = U2;
	else {
		import core.internal.traits: hasUnsharedIndirections;

		static assert(!hasUnsharedIndirections!V2,
			"Copying `" ~ V2.stringof ~ "* writeThis` to `" ~ shared(T)
				.stringof ~ "* here` would violate shared.");
		alias Thunk2 = V2;
	}
	static assert(is(T : Thunk1), "Mismatching types for `here` and `ifThis`: `" ~ shared(T)
			.stringof ~ "` and `" ~ V1.stringof ~ "`.");
	return casWeak!(succ, fail)(cast(T*)here, cast(Thunk1*)ifThis, *cast(Thunk2*)&writeThis);
}

bool casWeak(MemoryOrder succ = MemoryOrder.seq, MemoryOrder fail = MemoryOrder.seq, T, V)(
	shared(T)* here, shared(T)* ifThis, shared(V) writeThis) pure nothrow @nogc @trusted
	if (is(T == class))
in (atomicPtrIsProperlyAligned(here), "Argument `here` is not properly aligned") {
	return atomicCompareExchangeWeak!(succ, fail)(cast(T*)here, cast(T*)ifThis, cast(V)writeThis);
}

void atomicFence(MemoryOrder order = MemoryOrder.seq)() pure nothrow @nogc @safe {
	core.internal.atomic.atomicFence!order();
}

void pause() pure nothrow @nogc @safe {
	core.internal.atomic.pause();
}

TailShared!T atomicOp(string op, T, V1)(ref shared T val, V1 mod) pure nothrow @nogc @trusted // LDC: was @safe
if (__traits(compiles, mixin("*cast(T*)&val" ~ op ~ "mod")))
in (atomicValueIsProperlyAligned(val)) {
	version (LDC) {
		import ldc.intrinsics;

		enum suitedForLLVMAtomicRmw = (__traits(isIntegral, T) && __traits(isIntegral,
					V1) && T.sizeof <= AtomicRmwSizeLimit && V1.sizeof <= AtomicRmwSizeLimit);
	}
	else
		enum suitedForLLVMAtomicRmw = false;

	static if (op == "+" || op == "-" || op == "*" || op == "/" || op == "%" ||
		op == "^^" || op == "&" || op == "|" || op == "^" || op == "<<" || op == ">>" ||
		op == ">>>" || op == "~" || // skip "in"
		op == "==" || op == "!=" || op == "<" || op == "<=" || op == ">" || op == ">=") {
		T get = atomicLoad!(MemoryOrder.raw, T)(val);
		mixin("return get " ~ op ~ " mod;");
	}
	else // assignment operators
		static if (op == "+=" && suitedForLLVMAtomicRmw) {
			T m = cast(T)mod;
			return cast(T)(llvm_atomic_rmw_add(&val, m) + m);
		}
		else static if (op == "-=" && suitedForLLVMAtomicRmw) {
			T m = cast(T)mod;
			return cast(T)(llvm_atomic_rmw_sub(&val, m) - m);
		}
		else static if (op == "&=" && suitedForLLVMAtomicRmw) {
			T m = cast(T)mod;
			return cast(T)(llvm_atomic_rmw_and(&val, m) & m);
		}
		else static if (op == "|=" && suitedForLLVMAtomicRmw) {
			T m = cast(T)mod;
			return cast(T)(llvm_atomic_rmw_or(&val, m) | m);
		}
		else static if (op == "^=" && suitedForLLVMAtomicRmw) {
			T m = cast(T)mod;
			return cast(T)(llvm_atomic_rmw_xor(&val, m) ^ m);
		}
		else static if (op == "+=" && __traits(isIntegral, T) && __traits(isIntegral,
				V1) && T.sizeof <= size_t.sizeof && V1.sizeof <= size_t.sizeof) {
			return cast(T)(atomicFetchAdd(val, mod) + mod);
		}
		else static if (op == "-=" && __traits(isIntegral, T) && __traits(isIntegral,
				V1) && T.sizeof <= size_t.sizeof && V1.sizeof <= size_t.sizeof) {
			return cast(T)(atomicFetchSub(val, mod) - mod);
		}
		else static if (op == "+=" || op == "-=" || op == "*=" || op == "/=" || op == "%=" ||
			op == "^^=" || op == "&=" || op == "|=" || op == "^=" || op == "<<=" ||
			op == ">>=" || op == ">>>=") // skip "~="
			{
				T set, get = atomicLoad!(MemoryOrder.raw, T)(val);
				do {
					set = get;
					mixin("set " ~ op ~ " mod;");
				}
				while (!casWeakByRef(val, get, set));
				return set;
			}
		else {
			static assert(false, "Operation not supported.");
		}
}

version (LDC) {
	enum has64BitXCHG = true;
	enum has64BitCAS = true;

	version (D_LP64) {
		version (PPC64)
			enum has128BitCAS = real.mant_dig == 113;
		else
			enum has128BitCAS = true;
	}
	else
		enum has128BitCAS = false;
}
else version (D_InlineAsm_X86) {
	enum has64BitXCHG = false;
	enum has64BitCAS = true;
	enum has128BitCAS = false;
}
else version (D_InlineAsm_X86_64) {
	enum has64BitXCHG = true;
	enum has64BitCAS = true;
	enum has128BitCAS = true;
}
else version (GNU) {
	import gcc.config;

	enum has64BitCAS = GNU_Have_64Bit_Atomics;
	enum has64BitXCHG = GNU_Have_64Bit_Atomics;
	enum has128BitCAS = GNU_Have_LibAtomic;
}
else {
	enum has64BitXCHG = false;
	enum has64BitCAS = false;
	enum has128BitCAS = false;
}

private {
	bool atomicValueIsProperlyAligned(T)(ref T val) pure nothrow @nogc @trusted {
		return atomicPtrIsProperlyAligned(&val);
	}

	bool atomicPtrIsProperlyAligned(T)(T* ptr) pure nothrow @nogc @safe {
		static if (T.sizeof > size_t.sizeof) {
			version (X86) {
				return cast(size_t)ptr % size_t.sizeof == 0;
			}
			else {
				return cast(size_t)ptr % T.sizeof == 0;
			}
		}
		else {
			return cast(size_t)ptr % T.sizeof == 0;
		}
	}

	template IntForFloat(F) if (__traits(isFloating, F)) {
		static if (F.sizeof == 4)
			alias IntForFloat = uint;
		else static if (F.sizeof == 8)
			alias IntForFloat = ulong;
		else
			static assert(false,
				"Invalid floating point type: " ~ F.stringof ~ ", only support `float` and `double`.");
	}

	template IntForStruct(S) if (is(S == struct)) {
		static if (S.sizeof == 1)
			alias IntForFloat = ubyte;
		else static if (F.sizeof == 2)
			alias IntForFloat = ushort;
		else static if (F.sizeof == 4)
			alias IntForFloat = uint;
		else static if (F.sizeof == 8)
			alias IntForFloat = ulong;
		else static if (F.sizeof == 16)
			alias IntForFloat = ulong[2];
		else
			static assert(ValidateStruct!S);
	}

	template ValidateStruct(S) if (is(S == struct)) {
		import core.internal.traits: hasElaborateAssign;

		static assert(S.sizeof <= size_t.sizeof * 2 && (S.sizeof & (S.sizeof - 1)) == 0,
			S.stringof ~ " has invalid size for atomic operations.");
		static assert(!hasElaborateAssign!S,
			S.stringof ~ " may not have an elaborate assignment when used with atomic operations.");

		enum ValidateStruct = true;
	}

	bool casWeakByRef(T, V1, V2)(ref T value, ref V1 ifThis, V2 writeThis) pure nothrow @nogc @trusted {
		return casWeak(&value, &ifThis, writeThis);
	}

	template TailShared(U) if (!is(U == shared)) {
		alias TailShared = .TailShared!(shared U);
	}

	template TailShared(S) if (is(S == shared)) {
		// Get the unshared variant of S.
		static if (is(S U == shared U)) {
		}
		else
			static assert(false,
				"Should never be triggered. The `static " ~ "if` declares `U` as the unshared version of the shared type " ~
				"`S`. `S` is explicitly declared as shared, so getting `U` " ~ "should always work.");

		static if (is(S : U))
			alias TailShared = U;
		else static if (is(S == struct)) {
			enum implName = () {
				string name = "_impl";
				string[] fieldNames;
				static foreach (alias field; S.tupleof) {
					fieldNames ~= __traits(identifier, field);
				}
				static bool canFind(string[] haystack, string needle) {
					foreach (candidate; haystack) {
						if (candidate == needle)
							return true;
					}
					return false;
				}

				while (canFind(fieldNames, name))
					name ~= "_";
				return name;
			}();
			struct TailShared {
				static foreach (i, alias field; S.tupleof) {
					mixin("
						@trusted @property
						ref " ~ __traits(identifier, field) ~ "()
						{
							alias R = TailShared!(typeof(field));
							return * cast(R*) &" ~ implName ~ ".tupleof[i];
						}
					");
				}
				mixin("
					S " ~ implName ~ ";
					alias " ~ implName ~ " this;
				");
			}
		}
		else
			alias TailShared = S;
	}
}
