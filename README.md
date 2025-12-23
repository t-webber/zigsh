# ZigSh - A fast terminal to reduce the sizes of your prompts.

## Motivation

The main goal of this shell is to reduce the size of your prompts. I personally write prompt lines that are over 60 characters. To trim down the sizes of my prompts, I use aliases that containing all the arguments, for example:

```bash
ican
```

will expand to

```bash
git commit --amend --no-edit
```

and

```bash
fIH. folder
```

will expand to

```bash
fd -I -H . folder
```

I did this for virtually every command that I use often (`git`, `rg`, `fd`, `cargo`). Having this many aliases slowed downed my bashrc, so I decided to create scripts instead. To not create 1000 scripts, I decided to add a space, and only create an intelligent command system, which was much better than aliases because now I could parse the command, for example:

```bash
i ds1§2
```

would expand to

```bash
git diff --shortstat HEAD~1 HEAD~2
```

Thanks to this system, I could convert some symbols to more complex descriptions and have all the combinations in any order for free. I even could do this

```bash
i cgge$my-email@example.org$gn$my-name$
```

would expand to

```bash
git config --global user.email my-email@example.org --global user.name my-name
```

Parsing was now a core part of my prompts and I could not get rid of them. One problem remained: I can't remove the space after `i` without losing this parsing mechanism. Unless... I write my own shell. And here we are. The goal for the future is also to implement some useful behaviours, such as:

- automatically using `less` when the output is bigger than the terminal (instead of doing it always or never like in git commands)
- access the previous output without recomputing (to ease incremental piping).
- cancel feature that would cancel the last ran command if possible (for example rename a file on an existing file deletes it, removing a file, going to a folder, environment change, etc.)
- adding `fzf` virtually everywhere (I already have scripts to do lots of things with `fzf` but I wan't to push it further)
- instant update of the commands in all shells without restarting it (the problem of hardcoding them is that we should need to recompile and re-run, this will be solved by running them in a different process).
