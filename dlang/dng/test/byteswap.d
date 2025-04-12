module dng.test.byteswap;

import core.stdc.stdio: printf;
import dng.dlib.dtypes;

extern (C):

void main() {
	char* s = cast(char*)"";
	enum short shortInit = -99;
	auto shortSwap = SWAP_LE_BE!(shortInit);
	enum ushort ushortInit = 999;
	auto ushortSwap = SWAP_LE_BE!(ushortInit);
	enum int intInit = -101560;
	auto intSwap = SWAP_LE_BE!(intInit);
	enum uint uintInit = 102220;
	auto uintSwap = SWAP_LE_BE!(uintInit);
	enum long longInit = -11651600;
	auto longSwap = SWAP_LE_BE!(longInit);
	enum ulong ulongInit = 999999999999;
	auto ulongSwap = SWAP_LE_BE!(ulongInit);
	enum ptrdiff_t pdiffInit = -105150;
	auto pdiffSwap = SWAP_LE_BE!(pdiffInit);
	enum size_t sizeInit = 11151100;
	auto sizeSwap = SWAP_LE_BE!(sizeInit);
	enum autoZInit = -100;
	auto autoZSwap = SWAP_LE_BE!(autoZInit);
	enum autoNInit = 1999999999U;
	auto autoNSwap = SWAP_LE_BE!(autoNInit);
	printf("short.min       = %12s%04hx, short.max  = %12s%04hx\n", s, short.min, s, short.max);
	printf("ushort.min      = %12s%04hx, ushort.max = %12s%04hx\n", s, ushort.min, s, ushort.max);
	printf("int.min         = %8s%08x, int.max    = %8s%08x\n", s, int.min, s, int.max);
	printf("uint.min        = %8s%08x, uint.max   = %8s%08x\n", s, uint.min, s, uint.max);
	printf("long.min        = %016lx, long.max   = %016lx\n", long.min, long.max);
	printf("ulong.min       = %016lx, ulong.max  = %016lx\n", ulong.min, ulong.max);
	printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n");
	printf("shortInit.type  = %s,  shortInit.value      = %12s%04hx\n",
		cast(char*)__traits(fullyQualifiedName, typeof(shortInit)), s, shortInit);
	printf("shortSwap.type  = %s,  shortSwap.value      = %12s%04hx\n",
		cast(char*)__traits(fullyQualifiedName, typeof(shortSwap)), s, shortSwap);
	printf("ushortInit.type = %s, ushortInit.value     = %12s%04hx\n",
		cast(char*)__traits(fullyQualifiedName, typeof(ushortInit)), s, ushortInit);
	printf("ushortSwap.type = %s, ushortSwap.value     = %12s%04hx\n",
		cast(char*)__traits(fullyQualifiedName, typeof(ushortSwap)), s, ushortSwap);
	printf("\n");
	printf("intInit.type    = %s,    intInit.value        = %8s%08x\n",
		cast(char*)__traits(fullyQualifiedName, typeof(intInit)), s, intInit);
	printf("intSwap.type    = %s,    intSwap.value        = %8s%08x\n",
		cast(char*)__traits(fullyQualifiedName, typeof(intSwap)), s, intSwap);
	printf("uintInit.type   = %s,   uintInit.value       = %8s%08x\n",
		cast(char*)__traits(fullyQualifiedName, typeof(uintInit)), s, uintInit);
	printf("uintSwap.type   = %s,   uintSwap.value       = %8s%08x\n",
		cast(char*)__traits(fullyQualifiedName, typeof(uintSwap)), s, uintSwap);
	printf("\n");
	printf("longInit.type   = %s,   longInit.value       = %016lx\n",
		cast(char*)__traits(fullyQualifiedName, typeof(longInit)), longInit);
	printf("longSwap.type   = %s,   longSwap.value       = %016lx\n",
		cast(char*)__traits(fullyQualifiedName, typeof(longSwap)), longSwap);
	printf("ulongInit.type  = %s,  ulongInit.value      = %016lx\n",
		cast(char*)__traits(fullyQualifiedName, typeof(ulongInit)), ulongInit);
	printf("ulongSwap.type  = %s,  ulongSwap.value      = %016lx\n",
		cast(char*)__traits(fullyQualifiedName, typeof(ulongSwap)), ulongSwap);
	printf("\n");
	printf("pdiffInit.type  = %s,   pdiffInit.value      = %016lx\n",
		cast(char*)__traits(fullyQualifiedName, typeof(pdiffInit)), pdiffInit);
	printf("pdiffSwap.type  = %s,   pdiffSwap.value      = %016lx\n",
		cast(char*)__traits(fullyQualifiedName, typeof(pdiffSwap)), pdiffSwap);
	printf("sizeInit.type   = %s,  sizeInit.value       = %016lx\n",
		cast(char*)__traits(fullyQualifiedName, typeof(sizeInit)), sizeInit);
	printf("sizeSwap.type   = %s,  sizeSwap.value       = %016lx\n",
		cast(char*)__traits(fullyQualifiedName, typeof(sizeSwap)), sizeSwap);
	printf("\n");
	printf("autoZInit.type  = %s,    autoZInit.value      = %8s%08x\n",
		cast(char*)__traits(fullyQualifiedName, typeof(autoZInit)), s, autoZInit);
	printf("autoZSwap.type  = %s,    autoZSwap.value      = %8s%08x\n",
		cast(char*)__traits(fullyQualifiedName, typeof(autoZSwap)), s, autoZSwap);
	printf("autoNInit.type  = %s,   autoNInit.value      = %8s%08x\n",
		cast(char*)__traits(fullyQualifiedName, typeof(autoNInit)), s, autoNInit);
	printf("autoNSwap.type  = %s,   autoNSwap.value      = %8s%08x\n",
		cast(char*)__traits(fullyQualifiedName, typeof(autoNSwap)), s, autoNSwap);
}
