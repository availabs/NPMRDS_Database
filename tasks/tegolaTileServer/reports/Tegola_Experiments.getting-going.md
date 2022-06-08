# Tegola Experiments (Building)

## 1) GLIBC Version Issue

```sh
$ ./bin/v0.15.2/tegola --help
./bin/v0.15.2/tegola: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.28' not found (required by ./bin/v0.15.2/tegola)
```

```sh
$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 18.04.1 LTS
Release:        18.04
Codename:       bionic
```

## 2) Building from source

[link](https://github.com/go-spatial/tegola#building-from-source)

### 2.1) Installing Go

- [Go: Download and install](https://go.dev/doc/install)

I installed differently than the instructions suggested.

1. Downloaded the `go1.18.3.linux-amd64.tar.gz` to /tmp/
2. Put the binary in /opt

```sh
cd /opt/
sudo mkdir -p go/v1.18.3
cd go/v1.18.3
sudo mv /tmp/go1.18.3.linux-amd64.tar.gz .
sudo tar -xf go1.18.3.linux-amd64.tar.gz
sudo ln -s /opt/go/v1.18.3/go/bin/go /usr/bin/go
```

```sh
$ go version
go version go1.18.3 linux/amd64
```

```sh
git checkout https://github.com/go-spatial/tegola.git
cd tegola
git checkout tags/v0.15.2
```

### 2.2) Building

```sh
go generate ./...
...
Changed to directory: /home/paul/AVAIL/specialTasks/tegolaTileServer/tegola/ui
Running: npm version
Running: npm install
> npm WARN read-shrinkwrap This version of npm is compatible with lockfileVersion@1, but package-lock.json was generated for lockfileVersion@2. I'll try to do my best with it!
> npm ERR! cb() never called!
>
> npm ERR! This is an error with npm itself. Please report this error at:
> npm ERR!     <https://npm.community>
>
> npm ERR! A complete log of this run can be found in:
> npm ERR!     /home/paul/.npm/_logs/2022-06-06T20_27_36_886Z-debug.log
>
PATH: /home/paul/.rvm/bin:/home/paul/.rvm/bin:/home/paul/.sdkman/candidates/maven/current/bin:/home/paul/.sdkman/candidates/java/current/bin:/home/paul/.sdkman/candidates/gradle/current/bin:/home/paul/.rvm/gems/ruby-2.7.4/bin:/home/paul/.rvm/gems/ruby-2.7.4@global/bin:/home/paul/.rvm/rubies/ruby-2.7.4/bin:/home/paul/.local/bin:/home/paul/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/paul/.rvm/bin:/home/paul/.rvm/bin:/home/paul/.rvm/bin:/home/paul/.rvm/bin:/home/paul/.rvm/bin
While running `npm install`
Got error:
exit status 1
exit status 2
server/viewer_gen.go:1: running "go": exit status 1
```

```sh
go generate ./...
...
>
> > tegola@0.1.0 build /home/paul/AVAIL/specialTasks/tegolaTileServer/tegola/ui
> > vue-cli-service build
>
>
> -  Building for production...
>  ERROR  TypeError: ErrorStackParser.parse is not a function
> TypeError: ErrorStackParser.parse is not a function
>     at getOriginalErrorStack (/home/paul/AVAIL/specialTasks/tegolaTileServer/tegola/ui/node_modules/@soda/friendly-errors-webpack-plugin/src/core/extractWebpackError.js:31:29)
...
> npm ERR! code ELIFECYCLE
> npm ERR! errno 1
> npm ERR! tegola@0.1.0 build: `vue-cli-service build`
> npm ERR! Exit status 1
> npm ERR!
> npm ERR! Failed at the tegola@0.1.0 build script.
> npm ERR! This is probably not a problem with npm. There is likely additional logging output above.
>
> npm ERR! A complete log of this run can be found in:
> npm ERR!     /home/paul/.npm/_logs/2022-06-06T20_32_25_922Z-debug.log
>
PATH: /home/paul/.rvm/bin:/home/paul/.rvm/bin:/home/paul/.sdkman/candidates/maven/current/bin:/home/paul/.sdkman/candidates/java/current/bin:/home/paul/.sdkman/candidates/gradle/current/bin:/home/paul/.rvm/gems/ruby-2.7.4/bin:/home/paul/.rvm/gems/ruby-2.7.4@global/bin:/home/paul/.rvm/rubies/ruby-2.7.4/bin:/home/paul/.local/bin:/home/paul/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/paul/.rvm/bin:/home/paul/.rvm/bin:/home/paul/.rvm/bin:/home/paul/.rvm/bin:/home/paul/.rvm/bin
While running `npm run build`
Got error:
exit status 1
exit status 2
server/viewer_gen.go:1: running "go": exit status 1
```

The README.md in the ui/ dir includes

> ## Building for inclusion in tegola
>
> In order to compile the UI for inclusion in tegola, run the following commands from the `ui` folder:
>
> ```console
> $ go run build.go
> ```

```sh
$ cd ui
$ go run build.go
Changed to directory: /home/paul/AVAIL/specialTasks/tegolaTileServer/tegola/ui
Running: npm version
Running: npm install
Running: npm run build
success
```

Success!!

Again, from the tegula project root. (last command was in ./ui/).

```sh
$ cd cmd/tegula
$ go build --tags 'noAzblobCache noS3Cache noRedisCache'
$ ./tegola version
   version: Version not set
       git: not set @ not set
build tags: !noGpkgProvider !noPostgisProvider !noPrometheusObserver !noViewer !pprof cgo noAzblobCache noRedisCache noS3Cache
 ui viewer: f1b767c2
```

## Creating a DB USER

I am reluctant to give tegula admin permissions to the database.
Therefore, created a readonly user for tegula.

```sql
npmrds_production=# create role readonly_access;
npmrds_production=# grant connect on DATABASE npmrds_production to readonly_access ;
npmrds_production=# grant select on all tables in schema conflation to readonly_access ;
npmrds_production=# create user tegola with password 'tegola';
npmrds_production=# grant readonly_access TO tegola ;
npmrds_production=# grant USAGE on SCHEMA public to readonly_access ;
npmrds_production=# grant USAGE on SCHEMA conflation to readonly_access ;
```

# Issues

```console
2022-06-06 17:34:28 [WARN] postgis.go:900: Ignoring unsupported geometry in layer (highways_v2016). Only basic 2D geometry type are supported. Try using `ST_Force2D(wkb_geometry)`.
```
