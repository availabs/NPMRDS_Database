# [Why Use Make](https://bost.ocks.org/mike/make/)

> Makefiles are machine-readable documentation that make your workflow reproducible.

## It’s Files All The Way Down

> The beauty of Make is that it’s simply a rigorous way of recording what
> you’re already doing. It doesn’t fundamentally change how you do something, but
> it encourages to you record each step in the process, enabling you (and your
> coworkers) to reproduce the entire process later.

---

> Make encourages you to express your workflow backwards as dependencies
> between files, rather than forwards as a sequential recipe.

---

```
targetfile: sourcefile
  command
```

> Here targetfile is the file you want to generate, sourcefile is the file it
> depends on (is derived from), and command is something you run on the terminal
> to generate the target file. These terms generalize: a source file can itself
> be a generated file, in turn dependent on other source files; there can be
> multiple source files, or zero source files; and a command can be a sequence of
> commands or a complex script that you invoke. In Make parlance, source files
> are referred to as prerequisites, while target files are simply targets.
