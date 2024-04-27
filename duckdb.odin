package duckdb;


import "core:c"

STATIC_LINK :: false

when ODIN_OS == .Darwin {
	foreign import duckdb "libduckdb.dylib"
} else when ODIN_OS == .Linux {
	when STATIC_LINK {
		foreign import duckdb "libduckdb_static"
	} else {
		foreign import duckdb "libduckdb.so"
	}
} else when ODIN_OS == .Windows {
	foreign import duckdb "duckdb.lib"
} else {
	foreign import duckdb "system:duckdb"
}


//! API versions
//! If no explicit API version is defined, the latest API version is used.
//! Note that using older API versions (i.e. not using DUCKDB_API_LATEST) is deprecated.
//! These will not be supported long-term, and will be removed in future versions.

DUCKDB_API_0_3_1 :: 1
DUCKDB_API_0_3_2 :: 2


DUCKDB_API_LATEST :: DUCKDB_API_0_3_2


DUCKDB_API_VERSION :: DUCKDB_API_LATEST


//===--------------------------------------------------------------------===//
// Enums
//===--------------------------------------------------------------------===//
// WARNING: the numbers of these enums should not be changed, as changing the numbers breaks ABI compatibility
// Always add enums at the END of the enum
//! An enum over DuckDB's internal types.

duckdb_type :: enum {
    DUCKDB_TYPE_INVALID = 0,
	// bool
	DUCKDB_TYPE_BOOLEAN = 1,
	// int8_t
	DUCKDB_TYPE_TINYINT = 2,
	// int16_t
	DUCKDB_TYPE_SMALLINT = 3,
	// int32_t
	DUCKDB_TYPE_INTEGER = 4,
	// int64_t
	DUCKDB_TYPE_BIGINT = 5,
	// uint8_t
	DUCKDB_TYPE_UTINYINT = 6,
	// uint16_t
	DUCKDB_TYPE_USMALLINT = 7,
	// uint32_t
	DUCKDB_TYPE_UINTEGER = 8,
	// uint64_t
	DUCKDB_TYPE_UBIGINT = 9,
	// float
	DUCKDB_TYPE_FLOAT = 10,
	// double
	DUCKDB_TYPE_DOUBLE = 11,
	// duckdb_timestamp, in microseconds
	DUCKDB_TYPE_TIMESTAMP = 12,
	// duckdb_date
	DUCKDB_TYPE_DATE = 13,
	// duckdb_time
	DUCKDB_TYPE_TIME = 14,
	// duckdb_interval
	DUCKDB_TYPE_INTERVAL = 15,
	// duckdb_hugeint
	DUCKDB_TYPE_HUGEINT = 16,
	// duckdb_uhugeint
	DUCKDB_TYPE_UHUGEINT = 32,
	// const char*
	DUCKDB_TYPE_VARCHAR = 17,
	// duckdb_blob
	DUCKDB_TYPE_BLOB = 18,
	// decimal
	DUCKDB_TYPE_DECIMAL = 19,
	// duckdb_timestamp, in seconds
	DUCKDB_TYPE_TIMESTAMP_S = 20,
	// duckdb_timestamp, in milliseconds
	DUCKDB_TYPE_TIMESTAMP_MS = 21,
	// duckdb_timestamp, in nanoseconds
	DUCKDB_TYPE_TIMESTAMP_NS = 22,
	// enum type, only useful as logical type
	DUCKDB_TYPE_ENUM = 23,
	// list type, only useful as logical type
	DUCKDB_TYPE_LIST = 24,
	// struct type, only useful as logical type
	DUCKDB_TYPE_STRUCT = 25,
	// map type, only useful as logical type
	DUCKDB_TYPE_MAP = 26,
	// duckdb_array, only useful as logical type
	DUCKDB_TYPE_ARRAY = 33,
	// duckdb_hugeint
	DUCKDB_TYPE_UUID = 27,
	// union type, only useful as logical type
	DUCKDB_TYPE_UNION = 28,
	// duckdb_bit
	DUCKDB_TYPE_BIT = 29,
	// duckdb_time_tz
	DUCKDB_TYPE_TIME_TZ = 30,
	// duckdb_timestamp
	DUCKDB_TYPE_TIMESTAMP_TZ = 31,
}

//! An enum over the returned state of different functions.
duckdb_state :: enum { DuckDBSuccess = 0, DuckDBError = 1 }

//! An enum over the pending state of a pending query result.

duckdb_pending_state :: enum {
	DUCKDB_PENDING_RESULT_READY = 0,
	DUCKDB_PENDING_RESULT_NOT_READY = 1,
	DUCKDB_PENDING_ERROR = 2,
	DUCKDB_PENDING_NO_TASKS_AVAILABLE = 3
}
//! An enum over DuckDB's different result types.

duckdb_result_type :: enum {
	DUCKDB_RESULT_TYPE_INVALID = 0,
	DUCKDB_RESULT_TYPE_CHANGED_ROWS = 1,
	DUCKDB_RESULT_TYPE_NOTHING = 2,
	DUCKDB_RESULT_TYPE_QUERY_RESULT = 3,
}

//! An enum over DuckDB's different statement types.

duckdb_statement_type :: enum {
	DUCKDB_STATEMENT_TYPE_INVALID = 0,
	DUCKDB_STATEMENT_TYPE_SELECT = 1,
	DUCKDB_STATEMENT_TYPE_INSERT = 2,
	DUCKDB_STATEMENT_TYPE_UPDATE = 3,
	DUCKDB_STATEMENT_TYPE_EXPLAIN = 4,
	DUCKDB_STATEMENT_TYPE_DELETE = 5,
	DUCKDB_STATEMENT_TYPE_PREPARE = 6,
	DUCKDB_STATEMENT_TYPE_CREATE = 7,
	DUCKDB_STATEMENT_TYPE_EXECUTE = 8,
	DUCKDB_STATEMENT_TYPE_ALTER = 9,
	DUCKDB_STATEMENT_TYPE_TRANSACTION = 10,
	DUCKDB_STATEMENT_TYPE_COPY = 11,
	DUCKDB_STATEMENT_TYPE_ANALYZE = 12,
	DUCKDB_STATEMENT_TYPE_VARIABLE_SET = 13,
	DUCKDB_STATEMENT_TYPE_CREATE_FUNC = 14,
	DUCKDB_STATEMENT_TYPE_DROP = 15,
	DUCKDB_STATEMENT_TYPE_EXPORT = 16,
	DUCKDB_STATEMENT_TYPE_PRAGMA = 17,
	DUCKDB_STATEMENT_TYPE_VACUUM = 18,
	DUCKDB_STATEMENT_TYPE_CALL = 19,
	DUCKDB_STATEMENT_TYPE_SET = 20,
	DUCKDB_STATEMENT_TYPE_LOAD = 21,
	DUCKDB_STATEMENT_TYPE_RELATION = 22,
	DUCKDB_STATEMENT_TYPE_EXTENSION = 23,
	DUCKDB_STATEMENT_TYPE_LOGICAL_PLAN = 24,
	DUCKDB_STATEMENT_TYPE_ATTACH = 25,
	DUCKDB_STATEMENT_TYPE_DETACH = 26,
	DUCKDB_STATEMENT_TYPE_MULTI = 27,
}

//===--------------------------------------------------------------------===//
// General type definitions
//===--------------------------------------------------------------------===//

//! DuckDB's index type.
idx_t :: c.uint64_t

//! The callback that will be called to destroy data, e.g.,
//! bind data (if any), init data (if any), extra data for replacement scans (if any)
duckdb_delete_callback_t :: ^proc "c" (data:rawptr)

//! Used for threading, contains a task state. Must be destroyed with `duckdb_destroy_state`.
duckdb_task_state :: rawptr

//===--------------------------------------------------------------------===//
// Types (no explicit freeing)
//===--------------------------------------------------------------------===//

//! Days are stored as days since 1970-01-01
//! Use the duckdb_from_date/duckdb_to_date function to extract individual information
duckdb_date :: struct {
	days:c.int32_t
}
duckdb_date_struct :: struct {
	year:c.int32_t,
	month:c.int8_t,
	day:c.int8_t,
}

//! Time is stored as microseconds since 00:00:00
//! Use the duckdb_from_time/duckdb_to_time function to extract individual information
duckdb_time :: struct {
	micros:c.int64_t
}
duckdb_time_struct :: struct {
	hour:c.int8_t,
	min:c.int8_t ,
	sec:c.int8_t,
	micros:c.int32_t,
}

//! TIME_TZ is stored as 40 bits for int64_t micros, and 24 bits for int32_t offset
duckdb_time_tz :: struct {
	bits:c.uint64_t
};
duckdb_time_tz_struct :: struct {
	time:duckdb_time_struct,
	offset:c.int32_t,
}

//! Timestamps are stored as microseconds since 1970-01-01
//! Use the duckdb_from_timestamp/duckdb_to_timestamp function to extract individual information
duckdb_timestamp :: struct {
	micros:c.int64_t
}
duckdb_timestamp_struct :: struct {
	date:duckdb_date_struct,
	time:duckdb_time_struct,
}
duckdb_interval :: struct {
	months:c.int32_t,
	days:c.int32_t,
	micros:c.int64_t,
}

//! Hugeints are composed of a (lower, upper) component
//! The value of the hugeint is upper * 2^64 + lower
//! For easy usage, the functions duckdb_hugeint_to_double/duckdb_double_to_hugeint are recommended
duckdb_hugeint :: struct {
	lower:c.uint64_t,
	upper:c.int64_t
}
duckdb_uhugeint :: struct {
	lower:c.uint64_t,
	upper:c.int64_t
}

//! Decimals are composed of a width and a scale, and are stored in a hugeint
duckdb_decimal :: struct {
	width:c.uint8_t,
	scale:c.uint8_t,
	value:duckdb_hugeint,
}

//! A type holding information about the query execution progress
duckdb_query_progress_type :: struct {
	percentage:c.double,
	rows_processed:c.uint64_t,
	total_rows_to_process:c.uint64_t,
}

//! The internal representation of a VARCHAR (string_t). If the VARCHAR does not
//! exceed 12 characters, then we inline it. Otherwise, we inline a prefix for faster
//! string comparisons and store a pointer to the remaining characters. This is a non-
//! owning structure, i.e., it does not have to be freed.
pointer :: struct {
	length:c.uint32_t,
	prefix:[4]c.char,
	ptr:^c.char,
}

inlined :: struct {
	length:c.uint32_t,
	prefix:[12]c.char,
}


duckdb_string_t :: struct {
	value : union {
		pointer,
		inlined,
	}
}

//! The internal representation of a list metadata entry contains the list's offset in
//! the child vector, and its length. The parent vector holds these metadata entries,
//! whereas the child vector holds the data
duckdb_list_entry :: struct {
	offset:c.uint64_t,
	length:c.uint64_t,
}

//! A column consists of a pointer to its internal data. Don't operate on this type directly.
//! Instead, use functions such as duckdb_column_data, duckdb_nullmask_data,
//! duckdb_column_type, and duckdb_column_name, which take the result and the column index
//! as their parameters

when DUCKDB_API_VERSION < DUCKDB_API_0_3_2 {
duckdb_column :: struct {
	data:rawptr,
	nullmask:^c.bool,
	type:duckdb_type,
	name:^c.char,
	internal_data:rawptr,
}
} else {
duckdb_column :: struct {
	// deprecated, use duckdb_column_data
	__deprecated_data:rawptr,
	// deprecated, use duckdb_nullmask_data
	__deprecated_nullmask:^c.bool,
	// deprecated, use duckdb_column_type
	__deprecated_type:duckdb_type,
	// deprecated, use duckdb_column_name
	__deprecated_name:^c.char,
	internal_data:rawptr,
}
}

	
//! A vector to a specified column in a data chunk. Lives as long as the
//! data chunk lives, i.e., must not be destroyed.
duckdb_vector :: ^struct {
	__vctr:rawptr,
}

//===--------------------------------------------------------------------===//
// Types (explicit freeing/destroying)
//===--------------------------------------------------------------------===//

//! Strings are composed of a char pointer and a size. You must free string.data
//! with `duckdb_free`.
duckdb_string :: struct {
	data:^c.char,
	size:idx_t
}

//! BLOBs are composed of a byte pointer and a size. You must free blob.data
//! with `duckdb_free`.
duckdb_blob :: struct {
	data:rawptr,
	size:idx_t,
}

//! A query result consists of a pointer to its internal data.
//! Must be freed with 'duckdb_destroy_result'.

when DUCKDB_API_VERSION < DUCKDB_API_0_3_2 {
duckdb_result :: struct {
	column_count:idx_t,
	row_count:idx_t,
	rows_changed:idx_t,
	columns:^duckdb_column,
	error_message:^c.char,
	internal_data:rawptr,
}
} else {
duckdb_result :: struct {
	// deprecated, use duckdb_column_count
	__deprecated_column_count:idx_t,
	// deprecated, use duckdb_row_count
	__deprecated_row_count:idx_t,
	// deprecated, use duckdb_rows_changed
	__deprecated_rows_changed:idx_t,
	// deprecated, use duckdb_column_*-family of functions
	__deprecated_columns:^duckdb_column,
	// deprecated, use duckdb_result_error
	__deprecated_error_message:^c.char,
	internal_data:rawptr,
}
}

//! A database object. Should be closed with `duckdb_close`.
duckdb_database :: ^struct {
	__db:rawptr,
}

//! A connection to a duckdb database. Must be closed with `duckdb_disconnect`.
duckdb_connection :: ^struct {
	__conn:rawptr,
}

//! A prepared statement is a parameterized query that allows you to bind parameters to it.
//! Must be destroyed with `duckdb_destroy_prepare`.
duckdb_prepared_statement :: ^struct {
	__prep:rawptr,
}

//! Extracted statements. Must be destroyed with `duckdb_destroy_extracted`.
duckdb_extracted_statements :: ^struct {
	__extrac:rawptr,
}

//! The pending result represents an intermediate structure for a query that is not yet fully executed.
//! Must be destroyed with `duckdb_destroy_pending`.
duckdb_pending_result :: ^struct {
	__pend:rawptr,
}

//! The appender enables fast data loading into DuckDB.
//! Must be destroyed with `duckdb_appender_destroy`.
duckdb_appender :: ^struct {
	__appn:rawptr,
}

//! Can be used to provide start-up options for the DuckDB instance.
//! Must be destroyed with `duckdb_destroy_config`.
duckdb_config :: ^struct {
	__cnfg:rawptr,
}

//! Holds an internal logical type.
//! Must be destroyed with `duckdb_destroy_logical_type`.
duckdb_logical_type :: ^struct {
	__lglt:rawptr,
}

//! Contains a data chunk from a duckdb_result.
//! Must be destroyed with `duckdb_destroy_data_chunk`.
duckdb_data_chunk :: ^struct {
	__dtck:rawptr,
}
//! Holds a DuckDB value, which wraps a type.
//! Must be destroyed with `duckdb_destroy_value`.
duckdb_value :: ^struct {
	__val:rawptr,
}

//===--------------------------------------------------------------------===//
// Table function types
//===--------------------------------------------------------------------===//

//! A table function. Must be destroyed with `duckdb_destroy_table_function`.
duckdb_table_function :: rawptr

//! The bind info of the function. When setting this info, it is necessary to pass a destroy-callback function.
duckdb_bind_info :: rawptr

//! Additional function init info. When setting this info, it is necessary to pass a destroy-callback function.
duckdb_init_info :: rawptr

//! Additional function info. When setting this info, it is necessary to pass a destroy-callback function.
duckdb_function_info :: rawptr

//! The bind function of the table function.
duckdb_table_function_bind_t :: ^proc(info:duckdb_bind_info)

//! The (possibly thread-local) init function of the table function.
duckdb_table_function_init_t :: ^proc(info:duckdb_init_info)

//! The main function of the table function.
duckdb_table_function_t :: ^proc(info:duckdb_function_info, output:duckdb_data_chunk)

//===--------------------------------------------------------------------===//
// Replacement scan types
//===--------------------------------------------------------------------===//

//! Additional replacement scan info. When setting this info, it is necessary to pass a destroy-callback function.
duckdb_replacement_scan_info :: rawptr

//! A replacement scan function that can be added to a database.
duckdb_replacement_callback_t :: ^proc(info:duckdb_replacement_scan_info, table_name:cstring, data:rawptr)

//===--------------------------------------------------------------------===//
// Arrow-related types
//===--------------------------------------------------------------------===//

//! Holds an arrow query result. Must be destroyed with `duckdb_destroy_arrow`.
duckdb_arrow :: ^struct {
	__arrw:rawptr,
}

//! Holds an arrow array stream. Must be destroyed with `duckdb_destroy_arrow_stream`.
duckdb_arrow_stream :: ^struct {
	__arrwstr:rawptr,
}

//! Holds an arrow schema. Remember to release the respective ArrowSchema object.
duckdb_arrow_schema :: ^struct {
	__arrs:rawptr,
}

//! Holds an arrow array. Remember to release the respective ArrowArray object.
duckdb_arrow_array :: ^struct {
	__arra:rawptr,
}

//===--------------------------------------------------------------------===//
// Functions
//===--------------------------------------------------------------------===//
@(default_calling_convention="c", link_prefix="duckdb_")
foreign duckdb {
//===--------------------------------------------------------------------===//
// Open/Connect
//===--------------------------------------------------------------------===//

/*!
Creates a new database or opens an existing database file stored at the given path.
If no path is given a new in-memory database is created instead.
The instantiated database should be closed with 'duckdb_close'.

* path: Path to the database file on disk, or `nullptr` or `:memory:` to open an in-memory database.
* out_database: The result database object.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/



open :: proc (path:cstring, out_database:^duckdb_database) -> duckdb_state ---

/*!
Extended version of duckdb_open. Creates a new database or opens an existing database file stored at the given path.
The instantiated database should be closed with 'duckdb_close'.

* path: Path to the database file on disk, or `nullptr` or `:memory:` to open an in-memory database.
* out_database: The result database object.
* config: (Optional) configuration used to start up the database system.
* out_error: If set and the function returns DuckDBError, this will contain the reason why the start-up failed.
Note that the error must be freed using `duckdb_free`.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
open_ext :: proc (path:cstring, out_database:^duckdb_database, config:duckdb_config, out_error:^^c.char) -> duckdb_state ---


/*!
Closes the specified database and de-allocates all memory allocated for that database.
This should be called after you are done with any database allocated through `duckdb_open` or `duckdb_open_ext`.
Note that failing to call `duckdb_close` (in case of e.g. a program crash) will not cause data corruption.
Still, it is recommended to always correctly close a database object after you are done with it.

* database: The database object to shut down.
*/
close :: proc (database:^duckdb_database) ---

/*!
Opens a connection to a database. Connections are required to query the database, and store transactional state
associated with the connection.
The instantiated connection should be closed using 'duckdb_disconnect'.

* database: The database file to connect to.
* out_connection: The result connection object.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
connect :: proc (database:duckdb_database, out_connection:^duckdb_connection) -> duckdb_state ---

/*!
Interrupt running query

* connection: The connection to interrupt
*/
interrupt :: proc (connection:duckdb_connection) ---

/*!
Get progress of the running query

* connection: The working connection
* returns: -1 if no progress or a percentage of the progress
*/
query_progress :: proc (connection:duckdb_connection) -> duckdb_query_progress_type ---

/*!
Closes the specified connection and de-allocates all memory allocated for that connection.

* connection: The connection to close.
*/
disconnect :: proc (connection:^duckdb_connection) ---

/*!
Returns the version of the linked DuckDB, with a version postfix for dev versions

Usually used for developing C extensions that must return this for a compatibility check.
*/
library_version :: proc () -> cstring ---


//===--------------------------------------------------------------------===//
// Configuration
//===--------------------------------------------------------------------===//

/*!
Initializes an empty configuration object that can be used to provide start-up options for the DuckDB instance
through `duckdb_open_ext`.
The duckdb_config must be destroyed using 'duckdb_destroy_config'

This will always succeed unless there is a malloc failure.

* out_config: The result configuration object.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
create_config :: proc (out_config:^duckdb_config) -> duckdb_state ---

/*!
This returns the total amount of configuration options available for usage with `duckdb_get_config_flag`.

This should not be called in a loop as it internally loops over all the options.

* returns: The amount of config options available.
*/
config_count :: proc () -> c.size_t ---

/*!
Obtains a human-readable name and description of a specific configuration option. This can be used to e.g.
display configuration options. This will succeed unless `index` is out of range (i.e. `>= duckdb_config_count`).

The result name or description MUST NOT be freed.

* index: The index of the configuration option (between 0 and `duckdb_config_count`)
* out_name: A name of the configuration flag.
* out_description: A description of the configuration flag.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
get_config_flag :: proc (index:c.size_t, out_name:^cstring, out_description:^cstring) -> duckdb_state ---

/*!
Sets the specified option for the specified configuration. The configuration option is indicated by name.
To obtain a list of config options, see `duckdb_get_config_flag`.

In the source code, configuration options are defined in `config.cpp`.

This can fail if either the name is invalid, or if the value provided for the option is invalid.

* duckdb_config: The configuration object to set the option on.
* name: The name of the configuration flag to set.
* option: The value to set the configuration flag to.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
set_config :: proc (config:duckdb_config, name:cstring, option:cstring) -> duckdb_state ---

/*!
Destroys the specified configuration object and de-allocates all memory allocated for the object.

* config: The configuration object to destroy.
*/
destroy_config :: proc (config:^duckdb_config) ---

//===--------------------------------------------------------------------===//
// Query Execution
//===--------------------------------------------------------------------===//

/*!
Executes a SQL query within a connection and stores the full (materialized) result in the out_result pointer.
If the query fails to execute, DuckDBError is returned and the error message can be retrieved by calling
`duckdb_result_error`.

Note that after running `duckdb_query`, `duckdb_destroy_result` must be called on the result object even if the
query fails, otherwise the error stored within the result will not be freed correctly.

* connection: The connection to perform the query in.
* query: The SQL query to run.
* out_result: The query result.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
query :: proc (connection:duckdb_connection, query:cstring, out_result:^duckdb_result) -> duckdb_state ---

/*!
Closes the result and de-allocates all memory allocated for that connection.

* result: The result to destroy.
*/
destroy_result :: proc (result:^duckdb_result) ---

/*!
Returns the column name of the specified column. The result should not need to be freed; the column names will
automatically be destroyed when the result is destroyed.

Returns `NULL` if the column is out of range.

* result: The result object to fetch the column name from.
* col: The column index.
* returns: The column name of the specified column.
*/
column_name :: proc (result:^duckdb_result, col:idx_t) -> cstring ---

/*!
Returns the column type of the specified column.

Returns `DUCKDB_TYPE_INVALID` if the column is out of range.

* result: The result object to fetch the column type from.
* col: The column index.
* returns: The column type of the specified column.
*/
column_type :: proc (result:^duckdb_result, col:idx_t) -> duckdb_type ---

/*!
Returns the statement type of the statement that was executed

* result: The result object to fetch the statement type from.
 * returns: duckdb_statement_type value or DUCKDB_STATEMENT_TYPE_INVALID
 */
result_statement_type :: proc (result:duckdb_result) -> duckdb_statement_type ---

/*!
Returns the logical column type of the specified column.

The return type of this call should be destroyed with `duckdb_destroy_logical_type`.

Returns `NULL` if the column is out of range.

* result: The result object to fetch the column type from.
* col: The column index.
* returns: The logical column type of the specified column.
*/
column_logical_type :: proc (result:^duckdb_result, col:idx_t) -> duckdb_logical_type ---

/*!
Returns the number of columns present in a the result object.

* result: The result object.
* returns: The number of columns present in the result object.
*/
column_count :: proc (result:^duckdb_result) -> idx_t ---

/*!
Returns the number of rows present in the result object.

* result: The result object.
* returns: The number of rows present in the result object.
*/
row_count :: proc (result:^duckdb_result) -> idx_t ---

/*!
Returns the number of rows changed by the query stored in the result. This is relevant only for INSERT/UPDATE/DELETE
queries. For other queries the rows_changed will be 0.

* result: The result object.
* returns: The number of rows changed.
*/
rows_changed :: proc (result:^duckdb_result) -> idx_t ---

/*!
**DEPRECATED**: Prefer using `duckdb_result_get_chunk` instead.

Returns the data of a specific column of a result in columnar format.

The function returns a dense array which contains the result data. The exact type stored in the array depends on the
corresponding duckdb_type (as provided by `duckdb_column_type`). For the exact type by which the data should be
accessed, see the comments in [the types section](types) or the `DUCKDB_TYPE` enum.

For example, for a column of type `DUCKDB_TYPE_INTEGER`, rows can be accessed in the following manner:
```c
int32_t *data = (int32_t *) duckdb_column_data(&result, 0);
printf("Data for row %d: %d\n", row, data[row]);
```

* result: The result object to fetch the column data from.
* col: The column index.
* returns: The column data of the specified column.
*/
column_data :: proc (result:^duckdb_result, col:idx_t) -> rawptr ---

/*!
**DEPRECATED**: Prefer using `duckdb_result_get_chunk` instead.

Returns the nullmask of a specific column of a result in columnar format. The nullmask indicates for every row
whether or not the corresponding row is `NULL`. If a row is `NULL`, the values present in the array provided
by `duckdb_column_data` are undefined.

```c
int32_t *data = (int32_t *) duckdb_column_data(&result, 0);
bool *nullmask = duckdb_nullmask_data(&result, 0);
if (nullmask[row]) {
    printf("Data for row %d: NULL\n", row);
} else {
    printf("Data for row %d: %d\n", row, data[row]);
}
```

* result: The result object to fetch the nullmask from.
* col: The column index.
* returns: The nullmask of the specified column.
*/
nullmask_data :: proc (result:^duckdb_result, col:idx_t) -> ^c.bool ---

/*!
Returns the error message contained within the result. The error is only set if `duckdb_query` returns `DuckDBError`.

The result of this function must not be freed. It will be cleaned up when `duckdb_destroy_result` is called.

* result: The result object to fetch the error from.
* returns: The error of the result.
*/
result_error :: proc (result:^duckdb_result) -> cstring ---


//===--------------------------------------------------------------------===//
// Result Functions
//===--------------------------------------------------------------------===//

/*!
Fetches a data chunk from the duckdb_result. This function should be called repeatedly until the result is exhausted.

The result must be destroyed with `duckdb_destroy_data_chunk`.

This function supersedes all `duckdb_value` functions, as well as the `duckdb_column_data` and `duckdb_nullmask_data`
functions. It results in significantly better performance, and should be preferred in newer code-bases.

If this function is used, none of the other result functions can be used and vice versa (i.e. this function cannot be
mixed with the legacy result functions).

Use `duckdb_result_chunk_count` to figure out how many chunks there are in the result.

* result: The result object to fetch the data chunk from.
* chunk_index: The chunk index to fetch from.
* returns: The resulting data chunk. Returns `NULL` if the chunk index is out of bounds.
*/
result_get_chunk :: proc (result:^duckdb_result, chunk_index:idx_t) -> duckdb_data_chunk ---

/*!
Checks if the type of the internal result is StreamQueryResult.

* result: The result object to check.
* returns: Whether or not the result object is of the type StreamQueryResult
*/
result_is_streaming :: proc (result:duckdb_result) -> bool ---

/*!
Returns the number of data chunks present in the result.

* result: The result object
* returns: Number of data chunks present in the result.
*/
result_chunk_count :: proc (result:duckdb_result) -> idx_t ---

/*!
Returns the return_type of the given result, or DUCKDB_RETURN_TYPE_INVALID on error

* result: The result object
* returns: The return_type
 */
result_return_type :: proc (result:duckdb_result) -> duckdb_result_type ---

//===--------------------------------------------------------------------===//
// Safe fetch functions
//===--------------------------------------------------------------------===//

// These functions will perform conversions if necessary.
// On failure (e.g. if conversion cannot be performed or if the value is NULL) a default value is returned.
// Note that these functions are slow since they perform bounds checking and conversion
// For fast access of values prefer using `duckdb_result_get_chunk`

/*!
 * returns: The boolean value at the specified location, or false if the value cannot be converted.
 */
value_boolean :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> c.bool ---

/*!
 * returns: The int8_t value at the specified location, or 0 if the value cannot be converted.
 */
value_int8 :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> c.int8_t ---

/*!
 * returns: The int16_t value at the specified location, or 0 if the value cannot be converted.
 */
value_int16 :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> c.int16_t ---

/*!
 * returns: The int32_t value at the specified location, or 0 if the value cannot be converted.
 */
value_int32 :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> c.int32_t ---

/*!
 * returns: The int64_t value at the specified location, or 0 if the value cannot be converted.
 */
value_int64 :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> c.int64_t ---

/*!
 * returns: The duckdb_hugeint value at the specified location, or 0 if the value cannot be converted.
 */
value_hugeint :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> duckdb_hugeint ---

/*!
 * returns: The duckdb_uhugeint value at the specified location, or 0 if the value cannot be converted.
 */
value_uhugeint :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> duckdb_uhugeint ---

/*!
 * returns: The duckdb_decimal value at the specified location, or 0 if the value cannot be converted.
 */
value_decimal :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> duckdb_decimal ---

/*!
 * returns: The uint8_t value at the specified location, or 0 if the value cannot be converted.
 */
value_uint8 :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> c.uint8_t ---

/*!
 * returns: The uint16_t value at the specified location, or 0 if the value cannot be converted.
 */
value_uint16 :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> c.uint16_t ---

/*!
 * returns: The uint32_t value at the specified location, or 0 if the value cannot be converted.
 */
value_uint32 :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> c.uint32_t ---

/*!
 * returns: The uint64_t value at the specified location, or 0 if the value cannot be converted.
 */
value_uint64 :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> c.uint64_t ---

/*!
 * returns: The float value at the specified location, or 0 if the value cannot be converted.
 */
value_float :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> c.float ---

/*!
 * returns: The double value at the specified location, or 0 if the value cannot be converted.
 */
value_double :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> c.double ---

/*!
 * returns: The duckdb_date value at the specified location, or 0 if the value cannot be converted.
 */
value_date :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> duckdb_date ---

/*!
 * returns: The duckdb_time value at the specified location, or 0 if the value cannot be converted.
 */
value_time :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> duckdb_time ---

/*!
 * returns: The duckdb_timestamp value at the specified location, or 0 if the value cannot be converted.
 */
value_timestamp :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> duckdb_timestamp ---

/*!
 * returns: The duckdb_interval value at the specified location, or 0 if the value cannot be converted.
 */
value_interval :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> duckdb_interval ---

/*!
* DEPRECATED: use duckdb_value_string instead. This function does not work correctly if the string contains null bytes.
* returns: The text value at the specified location as a null-terminated string, or nullptr if the value cannot be
converted. The result must be freed with `duckdb_free`.
*/
value_varchar :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> ^c.char ---

/*!
 * returns: The string value at the specified location.
 * The resulting field "string.data" must be freed with `duckdb_free.`
 */
value_string :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> duckdb_string ---

/*!
* DEPRECATED: use duckdb_value_string_internal instead. This function does not work correctly if the string contains
null bytes.
* returns: The char* value at the specified location. ONLY works on VARCHAR columns and does not auto-cast.
If the column is NOT a VARCHAR column this function will return NULL.

The result must NOT be freed.
*/
value_varchar_internal :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> ^c.char ---

/*!
* DEPRECATED: use duckdb_value_string_internal instead. This function does not work correctly if the string contains
null bytes.
* returns: The char* value at the specified location. ONLY works on VARCHAR columns and does not auto-cast.
If the column is NOT a VARCHAR column this function will return NULL.

The result must NOT be freed.
*/
value_string_internal :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> duckdb_string ---

/*!
* returns: The duckdb_blob value at the specified location. Returns a blob with blob.data set to nullptr if the
value cannot be converted. The resulting field "blob.data" must be freed with `duckdb_free.`
*/
value_blob :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> duckdb_blob ---

/*!
 * returns: Returns true if the value at the specified index is NULL, and false otherwise.
 */
value_is_null :: proc (result:^duckdb_result, col:idx_t, row:idx_t) -> bool ---


//===--------------------------------------------------------------------===//
// Helpers
//===--------------------------------------------------------------------===//

/*!
Allocate `size` bytes of memory using the duckdb internal malloc function. Any memory allocated in this manner
should be freed using `duckdb_free`.

* size: The number of bytes to allocate.
* returns: A pointer to the allocated memory region.
*/
malloc :: proc (size:c.size_t) -> rawptr ---

/*!
Free a value returned from `duckdb_malloc`, `duckdb_value_varchar`, `duckdb_value_blob`, or
`duckdb_value_string`.

* ptr: The memory region to de-allocate.
*/
free :: proc (ptr:rawptr) ---

/*!
The internal vector size used by DuckDB.
This is the amount of tuples that will fit into a data chunk created by `duckdb_create_data_chunk`.

* returns: The vector size.
*/
vector_size :: proc () -> idx_t ---

/*!
Whether or not the duckdb_string_t value is inlined.
This means that the data of the string does not have a separate allocation.

*/
string_is_inlined :: proc (string:duckdb_string_t) -> bool ---



//===--------------------------------------------------------------------===//
// Date/Time/Timestamp Helpers
//===--------------------------------------------------------------------===//

/*!
Decompose a `duckdb_date` object into year, month and date (stored as `duckdb_date_struct`).

* date: The date object, as obtained from a `DUCKDB_TYPE_DATE` column.
* returns: The `duckdb_date_struct` with the decomposed elements.
*/

from_date :: proc (date:duckdb_date) -> duckdb_date_struct ---

/*!
Re-compose a `duckdb_date` from year, month and date (`duckdb_date_struct`).

* date: The year, month and date stored in a `duckdb_date_struct`.
* returns: The `duckdb_date` element.
*/
to_date :: proc (date:duckdb_date_struct) -> duckdb_date ---

/*!
Test a `duckdb_date` to see if it is a finite value.

* date: The date object, as obtained from a `DUCKDB_TYPE_DATE` column.
* returns: True if the date is finite, false if it is ±infinity.
*/
is_finite_date :: proc (date:duckdb_date) -> bool ---

/*!
Decompose a `duckdb_time` object into hour, minute, second and microsecond (stored as `duckdb_time_struct`).

* time: The time object, as obtained from a `DUCKDB_TYPE_TIME` column.
* returns: The `duckdb_time_struct` with the decomposed elements.
*/
from_time :: proc (time:duckdb_time) -> duckdb_time_struct ---

/*!
Create a `duckdb_time_tz` object from micros and a timezone offset.

* micros: The microsecond component of the time.
* offset: The timezone offset component of the time.
* returns: The `duckdb_time_tz` element.
*/
create_time_tz :: proc (micros:c.int64_t, offset:c.int32_t) -> duckdb_time_tz ---

/*!
Decompose a TIME_TZ objects into micros and a timezone offset.

Use `duckdb_from_time` to further decompose the micros into hour, minute, second and microsecond.

* micros: The time object, as obtained from a `DUCKDB_TYPE_TIME_TZ` column.
* out_micros: The microsecond component of the time.
* out_offset: The timezone offset component of the time.
*/
from_time_tz :: proc (micros:duckdb_time_tz) -> duckdb_time_tz_struct ---

/*!
Re-compose a `duckdb_time` from hour, minute, second and microsecond (`duckdb_time_struct`).

* time: The hour, minute, second and microsecond in a `duckdb_time_struct`.
* returns: The `duckdb_time` element.
*/
to_time :: proc (time:duckdb_time_struct) -> duckdb_time ---

/*!
Decompose a `duckdb_timestamp` object into a `duckdb_timestamp_struct`.

* ts: The ts object, as obtained from a `DUCKDB_TYPE_TIMESTAMP` column.
* returns: The `duckdb_timestamp_struct` with the decomposed elements.
*/
from_timestamp :: proc (ts:duckdb_timestamp) -> duckdb_timestamp_struct ---

/*!
Re-compose a `duckdb_timestamp` from a duckdb_timestamp_struct.

* ts: The de-composed elements in a `duckdb_timestamp_struct`.
* returns: The `duckdb_timestamp` element.
*/
to_timestamp :: proc (ts:duckdb_timestamp_struct) -> duckdb_timestamp ---

/*!
Test a `duckdb_timestamp` to see if it is a finite value.

* ts: The timestamp object, as obtained from a `DUCKDB_TYPE_TIMESTAMP` column.
* returns: True if the timestamp is finite, false if it is ±infinity.
*/
is_finite_timestamp :: proc (ts:duckdb_timestamp) -> bool ---



//===--------------------------------------------------------------------===//
// Hugeint Helpers
//===--------------------------------------------------------------------===//

/*!
Converts a duckdb_hugeint object (as obtained from a `DUCKDB_TYPE_HUGEINT` column) into a double.

* val: The hugeint value.
* returns: The converted `double` element.
*/
hugeint_to_double :: proc (val:duckdb_hugeint) -> c.double ---

/*!
Converts a double value to a duckdb_hugeint object.

If the conversion fails because the double value is too big the result will be 0.

* val: The double value.
* returns: The converted `duckdb_hugeint` element.
*/
double_to_hugeint :: proc (val:c.double) -> duckdb_hugeint ---

//===--------------------------------------------------------------------===//
// Unsigned Hugeint Helpers
//===--------------------------------------------------------------------===//

/*!
Converts a duckdb_uhugeint object (as obtained from a `DUCKDB_TYPE_UHUGEINT` column) into a double.

* val: The uhugeint value.
* returns: The converted `double` element.
*/
uhugeint_to_double :: proc (val:duckdb_uhugeint) -> c.double ---

/*!
Converts a double value to a duckdb_uhugeint object.

If the conversion fails because the double value is too big the result will be 0.

* val: The double value.
* returns: The converted `duckdb_uhugeint` element.
*/
double_to_uhugeint :: proc (val:c.double) -> duckdb_uhugeint ---

//===--------------------------------------------------------------------===//
// Decimal Helpers
//===--------------------------------------------------------------------===//

/*!
Converts a double value to a duckdb_decimal object.

If the conversion fails because the double value is too big, or the width/scale are invalid the result will be 0.

* val: The double value.
* returns: The converted `duckdb_decimal` element.
*/
double_to_decimal :: proc (val:c.double, width:c.uint8_t, scale:c.uint8_t) -> duckdb_decimal ---

/*!
Converts a duckdb_decimal object (as obtained from a `DUCKDB_TYPE_DECIMAL` column) into a double.

* val: The decimal value.
* returns: The converted `double` element.
*/
decimal_to_double :: proc (val:duckdb_decimal) -> c.double ---

//===--------------------------------------------------------------------===//
// Prepared Statements
//===--------------------------------------------------------------------===//

// A prepared statement is a parameterized query that allows you to bind parameters to it.
// * This is useful to easily supply parameters to functions and avoid SQL injection attacks.
// * This is useful to speed up queries that you will execute several times with different parameters.
// Because the query will only be parsed, bound, optimized and planned once during the prepare stage,
// rather than once per execution.
// For example:
//   SELECT * FROM tbl WHERE id=?
// Or a query with multiple parameters:
//   SELECT * FROM tbl WHERE id=$1 OR name=$2

/*!
Create a prepared statement object from a query.

Note that after calling `duckdb_prepare`, the prepared statement should always be destroyed using
`duckdb_destroy_prepare`, even if the prepare fails.

If the prepare fails, `duckdb_prepare_error` can be called to obtain the reason why the prepare failed.

* connection: The connection object
* query: The SQL query to prepare
* out_prepared_statement: The resulting prepared statement object
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
prepare :: proc (connection:duckdb_connection, query:cstring, out_prepared_statement:^duckdb_prepared_statement) -> duckdb_state ---

/*!
Closes the prepared statement and de-allocates all memory allocated for the statement.

* prepared_statement: The prepared statement to destroy.
*/
destroy_prepare :: proc (prepared_statement:^duckdb_prepared_statement) ---

/*!
Returns the error message associated with the given prepared statement.
If the prepared statement has no error message, this returns `nullptr` instead.

The error message should not be freed. It will be de-allocated when `duckdb_destroy_prepare` is called.

* prepared_statement: The prepared statement to obtain the error from.
* returns: The error message, or `nullptr` if there is none.
*/
prepare_error :: proc (prepared_statement:duckdb_prepared_statement) -> cstring ---

/*!
Returns the number of parameters that can be provided to the given prepared statement.

Returns 0 if the query was not successfully prepared.

* prepared_statement: The prepared statement to obtain the number of parameters for.
*/
nparams :: proc (prepared_statement:duckdb_prepared_statement) -> idx_t ---

/*!
Returns the name used to identify the parameter
The returned string should be freed using `duckdb_free`.

Returns NULL if the index is out of range for the provided prepared statement.

* prepared_statement: The prepared statement for which to get the parameter name from.
*/
parameter_name :: proc (prepared_statement:duckdb_prepared_statement, index:idx_t) -> cstring ---

/*!
Returns the parameter type for the parameter at the given index.

Returns `DUCKDB_TYPE_INVALID` if the parameter index is out of range or the statement was not successfully prepared.

* prepared_statement: The prepared statement.
* param_idx: The parameter index.
* returns: The parameter type
*/
param_type :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t) -> duckdb_type ---

/*!
Clear the params bind to the prepared statement.
*/
clear_bindings :: proc (prepared_statement:duckdb_prepared_statement) -> duckdb_state ---

/*!
Returns the statement type of the statement to be executed

* statement: The prepared statement.
* returns: duckdb_statement_type value or DUCKDB_STATEMENT_TYPE_INVALID
*/
prepared_statement_type :: proc (statement:duckdb_prepared_statement) -> duckdb_statement_type ---

//===--------------------------------------------------------------------===//
// Bind Values to Prepared Statements
//===--------------------------------------------------------------------===//

/*!
Binds a value to the prepared statement at the specified index.
*/
bind_value :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:duckdb_value) -> duckdb_state ---

/*!
Retrieve the index of the parameter for the prepared statement, identified by name
*/
bind_parameter_index :: proc (prepared_statement:duckdb_prepared_statement, param_idx_out:^idx_t, name:cstring) -> duckdb_state ---

/*!
Binds a bool value to the prepared statement at the specified index.
*/
bind_boolean :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:bool) -> duckdb_state ---

/*!
Binds an int8_t value to the prepared statement at the specified index.
*/
bind_int8 :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:c.int8_t) -> duckdb_state ---

/*!
Binds an int16_t value to the prepared statement at the specified index.
*/
bind_int16 :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:c.int16_t) -> duckdb_state ---

/*!
Binds an int32_t value to the prepared statement at the specified index.
*/
bind_int32 :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:c.int32_t) -> duckdb_state ---

/*!
Binds an int64_t value to the prepared statement at the specified index.
*/
bind_int64 :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:c.int64_t) -> duckdb_state ---

/*!
Binds a duckdb_hugeint value to the prepared statement at the specified index.
*/
bind_hugeint :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:duckdb_hugeint) -> duckdb_state ---

/*!
Binds an duckdb_uhugeint value to the prepared statement at the specified index.
*/
bind_uhugeint :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:duckdb_uhugeint) -> duckdb_state ---

/*!
Binds a duckdb_decimal value to the prepared statement at the specified index.
*/
bind_decimal :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:duckdb_decimal) -> duckdb_state ---

/*!
Binds an uint8_t value to the prepared statement at the specified index.
*/
bind_uint8 :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:c.uint8_t) -> duckdb_state ---

/*!
Binds an uint16_t value to the prepared statement at the specified index.
*/
bind_uint16 :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:c.uint16_t) -> duckdb_state ---

/*!
Binds an uint32_t value to the prepared statement at the specified index.
*/
bind_uint32 :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:c.uint32_t) -> duckdb_state ---

/*!
Binds an uint64_t value to the prepared statement at the specified index.
*/
bind_uint64 :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:c.uint64_t) -> duckdb_state ---

/*!
Binds a float value to the prepared statement at the specified index.
*/
bind_float :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:c.float) -> duckdb_state ---

/*!
Binds a double value to the prepared statement at the specified index.
*/
bind_double :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:c.double) -> duckdb_state ---

/*!
Binds a duckdb_date value to the prepared statement at the specified index.
*/
bind_date :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:duckdb_date) -> duckdb_state ---

/*!
Binds a duckdb_time value to the prepared statement at the specified index.
*/
bind_time :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:duckdb_time) -> duckdb_state ---

/*!
Binds a duckdb_timestamp value to the prepared statement at the specified index.
*/
bind_timestamp :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:duckdb_timestamp) -> duckdb_state ---

/*!
Binds a duckdb_interval value to the prepared statement at the specified index.
*/
bind_interval :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:duckdb_interval) -> duckdb_state ---

/*!
Binds a null-terminated varchar value to the prepared statement at the specified index.
*/
bind_varchar :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:cstring) -> duckdb_state ---

/*!
Binds a varchar value to the prepared statement at the specified index.
*/
bind_varchar_length :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, val:cstring, length:idx_t) -> duckdb_state ---

/*!
Binds a blob value to the prepared statement at the specified index.
*/
bind_blob :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t, data:rawptr,length:idx_t) -> duckdb_state ---

/*!
Binds a NULL value to the prepared statement at the specified index.
*/
bind_null :: proc (prepared_statement:duckdb_prepared_statement, param_idx:idx_t) -> duckdb_state ---

//===--------------------------------------------------------------------===//
// Execute Prepared Statements
//===--------------------------------------------------------------------===//

/*!
Executes the prepared statement with the given bound parameters, and returns a materialized query result.

This method can be called multiple times for each prepared statement, and the parameters can be modified
between calls to this function.

Note that the result must be freed with `duckdb_destroy_result`.

* prepared_statement: The prepared statement to execute.
* out_result: The query result.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
execute_prepared :: proc (prepared_statement:duckdb_prepared_statement, out_result:^duckdb_result) -> duckdb_state ---

/*!
Executes the prepared statement with the given bound parameters, and returns an optionally-streaming query result.
To determine if the resulting query was in fact streamed, use `duckdb_result_is_streaming`

This method can be called multiple times for each prepared statement, and the parameters can be modified
between calls to this function.

Note that the result must be freed with `duckdb_destroy_result`.

* prepared_statement: The prepared statement to execute.
* out_result: The query result.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
execute_prepared_streaming :: proc (prepared_statement:duckdb_prepared_statement, out_result:^duckdb_result) -> duckdb_state ---

//===--------------------------------------------------------------------===//
// Extract Statements
//===--------------------------------------------------------------------===//

// A query string can be extracted into multiple SQL statements. Each statement can be prepared and executed separately.

/*!
Extract all statements from a query.
Note that after calling `duckdb_extract_statements`, the extracted statements should always be destroyed using
`duckdb_destroy_extracted`, even if no statements were extracted.

If the extract fails, `duckdb_extract_statements_error` can be called to obtain the reason why the extract failed.

* connection: The connection object
* query: The SQL query to extract
* out_extracted_statements: The resulting extracted statements object
* returns: The number of extracted statements or 0 on failure.
*/
extract_statements :: proc (connection:duckdb_connection, query:cstring, out_extracted_statements:^duckdb_extracted_statements) -> idx_t ---

/*!
Prepare an extracted statement.
Note that after calling `duckdb_prepare_extracted_statement`, the prepared statement should always be destroyed using
`duckdb_destroy_prepare`, even if the prepare fails.

If the prepare fails, `duckdb_prepare_error` can be called to obtain the reason why the prepare failed.

* connection: The connection object
* extracted_statements: The extracted statements object
* index: The index of the extracted statement to prepare
* out_prepared_statement: The resulting prepared statement object
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
prepare_extracted_statement :: proc (connection:duckdb_connection, extracted_statements:duckdb_extracted_statements, index:idx_t, out_prepared_statement:^duckdb_prepared_statement) -> duckdb_state ---

/*!
Returns the error message contained within the extracted statements.
The result of this function must not be freed. It will be cleaned up when `duckdb_destroy_extracted` is called.

* result: The extracted statements to fetch the error from.
* returns: The error of the extracted statements.
*/
extracted_statements_error :: proc (extracted_statements:duckdb_extracted_statements) -> cstring ---

/*!
De-allocates all memory allocated for the extracted statements.
* extracted_statements: The extracted statements to destroy.
*/
destroy_extracted :: proc (extracted_statements:^duckdb_extracted_statements) ---

//===--------------------------------------------------------------------===//
// Pending Result Interface
//===--------------------------------------------------------------------===//

/*!
Executes the prepared statement with the given bound parameters, and returns a pending result.
The pending result represents an intermediate structure for a query that is not yet fully executed.
The pending result can be used to incrementally execute a query, returning control to the client between tasks.

Note that after calling `duckdb_pending_prepared`, the pending result should always be destroyed using
`duckdb_destroy_pending`, even if this function returns DuckDBError.

* prepared_statement: The prepared statement to execute.
* out_result: The pending query result.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
pending_prepared :: proc (prepared_statement:duckdb_prepared_statement, out_result:^duckdb_pending_result) -> duckdb_state ---

/*!
Executes the prepared statement with the given bound parameters, and returns a pending result.
This pending result will create a streaming duckdb_result when executed.
The pending result represents an intermediate structure for a query that is not yet fully executed.

Note that after calling `duckdb_pending_prepared_streaming`, the pending result should always be destroyed using
`duckdb_destroy_pending`, even if this function returns DuckDBError.

* prepared_statement: The prepared statement to execute.
* out_result: The pending query result.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
pending_prepared_streaming :: proc (prepared_statement:duckdb_prepared_statement, out_result:^duckdb_pending_result) -> duckdb_state ---


/*!
Closes the pending result and de-allocates all memory allocated for the result.

* pending_result: The pending result to destroy.
*/
destroy_pending :: proc (pending_result:^duckdb_pending_result) ---

/*!
Returns the error message contained within the pending result.

The result of this function must not be freed. It will be cleaned up when `duckdb_destroy_pending` is called.

* result: The pending result to fetch the error from.
* returns: The error of the pending result.
*/
pending_error :: proc (result:duckdb_pending_result) -> cstring ---

/*!
Executes a single task within the query, returning whether or not the query is ready.

If this returns DUCKDB_PENDING_RESULT_READY, the duckdb_execute_pending function can be called to obtain the result.
If this returns DUCKDB_PENDING_RESULT_NOT_READY, the duckdb_pending_execute_task function should be called again.
If this returns DUCKDB_PENDING_ERROR, an error occurred during execution.

The error message can be obtained by calling duckdb_pending_error on the pending_result.

* pending_result: The pending result to execute a task within.
* returns: The state of the pending result after the execution.
*/
pending_execute_task :: proc (pending_result:duckdb_pending_result) -> duckdb_pending_state ---

/*!
If this returns DUCKDB_PENDING_RESULT_READY, the duckdb_execute_pending function can be called to obtain the result.
If this returns DUCKDB_PENDING_RESULT_NOT_READY, the duckdb_pending_execute_check_state function should be called again.
If this returns DUCKDB_PENDING_ERROR, an error occurred during execution.

The error message can be obtained by calling duckdb_pending_error on the pending_result.

* pending_result: The pending result.
* returns: The state of the pending result.
*/
pending_execute_check_state :: proc (pending_result:duckdb_pending_result) -> duckdb_pending_state ---

/*!
Fully execute a pending query result, returning the final query result.

If duckdb_pending_execute_task has been called until DUCKDB_PENDING_RESULT_READY was returned, this will return fast.
Otherwise, all remaining tasks must be executed first.

Note that the result must be freed with `duckdb_destroy_result`.

* pending_result: The pending result to execute.
* out_result: The result object.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
execute_pending :: proc (pending_result:duckdb_pending_result, out_result:^duckdb_result) -> duckdb_state ---

/*!
Returns whether a duckdb_pending_state is finished executing. For example if `pending_state` is
DUCKDB_PENDING_RESULT_READY, this function will return true.

* pending_state: The pending state on which to decide whether to finish execution.
* returns: Boolean indicating pending execution should be considered finished.
*/
pending_execution_is_finished :: proc (pending_state:duckdb_pending_state) -> bool ---

//===--------------------------------------------------------------------===//
// Value Interface
//===--------------------------------------------------------------------===//

/*!
Destroys the value and de-allocates all memory allocated for that type.

* value: The value to destroy.
*/
destroy_value :: proc (value:^duckdb_value) ---

/*!
Creates a value from a null-terminated string

* value: The null-terminated string
* returns: The value. This must be destroyed with `duckdb_destroy_value`.
*/
create_varchar :: proc (text:cstring) -> duckdb_value ---

/*!
Creates a value from a string

* value: The text
* length: The length of the text
* returns: The value. This must be destroyed with `duckdb_destroy_value`.
*/
create_varchar_length :: proc (text:cstring, length:idx_t) -> duckdb_value ---

/*!
Creates a value from an int64

* value: The bigint value
* returns: The value. This must be destroyed with `duckdb_destroy_value`.
*/
create_int64 :: proc (val:c.int64_t) -> duckdb_value ---

/*!
Creates a struct value from a type and an array of values

* type: The type of the struct
* values: The values for the struct fields
* returns: The value. This must be destroyed with `duckdb_destroy_value`.
*/
create_struct_value :: proc (type:duckdb_logical_type, values:^duckdb_value) -> duckdb_value ---

/*!
Creates a list value from a type and an array of values of length `value_count`

* type: The type of the list
* values: The values for the list
* value_count: The number of values in the list
* returns: The value. This must be destroyed with `duckdb_destroy_value`.
*/
create_list_value :: proc (type:duckdb_logical_type, values:^duckdb_value, value_count:idx_t) -> duckdb_value ---

/*!
Creates a array value from a type and an array of values of length `value_count`

* type: The type of the array
* values: The values for the array
* value_count: The number of values in the array
* returns: The value. This must be destroyed with `duckdb_destroy_value`.
*/
create_array_value :: proc (type:duckdb_logical_type, values:^duckdb_value, value_count:idx_t) -> duckdb_value ---

/*!
Obtains a string representation of the given value.
The result must be destroyed with `duckdb_free`.

* value: The value
* returns: The string value. This must be destroyed with `duckdb_free`.
*/
get_varchar :: proc (value:duckdb_value) -> cstring ---

/*!
Obtains an int64 of the given value.

* value: The value
* returns: The int64 value, or 0 if no conversion is possible
*/
get_int64 :: proc (value:duckdb_value) -> c.int64_t ---

//===--------------------------------------------------------------------===//
// Logical Type Interface
//===--------------------------------------------------------------------===//

/*!
Creates a `duckdb_logical_type` from a standard primitive type.
The resulting type should be destroyed with `duckdb_destroy_logical_type`.

This should not be used with `DUCKDB_TYPE_DECIMAL`.

* type: The primitive type to create.
* returns: The logical type.
*/
create_logical_type :: proc (type:duckdb_type) -> duckdb_logical_type ---

/*!
Returns the alias of a duckdb_logical_type, if one is set, else `NULL`.
The result must be destroyed with `duckdb_free`.

* type: The logical type to return the alias of
* returns: The alias or `NULL`
 */
logical_type_get_alias :: proc (type:duckdb_logical_type) -> ^c.char ---

/*!
Creates a list type from its child type.
The resulting type should be destroyed with `duckdb_destroy_logical_type`.

* type: The child type of list type to create.
* returns: The logical type.
*/
create_list_type :: proc (type:duckdb_logical_type) -> duckdb_logical_type ---

/*!
Creates a array type from its child type.
The resulting type should be destroyed with `duckdb_destroy_logical_type`.

* type: The child type of array type to create.
* array_size: The number of elements in the array.
* returns: The logical type.
*/
create_array_type :: proc (type:duckdb_logical_type, array_size:idx_t) -> duckdb_logical_type ---

/*!
Creates a map type from its key type and value type.
The resulting type should be destroyed with `duckdb_destroy_logical_type`.

* type: The key type and value type of map type to create.
* returns: The logical type.
*/
create_map_type :: proc (key_type:duckdb_logical_type, value_type:duckdb_logical_type) -> duckdb_logical_type ---

/*!
Creates a UNION type from the passed types array.
The resulting type should be destroyed with `duckdb_destroy_logical_type`.

* types: The array of types that the union should consist of.
* type_amount: The size of the types array.
* returns: The logical type.
*/
create_union_type :: proc (member_types:^duckdb_logical_type,member_names:^cstring,member_count:idx_t) -> duckdb_logical_type ---

/*!
Creates a STRUCT type from the passed member name and type arrays.
The resulting type should be destroyed with `duckdb_destroy_logical_type`.

* member_types: The array of types that the struct should consist of.
* member_names: The array of names that the struct should consist of.
* member_count: The number of members that were specified for both arrays.
* returns: The logical type.
*/
create_struct_type :: proc (member_types:^duckdb_logical_type,member_names:^cstring,member_count:idx_t) -> duckdb_logical_type ---

/*!
Creates an ENUM type from the passed member name array.
The resulting type should be destroyed with `duckdb_destroy_logical_type`.

* enum_name: The name of the enum.
* member_names: The array of names that the enum should consist of.
* member_count: The number of elements that were specified in the array.
* returns: The logical type.
*/
create_enum_type :: proc (enum_name:cstring,member_names:^cstring,member_count:idx_t) -> duckdb_logical_type ---

/*!
Creates a `duckdb_logical_type` of type decimal with the specified width and scale.
The resulting type should be destroyed with `duckdb_destroy_logical_type`.

* width: The width of the decimal type
* scale: The scale of the decimal type
* returns: The logical type.
*/
create_decimal_type :: proc (width:c.uint8_t, scale:c.uint8_t) -> duckdb_logical_type ---

/*!
Retrieves the enum type class of a `duckdb_logical_type`.

* type: The logical type object
* returns: The type id
*/
get_type_id :: proc (type:duckdb_logical_type) -> duckdb_type ---

/*!
Retrieves the width of a decimal type.

* type: The logical type object
* returns: The width of the decimal type
*/
decimal_width :: proc (type:duckdb_logical_type) -> c.uint8_t ---

/*!
Retrieves the scale of a decimal type.

* type: The logical type object
* returns: The scale of the decimal type
*/
decimal_scale :: proc (type:duckdb_logical_type) -> c.uint8_t ---

/*!
Retrieves the internal storage type of a decimal type.

* type: The logical type object
* returns: The internal type of the decimal type
*/
decimal_internal_type :: proc (type:duckdb_logical_type) -> duckdb_type ---

/*!
Retrieves the internal storage type of an enum type.

* type: The logical type object
* returns: The internal type of the enum type
*/
enum_internal_type :: proc (type:duckdb_logical_type) -> duckdb_type ---

/*!
Retrieves the dictionary size of the enum type.

* type: The logical type object
* returns: The dictionary size of the enum type
*/
enum_dictionary_size :: proc (type:duckdb_logical_type) -> c.uint32_t ---

/*!
Retrieves the dictionary value at the specified position from the enum.

The result must be freed with `duckdb_free`.

* type: The logical type object
* index: The index in the dictionary
* returns: The string value of the enum type. Must be freed with `duckdb_free`.
*/
enum_dictionary_value :: proc (type:duckdb_logical_type, index:idx_t) -> cstring ---

/*!
Retrieves the child type of the given list type.

The result must be freed with `duckdb_destroy_logical_type`.

* type: The logical type object
* returns: The child type of the list type. Must be destroyed with `duckdb_destroy_logical_type`.
*/
list_type_child_type :: proc (type:duckdb_logical_type) -> duckdb_logical_type ---

/*!
Retrieves the child type of the given array type.

The result must be freed with `duckdb_destroy_logical_type`.

* type: The logical type object
* returns: The child type of the array type. Must be destroyed with `duckdb_destroy_logical_type`.
*/
array_type_child_type :: proc (type:duckdb_logical_type) -> duckdb_logical_type ---

/*!
Retrieves the array size of the given array type.

* type: The logical type object
* returns: The fixed number of elements the values of this array type can store.
*/
array_type_array_size :: proc (type:duckdb_logical_type) -> idx_t ---

/*!
Retrieves the key type of the given map type.

The result must be freed with `duckdb_destroy_logical_type`.

* type: The logical type object
* returns: The key type of the map type. Must be destroyed with `duckdb_destroy_logical_type`.
*/
map_type_key_type :: proc (type:duckdb_logical_type) -> duckdb_logical_type ---

/*!
Retrieves the value type of the given map type.

The result must be freed with `duckdb_destroy_logical_type`.

* type: The logical type object
* returns: The value type of the map type. Must be destroyed with `duckdb_destroy_logical_type`.
*/
map_type_value_type :: proc (type:duckdb_logical_type) -> duckdb_logical_type ---

/*!
Returns the number of children of a struct type.

* type: The logical type object
* returns: The number of children of a struct type.
*/
struct_type_child_count :: proc (type:duckdb_logical_type) -> idx_t ---

/*!
Retrieves the name of the struct child.

The result must be freed with `duckdb_free`.

* type: The logical type object
* index: The child index
* returns: The name of the struct type. Must be freed with `duckdb_free`.
*/
struct_type_child_name :: proc (type:duckdb_logical_type, index:idx_t) -> cstring ---

/*!
Retrieves the child type of the given struct type at the specified index.

The result must be freed with `duckdb_destroy_logical_type`.

* type: The logical type object
* index: The child index
* returns: The child type of the struct type. Must be destroyed with `duckdb_destroy_logical_type`.
*/
struct_type_child_type :: proc (type:duckdb_logical_type, index:idx_t) -> duckdb_logical_type ---

/*!
Returns the number of members that the union type has.

* type: The logical type (union) object
* returns: The number of members of a union type.
*/
union_type_member_count :: proc (type:duckdb_logical_type) -> idx_t ---

/*!
Retrieves the name of the union member.

The result must be freed with `duckdb_free`.

* type: The logical type object
* index: The child index
* returns: The name of the union member. Must be freed with `duckdb_free`.
*/
union_type_member_name :: proc (type:duckdb_logical_type, index:idx_t) -> cstring ---

/*!
Retrieves the child type of the given union member at the specified index.

The result must be freed with `duckdb_destroy_logical_type`.

* type: The logical type object
* index: The child index
* returns: The child type of the union member. Must be destroyed with `duckdb_destroy_logical_type`.
*/
union_type_member_type :: proc (type:duckdb_logical_type, index:idx_t) -> duckdb_logical_type ---

/*!
Destroys the logical type and de-allocates all memory allocated for that type.

* type: The logical type to destroy.
*/
destroy_logical_type :: proc (type:^duckdb_logical_type) ---

//===--------------------------------------------------------------------===//
// Data Chunk Interface
//===--------------------------------------------------------------------===//

/*!
Creates an empty DataChunk with the specified set of types.

Note that the result must be destroyed with `duckdb_destroy_data_chunk`.

* types: An array of types of the data chunk.
* column_count: The number of columns.
* returns: The data chunk.
*/
create_data_chunk :: proc (types:^duckdb_logical_type, column_count:idx_t) -> duckdb_data_chunk ---

/*!
Destroys the data chunk and de-allocates all memory allocated for that chunk.

* chunk: The data chunk to destroy.
*/
destroy_data_chunk :: proc (chunk:^duckdb_data_chunk) ---

/*!
Resets a data chunk, clearing the validity masks and setting the cardinality of the data chunk to 0.

* chunk: The data chunk to reset.
*/
data_chunk_reset :: proc (chunk:duckdb_data_chunk) ---

/*!
Retrieves the number of columns in a data chunk.

* chunk: The data chunk to get the data from
* returns: The number of columns in the data chunk
*/
data_chunk_get_column_count :: proc (chunk:duckdb_data_chunk) -> idx_t ---

/*!
Retrieves the vector at the specified column index in the data chunk.

The pointer to the vector is valid for as long as the chunk is alive.
It does NOT need to be destroyed.

* chunk: The data chunk to get the data from
* returns: The vector
*/
data_chunk_get_vector :: proc (chunk:duckdb_data_chunk, column_idx:idx_t) -> duckdb_vector ---

/*!
Retrieves the current number of tuples in a data chunk.

* chunk: The data chunk to get the data from
* returns: The number of tuples in the data chunk
*/
data_chunk_get_size :: proc (chunk:duckdb_data_chunk) -> idx_t ---

/*!
Sets the current number of tuples in a data chunk.

* chunk: The data chunk to set the size in
* size: The number of tuples in the data chunk
*/
data_chunk_set_size :: proc (chunk:duckdb_data_chunk, size:idx_t) ---

//===--------------------------------------------------------------------===//
// Vector Interface
//===--------------------------------------------------------------------===//

/*!
Retrieves the column type of the specified vector.

The result must be destroyed with `duckdb_destroy_logical_type`.

* vector: The vector get the data from
* returns: The type of the vector
*/
vector_get_column_type :: proc (vector:duckdb_vector) -> duckdb_logical_type ---

/*!
Retrieves the data pointer of the vector.

The data pointer can be used to read or write values from the vector.
How to read or write values depends on the type of the vector.

* vector: The vector to get the data from
* returns: The data pointer
*/
vector_get_data :: proc (vector:duckdb_vector) -> rawptr ---

/*!
Retrieves the validity mask pointer of the specified vector.

If all values are valid, this function MIGHT return NULL!

The validity mask is a bitset that signifies null-ness within the data chunk.
It is a series of uint64_t values, where each uint64_t value contains validity for 64 tuples.
The bit is set to 1 if the value is valid (i.e. not NULL) or 0 if the value is invalid (i.e. NULL).

Validity of a specific value can be obtained like this:

idx_t entry_idx = row_idx / 64;
idx_t idx_in_entry = row_idx % 64;
bool is_valid = validity_mask[entry_idx] & (1 << idx_in_entry);

Alternatively, the (slower) duckdb_validity_row_is_valid function can be used.

* vector: The vector to get the data from
* returns: The pointer to the validity mask, or NULL if no validity mask is present
*/
vector_get_validity :: proc (vector:duckdb_vector) -> ^c.uint64_t ---

/*!
Ensures the validity mask is writable by allocating it.

After this function is called, `duckdb_vector_get_validity` will ALWAYS return non-NULL.
This allows null values to be written to the vector, regardless of whether a validity mask was present before.

* vector: The vector to alter
*/
vector_ensure_validity_writable :: proc (vector:duckdb_vector) ---

/*!
Assigns a string element in the vector at the specified location.

* vector: The vector to alter
* index: The row position in the vector to assign the string to
* str: The null-terminated string
*/
vector_assign_string_element :: proc (vector:duckdb_vector, index:idx_t, str:cstring) ---

/*!
Assigns a string element in the vector at the specified location. You may also use this function to assign BLOBs.

* vector: The vector to alter
* index: The row position in the vector to assign the string to
* str: The string
* str_len: The length of the string (in bytes)
*/
vector_assign_string_element_len :: proc (vector:duckdb_vector, index:idx_t, str:cstring, str_len:idx_t) ---

/*!
Retrieves the child vector of a list vector.

The resulting vector is valid as long as the parent vector is valid.

* vector: The vector
* returns: The child vector
*/
list_vector_get_child :: proc (vector:duckdb_vector) -> duckdb_vector ---

/*!
Returns the size of the child vector of the list.

* vector: The vector
* returns: The size of the child list
*/
list_vector_get_size :: proc (vector:duckdb_vector) -> idx_t ---

/*!
Sets the total size of the underlying child-vector of a list vector.

* vector: The list vector.
* size: The size of the child list.
* returns: The duckdb state. Returns DuckDBError if the vector is nullptr.
*/
list_vector_set_size :: proc (vector:duckdb_vector, size:idx_t) -> duckdb_state ---

/*!
Sets the total capacity of the underlying child-vector of a list.

* vector: The list vector.
* required_capacity: the total capacity to reserve.
* return: The duckdb state. Returns DuckDBError if the vector is nullptr.
*/
list_vector_reserve :: proc (vector:duckdb_vector, required_capacity:idx_t) -> duckdb_state ---

/*!
Retrieves the child vector of a struct vector.

The resulting vector is valid as long as the parent vector is valid.

* vector: The vector
* index: The child index
* returns: The child vector
*/
struct_vector_get_child :: proc (vector:duckdb_vector, index:idx_t) -> duckdb_vector ---

/*!
Retrieves the child vector of a array vector.

The resulting vector is valid as long as the parent vector is valid.
The resulting vector has the size of the parent vector multiplied by the array size.

* vector: The vector
* returns: The child vector
*/
array_vector_get_child :: proc (vector:duckdb_vector) -> duckdb_vector ---

//===--------------------------------------------------------------------===//
// Validity Mask Functions
//===--------------------------------------------------------------------===//

/*!
Returns whether or not a row is valid (i.e. not NULL) in the given validity mask.

* validity: The validity mask, as obtained through `duckdb_vector_get_validity`
* row: The row index
* returns: true if the row is valid, false otherwise
*/
validity_row_is_valid :: proc (validity:^c.uint64_t, row:idx_t) -> bool ---

/*!
In a validity mask, sets a specific row to either valid or invalid.

Note that `duckdb_vector_ensure_validity_writable` should be called before calling `duckdb_vector_get_validity`,
to ensure that there is a validity mask to write to.

* validity: The validity mask, as obtained through `duckdb_vector_get_validity`.
* row: The row index
* valid: Whether or not to set the row to valid, or invalid
*/
validity_set_row_validity :: proc (validity:^c.uint64_t, row:idx_t, valid:bool) ---

/*!
In a validity mask, sets a specific row to invalid.

Equivalent to `duckdb_validity_set_row_validity` with valid set to false.

* validity: The validity mask
* row: The row index
*/
validity_set_row_invalid :: proc (validity:^c.uint64_t, row:idx_t) ---

/*!
In a validity mask, sets a specific row to valid.

Equivalent to `duckdb_validity_set_row_validity` with valid set to true.

* validity: The validity mask
* row: The row index
*/
validity_set_row_valid :: proc (validity:^c.uint64_t, row:idx_t) ---

//===--------------------------------------------------------------------===//
// Table Functions
//===--------------------------------------------------------------------===//

/*!
Creates a new empty table function.

The return value should be destroyed with `duckdb_destroy_table_function`.

* returns: The table function object.
*/
create_table_function :: proc () -> duckdb_table_function ---

/*!
Destroys the given table function object.

* table_function: The table function to destroy
*/
destroy_table_function :: proc (table_function:^duckdb_table_function) ---

/*!
Sets the name of the given table function.

* table_function: The table function
* name: The name of the table function
*/
table_function_set_name :: proc (table_function:duckdb_table_function, name:cstring) ---

/*!
Adds a parameter to the table function.

* table_function: The table function
* type: The type of the parameter to add.
*/
table_function_add_parameter :: proc (table_function:duckdb_table_function, type:duckdb_logical_type) ---

/*!
Adds a named parameter to the table function.

* table_function: The table function
* name: The name of the parameter
* type: The type of the parameter to add.
*/
table_function_add_named_parameter :: proc (table_function:duckdb_table_function, name:cstring, type:duckdb_logical_type) ---

/*!
Assigns extra information to the table function that can be fetched during binding, etc.

* table_function: The table function
* extra_info: The extra information
* destroy: The callback that will be called to destroy the bind data (if any)
*/
table_function_set_extra_info :: proc (table_function:duckdb_table_function, extra_info:rawptr, destroy:duckdb_delete_callback_t) ---

/*!
Sets the bind function of the table function.

* table_function: The table function
* bind: The bind function
*/
table_function_set_bind :: proc (table_function:duckdb_table_function, bind:duckdb_table_function_bind_t) ---

/*!
Sets the init function of the table function.

* table_function: The table function
* init: The init function
*/
table_function_set_init :: proc (table_function:duckdb_table_function, init:duckdb_table_function_init_t) ---

/*!
Sets the thread-local init function of the table function.

* table_function: The table function
* init: The init function
*/
table_function_set_local_init :: proc (table_function:duckdb_table_function, init:duckdb_table_function_init_t) ---

/*!
Sets the main function of the table function.

* table_function: The table function
* function: The function
*/
table_function_set_function :: proc (table_function:duckdb_table_function, function:duckdb_table_function_t) ---

/*!
Sets whether or not the given table function supports projection pushdown.

If this is set to true, the system will provide a list of all required columns in the `init` stage through
the `duckdb_init_get_column_count` and `duckdb_init_get_column_index` functions.
If this is set to false (the default), the system will expect all columns to be projected.

* table_function: The table function
* pushdown: True if the table function supports projection pushdown, false otherwise.
*/
table_function_supports_projection_pushdown :: proc (table_function:duckdb_table_function, pushdown:bool) ---

/*!
Register the table function object within the given connection.

The function requires at least a name, a bind function, an init function and a main function.

If the function is incomplete or a function with this name already exists DuckDBError is returned.

* con: The connection to register it in.
* function: The function pointer
* returns: Whether or not the registration was successful.
*/
register_table_function :: proc (con:duckdb_connection, function:duckdb_table_function) -> duckdb_state ---

//===--------------------------------------------------------------------===//
// Table Function Bind
//===--------------------------------------------------------------------===//

/*!
Retrieves the extra info of the function as set in `duckdb_table_function_set_extra_info`.

* info: The info object
* returns: The extra info
*/
bind_get_extra_info :: proc (info:duckdb_bind_info) -> rawptr ---

/*!
Adds a result column to the output of the table function.

* info: The info object
* name: The name of the column
* type: The logical type of the column
*/
bind_add_result_column :: proc (info:duckdb_bind_info, name:cstring, type:duckdb_logical_type) ---

/*!
Retrieves the number of regular (non-named) parameters to the function.

* info: The info object
* returns: The number of parameters
*/
bind_get_parameter_count :: proc (info:duckdb_bind_info) -> idx_t ---

/*!
Retrieves the parameter at the given index.

The result must be destroyed with `duckdb_destroy_value`.

* info: The info object
* index: The index of the parameter to get
* returns: The value of the parameter. Must be destroyed with `duckdb_destroy_value`.
*/
bind_get_parameter :: proc (info:duckdb_bind_info, index:idx_t) -> duckdb_value ---

/*!
Retrieves a named parameter with the given name.

The result must be destroyed with `duckdb_destroy_value`.

* info: The info object
* name: The name of the parameter
* returns: The value of the parameter. Must be destroyed with `duckdb_destroy_value`.
*/
bind_get_named_parameter :: proc (info:duckdb_bind_info, name:cstring) -> duckdb_value ---

/*!
Sets the user-provided bind data in the bind object. This object can be retrieved again during execution.

* info: The info object
* extra_data: The bind data object.
* destroy: The callback that will be called to destroy the bind data (if any)
*/
bind_set_bind_data :: proc (info:duckdb_bind_info, extra_data:rawptr, destroy:duckdb_delete_callback_t) ---

/*!
Sets the cardinality estimate for the table function, used for optimization.

* info: The bind data object.
* is_exact: Whether or not the cardinality estimate is exact, or an approximation
*/
bind_set_cardinality :: proc (info:duckdb_bind_info, cardinality:idx_t, is_exact:bool) ---

/*!
Report that an error has occurred while calling bind.

* info: The info object
* error: The error message
*/
bind_set_error :: proc (info:duckdb_bind_info, error:cstring) ---

//===--------------------------------------------------------------------===//
// Table Function Init
//===--------------------------------------------------------------------===//

/*!
Retrieves the extra info of the function as set in `duckdb_table_function_set_extra_info`.

* info: The info object
* returns: The extra info
*/
init_get_extra_info :: proc (info:duckdb_init_info) -> rawptr ---

/*!
Gets the bind data set by `duckdb_bind_set_bind_data` during the bind.

Note that the bind data should be considered as read-only.
For tracking state, use the init data instead.

* info: The info object
* returns: The bind data object
*/
init_get_bind_data :: proc (info:duckdb_init_info) -> rawptr ---

/*!
Sets the user-provided init data in the init object. This object can be retrieved again during execution.

* info: The info object
* extra_data: The init data object.
* destroy: The callback that will be called to destroy the init data (if any)
*/
init_set_init_data :: proc (info:duckdb_init_info, extra_data:rawptr, destroy:duckdb_delete_callback_t) ---

/*!
Returns the number of projected columns.

This function must be used if projection pushdown is enabled to figure out which columns to emit.

* info: The info object
* returns: The number of projected columns.
*/
init_get_column_count :: proc (info:duckdb_init_info) -> idx_t ---

/*!
Returns the column index of the projected column at the specified position.

This function must be used if projection pushdown is enabled to figure out which columns to emit.

* info: The info object
* column_index: The index at which to get the projected column index, from 0..duckdb_init_get_column_count(info)
* returns: The column index of the projected column.
*/
init_get_column_index :: proc (info:duckdb_init_info, column_index:idx_t) -> idx_t ---

/*!
Sets how many threads can process this table function in parallel (default: 1)

* info: The info object
* max_threads: The maximum amount of threads that can process this table function
*/
init_set_max_threads :: proc (info:duckdb_init_info, max_threads:idx_t) ---

/*!
Report that an error has occurred while calling init.

* info: The info object
* error: The error message
*/
init_set_error :: proc (info:duckdb_init_info, error:cstring) ---

//===--------------------------------------------------------------------===//
// Table Function
//===--------------------------------------------------------------------===//

/*!
Retrieves the extra info of the function as set in `duckdb_table_function_set_extra_info`.

* info: The info object
* returns: The extra info
*/
function_get_extra_info :: proc (info:duckdb_function_info) -> rawptr ---

/*!
Gets the bind data set by `duckdb_bind_set_bind_data` during the bind.

Note that the bind data should be considered as read-only.
For tracking state, use the init data instead.

* info: The info object
* returns: The bind data object
*/
function_get_bind_data :: proc (info:duckdb_function_info) -> rawptr ---

/*!
Gets the init data set by `duckdb_init_set_init_data` during the init.

* info: The info object
* returns: The init data object
*/
function_get_init_data :: proc (info:duckdb_function_info) -> rawptr ---

/*!
Gets the thread-local init data set by `duckdb_init_set_init_data` during the local_init.

* info: The info object
* returns: The init data object
*/
function_get_local_init_data :: proc (info:duckdb_function_info) -> rawptr ---

/*!
Report that an error has occurred while executing the function.

* info: The info object
* error: The error message
*/
function_set_error :: proc (info:duckdb_function_info, error:cstring) ---

//===--------------------------------------------------------------------===//
// Replacement Scans
//===--------------------------------------------------------------------===//

/*!
Add a replacement scan definition to the specified database.

* db: The database object to add the replacement scan to
* replacement: The replacement scan callback
* extra_data: Extra data that is passed back into the specified callback
* delete_callback: The delete callback to call on the extra data, if any
*/
add_replacement_scan :: proc (db:duckdb_database, replacement:duckdb_replacement_callback_t, extra_data:rawptr, delete_callback:duckdb_delete_callback_t) ---

/*!
Sets the replacement function name. If this function is called in the replacement callback,
the replacement scan is performed. If it is not called, the replacement callback is not performed.

* info: The info object
* function_name: The function name to substitute.
*/
replacement_scan_set_function_name :: proc (info:duckdb_replacement_scan_info, function_name:cstring) ---

/*!
Adds a parameter to the replacement scan function.

* info: The info object
* parameter: The parameter to add.
*/
replacement_scan_add_parameter :: proc (info:duckdb_replacement_scan_info, parameter:duckdb_value) ---

/*!
Report that an error has occurred while executing the replacement scan.

* info: The info object
* error: The error message
*/
replacement_scan_set_error :: proc (info:duckdb_replacement_scan_info, error:cstring) ---

//===--------------------------------------------------------------------===//
// Appender
//===--------------------------------------------------------------------===//

// Appenders are the most efficient way of loading data into DuckDB from within the C interface, and are recommended for
// fast data loading. The appender is much faster than using prepared statements or individual `INSERT INTO` statements.

// Appends are made in row-wise format. For every column, a `duckdb_append_[type]` call should be made, after which
// the row should be finished by calling `duckdb_appender_end_row`. After all rows have been appended,
// `duckdb_appender_destroy` should be used to finalize the appender and clean up the resulting memory.

// Instead of appending rows with `duckdb_appender_end_row`, it is also possible to fill and append
// chunks-at-a-time.

// Note that `duckdb_appender_destroy` should always be called on the resulting appender, even if the function returns
// `DuckDBError`.

/*!
Creates an appender object.

Note that the object must be destroyed with `duckdb_appender_destroy`.

* connection: The connection context to create the appender in.
* schema: The schema of the table to append to, or `nullptr` for the default schema.
* table: The table name to append to.
* out_appender: The resulting appender object.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
create_appender :: proc (connection:duckdb_connection, schema:cstring, table:cstring, out_appender:^duckdb_appender) -> duckdb_state ---

/*!
Returns the number of columns in the table that belongs to the appender.

* appender The appender to get the column count from.
* returns: The number of columns in the table.
*/
appender_column_count :: proc (appender:duckdb_appender) -> idx_t ---

/*!
Returns the type of the column at the specified index.

Note: The resulting type should be destroyed with `duckdb_destroy_logical_type`.

* appender The appender to get the column type from.
* col_idx The index of the column to get the type of.
* returns: The duckdb_logical_type of the column.
*/
appender_column_type :: proc (appender:duckdb_appender, col_idx:idx_t) -> duckdb_logical_type ---

/*!
Returns the error message associated with the given appender.
If the appender has no error message, this returns `nullptr` instead.

The error message should not be freed. It will be de-allocated when `duckdb_appender_destroy` is called.

* appender: The appender to get the error from.
* returns: The error message, or `nullptr` if there is none.
*/
appender_error :: proc (appender:duckdb_appender) -> cstring ---

/*!
Flush the appender to the table, forcing the cache of the appender to be cleared and the data to be appended to the
base table.

This should generally not be used unless you know what you are doing. Instead, call `duckdb_appender_destroy` when you
are done with the appender.

* appender: The appender to flush.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
appender_flush :: proc (appender:duckdb_appender) -> duckdb_state ---

/*!
Close the appender, flushing all intermediate state in the appender to the table and closing it for further appends.

This is generally not necessary. Call `duckdb_appender_destroy` instead.

* appender: The appender to flush and close.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
appender_close :: proc (appender:duckdb_appender) -> duckdb_state ---

/*!
Close the appender and destroy it. Flushing all intermediate state in the appender to the table, and de-allocating
all memory associated with the appender.

* appender: The appender to flush, close and destroy.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
appender_destroy :: proc (appender:^duckdb_appender) -> duckdb_state ---

/*!
A nop function, provided for backwards compatibility reasons. Does nothing. Only `duckdb_appender_end_row` is required.
*/
appender_begin_row :: proc (appender:duckdb_appender) -> duckdb_state ---

/*!
Finish the current row of appends. After end_row is called, the next row can be appended.

* appender: The appender.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
appender_end_row :: proc (appender:duckdb_appender) -> duckdb_state ---

/*!
Append a bool value to the appender.
*/
appender_append_bool :: proc (appender:duckdb_appender, value:bool) -> duckdb_state ---

/*!
Append an int8_t value to the appender.
*/
appender_append_int8 :: proc (appender:duckdb_appender, value:c.int8_t) -> duckdb_state ---

/*!
Append an int16_t value to the appender.
*/
appender_append_int16 :: proc (appender:duckdb_appender, value:c.int16_t) -> duckdb_state ---

/*!
Append an int32_t value to the appender.
*/
appender_append_int32 :: proc (appender:duckdb_appender, value:c.int32_t) -> duckdb_state ---

/*!
Append an int64_t value to the appender.
*/
appender_append_int64 :: proc (appender:duckdb_appender, value:c.int64_t) -> duckdb_state ---

/*!
Append a duckdb_hugeint value to the appender.
*/
appender_append_hugeint :: proc (appender:duckdb_appender, value:duckdb_hugeint) -> duckdb_state ---

/*!
Append a uint8_t value to the appender.
*/
appender_append_uint8 :: proc (appender:duckdb_appender, value:c.uint8_t) -> duckdb_state ---

/*!
Append a uint16_t value to the appender.
*/
appender_append_uint16 :: proc (appender:duckdb_appender, value:c.uint16_t) -> duckdb_state ---

/*!
Append a uint32_t value to the appender.
*/
appender_append_uint32 :: proc (appender:duckdb_appender, value:c.uint32_t) -> duckdb_state ---

/*!
Append a uint64_t value to the appender.
*/
appender_append_uint64 :: proc (appender:duckdb_appender, value:c.uint64_t) -> duckdb_state ---

/*!
Append a duckdb_uhugeint value to the appender.
*/
appender_append_uhugeint :: proc (appender:duckdb_appender, value:duckdb_uhugeint) -> duckdb_state ---

/*!
Append a float value to the appender.
*/
appender_append_float :: proc (appender:duckdb_appender, value:c.float) -> duckdb_state ---

/*!
Append a double value to the appender.
*/
appender_append_double :: proc (appender:duckdb_appender, value:c.double) -> duckdb_state ---

/*!
Append a duckdb_date value to the appender.
*/
appender_append_date :: proc (appender:duckdb_appender, value:duckdb_date) -> duckdb_state ---

/*!
Append a duckdb_time value to the appender.
*/
appender_append_time :: proc (appender:duckdb_appender, value:duckdb_time) -> duckdb_state ---

/*!
Append a duckdb_timestamp value to the appender.
*/
appender_append_timestamp :: proc (appender:duckdb_appender, value:duckdb_timestamp) -> duckdb_state ---

/*!
Append a duckdb_interval value to the appender.
*/
appender_append_interval :: proc (appender:duckdb_appender, value:duckdb_interval) -> duckdb_state ---

/*!
Append a varchar value to the appender.
*/
appender_append_varchar :: proc (appender:duckdb_appender, value:cstring) -> duckdb_state ---

/*!
Append a varchar value to the appender.
*/
appender_append_varchar_length :: proc (appender:duckdb_appender, value:cstring, length:idx_t) -> duckdb_state ---

/*!
Append a blob value to the appender.
*/
appender_append_blob :: proc (appender:duckdb_appender, data:rawptr, length:idx_t) -> duckdb_state ---

/*!
Append a NULL value to the appender (of any type).
*/
appender_append_null :: proc (appender:duckdb_appender) -> duckdb_state ---

/*!
Appends a pre-filled data chunk to the specified appender.

The types of the data chunk must exactly match the types of the table, no casting is performed.
If the types do not match or the appender is in an invalid state, DuckDBError is returned.
If the append is successful, DuckDBSuccess is returned.

* appender: The appender to append to.
* chunk: The data chunk to append.
* returns: The return state.
*/
appender_append_data_chunk :: proc (appender:duckdb_appender, chunk:duckdb_data_chunk) -> duckdb_state ---

//===--------------------------------------------------------------------===//
// Arrow Interface
//===--------------------------------------------------------------------===//

/*!
Executes a SQL query within a connection and stores the full (materialized) result in an arrow structure.
If the query fails to execute, DuckDBError is returned and the error message can be retrieved by calling
`duckdb_query_arrow_error`.

Note that after running `duckdb_query_arrow`, `duckdb_destroy_arrow` must be called on the result object even if the
query fails, otherwise the error stored within the result will not be freed correctly.

* connection: The connection to perform the query in.
* query: The SQL query to run.
* out_result: The query result.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
query_arrow :: proc (connection:duckdb_connection, query:cstring, out_result:^duckdb_arrow) -> duckdb_state ---

/*!
Fetch the internal arrow schema from the arrow result. Remember to call release on the respective
ArrowSchema object.

* result: The result to fetch the schema from.
* out_schema: The output schema.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
query_arrow_schema :: proc (result:duckdb_arrow, out_schema:^duckdb_arrow_schema) -> duckdb_state ---

/*!
Fetch the internal arrow schema from the prepared statement. Remember to call release on the respective
ArrowSchema object.

* result: The prepared statement to fetch the schema from.
* out_schema: The output schema.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
prepared_arrow_schema :: proc (prepared:duckdb_prepared_statement, out_schema:^duckdb_arrow_schema) -> duckdb_state ---

/*!
Convert a data chunk into an arrow struct array. Remember to call release on the respective
ArrowArray object.

* result: The result object the data chunk have been fetched from.
* chunk: The data chunk to convert.
* out_array: The output array.
*/
result_arrow_array :: proc (result:duckdb_result, chunk:duckdb_data_chunk, out_array:^duckdb_arrow_array) ---

/*!
Fetch an internal arrow struct array from the arrow result. Remember to call release on the respective
ArrowArray object.

This function can be called multiple time to get next chunks, which will free the previous out_array.
So consume the out_array before calling this function again.

* result: The result to fetch the array from.
* out_array: The output array.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
query_arrow_array :: proc (result:duckdb_arrow, out_array:^duckdb_arrow_array) -> duckdb_state ---

/*!
Returns the number of columns present in the arrow result object.

* result: The result object.
* returns: The number of columns present in the result object.
*/
arrow_column_count :: proc (result:duckdb_arrow) -> idx_t ---

/*!
Returns the number of rows present in the arrow result object.

* result: The result object.
* returns: The number of rows present in the result object.
*/
arrow_row_count :: proc (result:duckdb_arrow) -> idx_t ---

/*!
Returns the number of rows changed by the query stored in the arrow result. This is relevant only for
INSERT/UPDATE/DELETE queries. For other queries the rows_changed will be 0.

* result: The result object.
* returns: The number of rows changed.
*/
arrow_rows_changed :: proc (result:duckdb_arrow) -> idx_t ---

/*!
Returns the error message contained within the result. The error is only set if `duckdb_query_arrow` returns
`DuckDBError`.

The error message should not be freed. It will be de-allocated when `duckdb_destroy_arrow` is called.

* result: The result object to fetch the error from.
* returns: The error of the result.
*/
arrow_error :: proc (result:duckdb_arrow) -> cstring ---

/*!
Closes the result and de-allocates all memory allocated for the arrow result.

* result: The result to destroy.
*/
destroy_arrow :: proc (result:^duckdb_arrow) ---

/*!
Releases the arrow array stream and de-allocates its memory.

* stream: The arrow array stream to destroy.
*/
destroy_arrow_stream :: proc (stream:^duckdb_arrow_stream) ---

/*!
Executes the prepared statement with the given bound parameters, and returns an arrow query result.
Note that after running `duckdb_execute_prepared_arrow`, `duckdb_destroy_arrow` must be called on the result object.

* prepared_statement: The prepared statement to execute.
* out_result: The query result.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
execute_prepared_arrow :: proc (prepared_statement:duckdb_prepared_statement, out_result:^duckdb_arrow) -> duckdb_state ---

/*!
Scans the Arrow stream and creates a view with the given name.

* connection: The connection on which to execute the scan.
* table_name: Name of the temporary view to create.
* arrow: Arrow stream wrapper.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
arrow_scan :: proc (connection:duckdb_connection, table_name:cstring, arrow:duckdb_arrow_stream) -> duckdb_state ---

/*!
Scans the Arrow array and creates a view with the given name.
Note that after running `duckdb_arrow_array_scan`, `duckdb_destroy_arrow_stream` must be called on the out stream.

* connection: The connection on which to execute the scan.
* table_name: Name of the temporary view to create.
* arrow_schema: Arrow schema wrapper.
* arrow_array: Arrow array wrapper.
* out_stream: Output array stream that wraps around the passed schema, for releasing/deleting once done.
* returns: `DuckDBSuccess` on success or `DuckDBError` on failure.
*/
arrow_array_scan :: proc (connection:duckdb_connection, table_name:cstring, arrow_schema:duckdb_arrow_schema, arrow_array:duckdb_arrow_array, out_stream:^duckdb_arrow_stream) -> duckdb_state ---

//===--------------------------------------------------------------------===//
// Threading Information
//===--------------------------------------------------------------------===//

/*!
Execute DuckDB tasks on this thread.

Will return after `max_tasks` have been executed, or if there are no more tasks present.

* database: The database object to execute tasks for
* max_tasks: The maximum amount of tasks to execute
*/
execute_tasks :: proc (database:duckdb_database, max_tasks:idx_t) ---

/*!
Creates a task state that can be used with duckdb_execute_tasks_state to execute tasks until
`duckdb_finish_execution` is called on the state.

`duckdb_destroy_state` must be called on the result.

* database: The database object to create the task state for
* returns: The task state that can be used with duckdb_execute_tasks_state.
*/
create_task_state :: proc (database:duckdb_database) -> duckdb_task_state ---

/*!
Execute DuckDB tasks on this thread.

The thread will keep on executing tasks forever, until duckdb_finish_execution is called on the state.
Multiple threads can share the same duckdb_task_state.

* state: The task state of the executor
*/
execute_tasks_state :: proc (state:duckdb_task_state) ---

/*!
Execute DuckDB tasks on this thread.

The thread will keep on executing tasks until either duckdb_finish_execution is called on the state,
max_tasks tasks have been executed or there are no more tasks to be executed.

Multiple threads can share the same duckdb_task_state.

* state: The task state of the executor
* max_tasks: The maximum amount of tasks to execute
* returns: The amount of tasks that have actually been executed
*/
execute_n_tasks_state :: proc (state:duckdb_task_state, max_tasks:idx_t) -> idx_t ---

/*!
Finish execution on a specific task.

* state: The task state to finish execution
*/
finish_execution :: proc (state:duckdb_task_state) ---

/*!
Check if the provided duckdb_task_state has finished execution

* state: The task state to inspect
* returns: Whether or not duckdb_finish_execution has been called on the task state
*/
task_state_is_finished :: proc (state:duckdb_task_state) -> bool ---

/*!
Destroys the task state returned from duckdb_create_task_state.

Note that this should not be called while there is an active duckdb_execute_tasks_state running
on the task state.

* state: The task state to clean up
*/
destroy_task_state :: proc (state:duckdb_task_state) ---

/*!
Returns true if the execution of the current query is finished.

* con: The connection on which to check
*/
execution_is_finished :: proc (con:duckdb_connection) -> bool ---

//===--------------------------------------------------------------------===//
// Streaming Result Interface
//===--------------------------------------------------------------------===//

/*!
Fetches a data chunk from the (streaming) duckdb_result. This function should be called repeatedly until the result is
exhausted.

The result must be destroyed with `duckdb_destroy_data_chunk`.

This function can only be used on duckdb_results created with 'duckdb_pending_prepared_streaming'

If this function is used, none of the other result functions can be used and vice versa (i.e. this function cannot be
mixed with the legacy result functions or the materialized result functions).

It is not known beforehand how many chunks will be returned by this result.

* result: The result object to fetch the data chunk from.
* returns: The resulting data chunk. Returns `NULL` if the result has an error.
*/
stream_fetch_chunk :: proc (result:duckdb_result) -> duckdb_data_chunk ---


}