FROM: [SO](https://stackoverflow.com/a/40453909/3970755)

Why are you using the shell make function, when you are already in a shell
(because you're in a recipe)?

Try:

```
mydir:
        a=$$(ls -la); echo "$$a"
```

Note that this is equivalent to running these commands at the shell prompt:

```
a=$(ls -la); echo "$a"
```

but we escape the $ (by typing it twice) so that make doesn't interpret it.
