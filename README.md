## Contact Codetest

We'd like you to write a program to parse a cron string to expand the time fields and output a description of when the command will be run. Using the example above (`*/20 1-3 10,11 * * echo hello`), your program would output the following:

```
We'd like you to write a program to parse a cron string to expand the time fields and output a description of when the command will be run. Using the example above (*/20 1-3 10,11 * * echo hello), your program would output the following:
```

Your program will be executed with the cron string given as a single argument, e.g.:

```
$ ./your-program "*/20 1-3 10,11 * * echo hello"
```