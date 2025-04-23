module dng.base.g_timezone;
extern (C) __gshared @nogc nothrow @safe:

struct G_Timezone;

/***
 * G_TIME_TYPE:
 * @G_TIME_TYPE_STANDARD: the time is in local standard time
 * @G_TIME_TYPE_DAYLIGHT: the time is in local daylight time
 * @G_TIME_TYPE_UNIVERSAL: the time is in UTC
 *
 * Disambiguates a given time in two ways.
 *
 * First, specifies if the given time is in universal or local time.
 *
 * Second, if the time is in local time, specifies if it is local
 * standard time or local daylight time.  This is important for the case
 * where the same local time occurs twice (during daylight savings time
 * transitions, for example). */
enum G_TIME_TYPE {
	G_TIME_TYPE_STANDARD,
	G_TIME_TYPE_DAYLIGHT,
	G_TIME_TYPE_UNIVERSAL
}

G_Timezone* g_timezone_new_identifier(string identifier);

G_Timezone* g_timezone_new_utc();

G_Timezone* g_timezone_new_local();

G_Timezone* g_timezone_new_offset(int seconds);

G_Timezone* g_timezone_ref(G_Timezone* tz);

void g_timezone_unref(G_Timezone* tz);

int g_timezone_find_interval(G_Timezone* tz, G_TIME_TYPE type_, long time_);

int g_timezone_adjust_time(G_Timezone* tz, G_TIME_TYPE type_, long* time_);

string g_timezone_get_abbreviation(G_Timezone* tz, int interval);

int g_timezone_get_offset(G_Timezone* tz, int interval);

bool g_timezone_is_dst(G_Timezone* tz, int interval);

string g_timezone_get_identifier(G_Timezone* tz);
