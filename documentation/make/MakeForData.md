# [make For Data Using Makefiles](http://mojodna.net/2015/01/07/make-for-data-using-make.html)

> Like many other people who wrangle data for a living, I've been in on-and-off
> pursuit of a make-like approach to processing and transforming data.
> Specifically, one that allows me to idempotently bootstrap and process data
> without starting from zero each time. Also, one that makes it easy enough to
> script experiments pro-actively rather than putting replicability off.

## Common Idioms

### Use of Exit Codes

> When a process exits, it does so with a numeric code that indicates success or
> failure (in the latter case, often with a value that can be used to determine
> why). 0 is considered success; anything else is a failure of some sort. These
> codes aren't directly visible, but make uses them to determine whether a target
> was successful (and whether execution should continue).

### || and &&

> || and && are used in conjunction with exit codes to conditionally execute
> subsequent parts of a composite command.

### > /dev/null 2>&1

> POSIX processes are provided 3 file descriptions (handles to files or file-like
> things) by default. stdin (content from a file or other source like a keyboard)
> is file descriptor 0, stdout is 1, and stderr is 2.

### psql Checks

> At various points, we want to short-circuit tasks if a resource already exists.
> In a traditional Makefile, these resources would be files and that
> short-circuiting is built-in. However, since we're since working with database
> tables (etc.) and there are no file equivalents, we need to implement
> equivalent functionality.
>
> We use psql -c for practically all existence checks, as it allows us to
> construct a SQL command and use it to query PostgreSQL. Unfortunately,
> different checks result in varying output and exit codes.

#### Looking for Relations

```
availien@dionysus:~$ psql -c '\d npmrds' npmrds_analysis
                       Table "public.npmrds"
             Column             |         Type         | Modifiers
--------------------------------+----------------------+-----------
 tmc                            | character varying(9) |
 date                           | date                 |
 epoch                          | smallint             |
 travel_time_all_vehicles       | integer              |
 travel_time_passenger_vehicles | integer              |
 travel_time_freight_trucks     | integer              |
 state                          | character(2)         |
Number of child tables: 2 (Use \d+ to list them.)

availien@dionysus:~$ echo $?
0
availien@dionysus:~$ psql -c '\d npm' npmrds_analysis
Did not find any relation named "npm".
availien@dionysus:~$ echo $?
1
```

### Implicit make Variables

> make includes many implicit variables, most of which are intended for use in an
> environment where source files are being compiled and linked into binaries.
> However, there are still a few we make use of:

* `$@` - the name of the target (the thing before the :).
* `$<` - the name of the first prerequisite. Convenient.
* `$^` - all prerequisites, space-delimited.
          Can be combined with `$(word <n>,$^)` to select the nth one.

### make Functions

> Since many of the targets we're working with are synthetic, we need to extract
> relevant components of their names. Database-related functionality is grouped
> under the db/ "path", so we primarily use subst to remove irrelevant
> components. We also use word to refer to components within space-delimited
> values.

### make Patterns

> There are many resources that follow patterns when we work with data. Natural
> Earth's filenames and source URLs are a good example of this. In keeping with
> the DRY principle ("don't repeat yourself"), we fold these into a smaller
> number of targets using make patterns. These are strings that include %
> anywhere text may vary.
>
> The convenient bit is that prerequisites can also use the % syntax and the
> value of the pattern in the target name will be substituted. Thus, %: %.mml
> will convert toner to toner: toner.mml and gives us the behavior we're looking
> for.


