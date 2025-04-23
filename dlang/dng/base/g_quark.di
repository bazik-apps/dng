module dng.base.g_quark;
extern (C) __gshared @nogc nothrow @safe:

alias G_Quark = int;

/***
 * Quarks (string<->id association) */
G_Quark g_quark_try_string(string s);
G_Quark g_quark_from_static_string(string s);
G_Quark g_quark_from_string(string s);

enum G_Quark G_DEFINE_QUARK(string QN) = g_quark_from_static_string(QN);

string g_intern_string(string s);
string g_intern_static_string(string s);

enum QUARK_BLOCK_SIZE = 2048;
enum QUARK_STRING_BLOCK_SIZE = 4096 - size_t.sizeof;
