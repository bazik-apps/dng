module dng.base.g_datetime;
extern (C) __gshared @nogc nothrow @safe:

import dng.base.g_types: G_Refcount;
import dng.base.g_timezone: G_Timezone;

/***
 * G_TIME_SPAN_DAY:
 *
 * Evaluates to a time span of one day. */
enum G_TIME_SPAN_DAY = 86_400_000_000;

/***
 * G_TIME_SPAN_HOUR:
 *
 * Evaluates to a time span of one hour. */
enum G_TIME_SPAN_HOUR = 3_600_000_000;

/***
 * G_TIME_SPAN_MINUTE:
 *
 * Evaluates to a time span of one minute. */
enum G_TIME_SPAN_MINUTE = 60_000_000;

/***
 * G_TIME_SPAN_SECOND:
 *
 * Evaluates to a time span of one second. */
enum G_TIME_SPAN_SECOND = 1_000_000;

/***
 * G_TIME_SPAN_MILLISECOND:
 *
 * Evaluates to a time span of one millisecond. */
enum G_TIME_SPAN_MILLISECOND = 1000;

/***
 * G_Time_Span:
 *
 * A value representing an interval of time, in microseconds. */
alias G_Time_Span = long;

/***
 * G_Datetime:
 *
 * `G_Datetime` is a structure that combines a Gregorian date and time
 * into a single structure.
 *
 * `G_Datetime` provides many conversion and methods to manipulate dates and times.
 * Time precision is provided down to microseconds and the time can range
 * (proleptically) from 0001-01-01 00:00:00 to 9999-12-31 23:59:59.999999.
 * `G_Datetime` follows POSIX time in the sense that it is oblivious to leap
 * seconds.
 *
 * `G_Datetime` is an immutable object; once it has been created it cannot
 * be modified further. All modifiers will create a new `G_Datetime`.
 * Nearly all such functions can fail due to the date or time going out
 * of range, in which case %NULL will be returned.
 *
 * `G_Datetime` is reference counted: the reference count is increased by calling
 * [method@GLib.DateTime.ref] and decreased by calling [method@GLib.DateTime.unref].
 * When the reference count drops to 0, the resources allocated by the `G_Datetime`
 * structure are released.
 *
 * Many parts of the API may produce non-obvious results. As an
 * example, adding two months to January 31st will yield March 31st
 * whereas adding one month and then one month again will yield either
 * March 28th or March 29th.  Also note that adding 24 hours is not
 * always the same as adding one day (since days containing daylight
 * savings time transitions are either 23 or 25 hours in length). */
struct G_Datetime {
	ulong usec;
	G_Timezone* tz;
	int interval;
	int days;
	G_Refcount refcount;
}

void g_datetime_unref(G_Datetime* datetime);

G_Datetime* g_datetime_ref(G_Datetime* datetime);

G_Datetime* g_datetime_new_now(G_Timezone* tz);

G_Datetime* g_datetime_new_now_local();

G_Datetime* g_datetime_new_now_utc();

G_Datetime* g_datetime_new_from_unix_local(long t);

G_Datetime* g_datetime_new_from_unix_utc(long t);

G_Datetime* g_datetime_new_from_unix_local_usec(long usecs);

G_Datetime* g_datetime_new_from_unix_utc_usec(long usecs);

G_Datetime* g_datetime_new_from_iso8601(string text, G_Timezone* default_tz);

//dfmt off
G_Datetime* g_datetime_new(
	G_Timezone* tz,
	int year,
	int month,
	int day,
	int hour,
	int minute,
	double seconds
);

G_Datetime* g_datetime_new_local(
	int year,
	int month,
	int day,
	int hour,
	int minute,
	double seconds
);
//dfmt on

G_Datetime* g_datetime_new_utc(int year, int month, int day, int hour, int minute, double seconds);

G_Datetime* g_datetime_add(G_Datetime* datetime, G_Time_Span timespan);

G_Datetime* g_datetime_add_years(G_Datetime* datetime, int years);

G_Datetime* g_datetime_add_months(G_Datetime* datetime, int months);

G_Datetime* g_datetime_add_weeks(G_Datetime* datetime, int weeks);

G_Datetime* g_datetime_add_days(G_Datetime* datetime, int days);

G_Datetime* g_datetime_add_hours(G_Datetime* datetime, int hours);

G_Datetime* g_datetime_add_minutes(G_Datetime* datetime, int minutes);

G_Datetime* g_datetime_add_seconds(G_Datetime* datetime, double seconds);

//dfmt off
G_Datetime* g_datetime_add_full(
	G_Datetime* datetime,
	int years,
	int months,
	int days,
	int hours,
	int minutes,
	double seconds
);
//dfmt on

int g_datetime_compare(const(void)* dt1, const(void)* dt2);

G_Time_Span g_datetime_difference(G_Datetime* end, G_Datetime* begin);

uint g_datetime_hash(const(void)* datetime);

bool g_datetime_equal(const(void)* dt1, const(void)* dt2);

void g_datetime_get_ymd(G_Datetime* datetime, int* year, int* month, int* day);

int g_datetime_get_year(G_Datetime* datetime);

int g_datetime_get_month(G_Datetime* datetime);

int g_datetime_get_day_of_month(G_Datetime* datetime);

int g_datetime_get_week_numbering_year(G_Datetime* datetime);

int g_datetime_get_week_of_year(G_Datetime* datetime);

int g_datetime_get_day_of_week(G_Datetime* datetime);

int g_datetime_get_day_of_year(G_Datetime* datetime);

int g_datetime_get_hour(G_Datetime* datetime);

int g_datetime_get_minute(G_Datetime* datetime);

int g_datetime_get_second(G_Datetime* datetime);

int g_datetime_get_microsecond(G_Datetime* datetime);

double g_datetime_get_seconds(G_Datetime* datetime);

long g_datetime_to_unix(G_Datetime* datetime);

long g_datetime_to_unix_usec(G_Datetime* datetime);

G_Time_Span g_datetime_get_utc_offset(G_Datetime* datetime);

G_Timezone* g_datetime_get_timezone(G_Datetime* datetime);

string g_datetime_get_timezone_abbreviation(G_Datetime* datetime);

bool g_datetime_is_daylight_savings(G_Datetime* datetime);

G_Datetime* g_datetime_to_timezone(G_Datetime* datetime, G_Timezone* tz);

G_Datetime* g_datetime_to_local(G_Datetime* datetime);

G_Datetime* g_datetime_to_utc(G_Datetime* datetime);

string g_datetime_format(G_Datetime* datetime, string format);

string g_datetime_format_iso8601(G_Datetime* datetime);
