# inc

An inline pattern compiler for embedding Python code into static files.

# Example use-case

Say we have a README file containing the latest version of a package version. Instead of hardcoding that version number
and manually updating it when necessary, you can embed some Python code to fetch the version number and use `inc` to
compile your part-Markdown-part-python file into static Markdown. Here is an example of what that would look like:

```markdown
# My package

The latest version for this package is |>
```

```py
with open('package.txt') as p:
    version = p.readline()
    print(version, end='')
```

```markdown
<|

# Features

* Continue with markdown...
```

Once compiled via `inc`, the final contents of your README file would be something like this:

```markdown
# My package

The latest version for this package is 1.13.15

# Features

* Continue with markdown...
```

# Usage

```
-h, --help      Show the usage for this program.
-i, --input     Input file path to compile from. If none is provide, the standard input is used.
-o, --output    Output file path to write to. If none is provide, the standard output is used.
-1, --begin     Beginning pattern to match with.
                (defaults to "|>")
-2, --end       Ending pattern to match with.
                (defaults to "<|")
```

# Installing

If you already have Dart installed, simply activate the package globally:

```shell
dart pub global activate inc
```

Then, assuming your global package directory has
been [added to your PATH](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path), simply call the
executable.
