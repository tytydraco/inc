# Example file for inc

In this static Markdown file, we will insert some dynamic code. Let's insert a sequence from 1 to 100. We will compile
it using:

```shell
inc -i README.md -o example_compiled.md
```

|>
for i in range(1, 100):
    print(f' * {i + 1}')
<|
