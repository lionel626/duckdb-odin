package test;

import duckdb ".."
import "core:fmt"
import "core:testing"

@(test)
duckdb_embedded_odin_test :: proc(t:^testing.T) {
    db : duckdb.duckdb_database
    con : duckdb.duckdb_connection
    result : duckdb.duckdb_result
    defer {
        duckdb.disconnect(&con)
        duckdb.destroy_result(&result)
        duckdb.close(&db)
    }
    if duckdb.open(nil, &db)==duckdb.duckdb_state.DuckDBError {
        fmt.printf("Failed to open database\n")
    }
    if duckdb.connect(db, &con)==duckdb.duckdb_state.DuckDBError {
        fmt.printf("Failed to connect to database\n")
    }
    if (duckdb.query(con, "CREATE TABLE integers(i INTEGER, j INTEGER);", nil) == duckdb.duckdb_state.DuckDBError) {
		fmt.printf("Failed to query database\n")
	}
    if (duckdb.query(con, "INSERT INTO integers VALUES (3, 4), (5, 6), (7, NULL);", nil) == duckdb.duckdb_state.DuckDBError) {
		fmt.printf("Failed to query database\n")
	}
    if (duckdb.query(con, "SELECT * FROM integers;", &result) == duckdb.duckdb_state.DuckDBError) {
		fmt.printf("Failed to query database\n")
	}
    // print the names of the result
    row_count := duckdb.row_count(&result)
    fmt.printf("Row count: %d\n", row_count)
    column_count := duckdb.column_count(&result)
    fmt.printf("Column count: %d\n", column_count)
    for i :u64= 0; i < column_count; i+=1 {
        fmt.printf("Column %d: %s\n", i, duckdb.column_name(&result, i))
    }
    fmt.printf("\n");
    // print the data of the result
    for row_idx:u64=0; row_idx<row_count; row_idx+=1 {
        for col_idx:u64=0; col_idx<column_count; col_idx+=1 {
            val := duckdb.value_varchar(&result, row_idx, col_idx)
            fmt.printf("%s\t", cstring(val))
            duckdb.free(val)
        }
        fmt.printf("\n")
    }

}