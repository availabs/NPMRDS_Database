-c **command**
--command=**command**

* Specifies that psql is to execute the given command string, **command**. This
  option can be repeated and combined in any order with the -f option. When
  either -c or -f is specified, psql does not read commands from standard input;
  instead it terminates after processing all the -c and -f options in sequence.

* **command** must be either a command string that is completely parsable by the
  server (i.e., it contains no psql-specific features), or a single backslash
  command. Thus you cannot mix SQL and psql meta-commands within a -c option. To
  achieve that, you could use repeated -c options or pipe the string into psql,
  for example:

```
psql -c '\x' -c 'SELECT * FROM foo;' or
```

```
echo '\x \\ SELECT * FROM foo;' | psql
```

(\\ is the separator meta-command.)

Each SQL command string passed to -c is sent to the server as a single query.
Because of this, the server executes it as a single transaction even if the
string contains multiple SQL commands, unless there are explicit BEGIN/COMMIT
commands included in the string to divide it into multiple transactions. Also,
psql only prints the result of the last SQL command in the string. This is
different from the behavior when the same string is read from a file or fed to
psql's standard input, because then psql sends each SQL command separately.

Because of this behavior, putting more than one command in a single -c string
often has unexpected results. It's better to use repeated -c commands or feed
multiple commands to psql's standard input, either using echo as illustrated
above, or via a shell here-document, for example:

```
psql <<EOF
\x
SELECT * FROM foo;
EOF
```
