# duckdb odin bindings

## Run test

### Dynamic/Shared library

```bash
odin run ./test -extra-linker-flags:"-rpath <PATH_TO_DUCKDB_DYLIB>"
```