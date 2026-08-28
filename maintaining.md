# Maintaining completion scripts

This document aims to outline how the different completion scripts should be maintained in the case of an
update to the compiler that introduces new flags, options and other behaviour.

## Bash

*TODO*

## ZSH

The `zsh` completion makes use of it's own completion system by the name of `compsys`, for which extensive documentation can be found [here](https://zsh.sourceforge.io/Doc/Release/Completion-System.html), specifically in Section [20.6](https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Completion-Functions).

### Layout

The file is laid out in a way that aims to make it as declarative as possible. It is laid out as follows:

1. Helper functions for making completion specs
2. Completion specs, described in the following table

   | Name                     | Description                                                                                |
   | ------------------------ | ------------------------------------------------------------------------------------------ |
   | Subcommands              | Subcommands of the main `c3c` command                                                      |
   | Simple options           | Options who don't expect a value and take effect just by being present                     |
   | Dir options              | Options that are completed with a directory                                                |
   | Toggle options           | Options that are completed with either "yes" or "no"                                       |
   | Multi options            | Options that have a set selection of values they can be completed with                     |
   | Complex options          | Options whose completion does not fall into any of the above and/or needs special handling |
   | C3C Project Filter Views | Flags specifically for the `c3c project view` command                                      |

3. Registration of completion specs 

### Maintenance

#### Overview

For maintenance, adding the relevant options in the arrays should be enough. For a deeper understanding, a brief overview of the completion process is given in the following.

The main entry of the completion is the `c3c` function, as defined in the first line of the script. The `_arguments` function is responsible for showing on screen the completion specs it's given. Invoking it with the `-C` flag stores relevant information about the completion in the variables `context`, `state`, `state_descr`, `line` and `opt_args`. These may be subsequently evaluated to determine what completions to offer beyond just the initial subcommand.

Inspecting the first member of the `line` array tells us what the subcommand entered is, and we pass control to a different function which will handle completion from thereon out.

#### Control functions

Out of these, `init` is the simplest, expecting only a `--template` flag.

`project` similarly inspects what subcommand it was given, and in the case of `view`, it will also pass control to a designated function that simply offers the `c3c_project_view_filters` filters as described above.

Other than that, the remaining commands are considered build commands and will offer all the other option types as described in the table. The only special line here is the last one in `_c3c_build`, which allows for the `--linker` flag to have a two part completion if the first argument after it is `custom`, in which case it will complete to a file for this flag.

#### Format of flags

The format of completion specs for this completion system can be a bit sophisticated, and is therefore best understood by looking at the `specs: overview` section of the documentation. For the purposes of this script, it would be the easiest to understand a flag as follows:

`--<name>:<message>:<action>`

The `name` is the name of the flag, `message` is a string that is printed above the matches generated, and `action` gives explicit completions for the flag. If left empty, there will be no completion (which is useful for flags without options).

Mostly, it will be of the form `(foo bar bazz)`, which would mean that the flag could use either of `foo`, `bar`, or `bazz` as options. This is used for `c3c_toggle_options` and `c3c_multi_options`. Alternatively, there are some special functions that the completion system offers for action. The most interesting ones for us are `files`, which completes to a file, and `files -/`, which completes to a directory and is used in `c3c_dir_options`.
