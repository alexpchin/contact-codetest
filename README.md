## Contact Codetest

We'd like you to write a program to parse a cron string to expand the time fields and output a description of when the command will be run. Using the example above (`*/20 1-3 10,11 * * echo hello`), your program would output the following:

```
minute: 0 20 40
hour: 1 2 3
day of month: 10 11
month: 1 2 3 4 5 6 7 8 9 10 11 12
day of week: 1 2 3 4 5 6 7
command: echo hello
```

Your program will be executed with the cron string given as a single argument, e.g.:

```sh
$ ./your-program "*/20 1-3 10,11 * * echo hello"
```

### Solution

```sh
$ ruby ./run.rb "*/20 1-3 10,11 * * echo hello" 
```

### Tests

Run tests with:

```sh
$ rspec
```