# [Recursive Use of make](https://www.gnu.org/software/make/manual/html_node/Recursion.html)

> Recursive use of make means using make as a command in a makefile. This
> technique is useful when you want separate makefiles for various subsystems
> that compose a larger system. For example, suppose you have a sub-directory
> subdir which has its own makefile, and you would like the containing
> directory’s makefile to run make on the sub-directory. You can do it by writing
> this:

```
subsystem:
  $(MAKE) -C subdir
```
