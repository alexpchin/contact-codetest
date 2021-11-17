## Notes

A crontab command is usually made up of 5 fields in a space separated string:

```
minute: 0-59
hour: 0-23
day of month: 1-31
month: 1-12
day of week: 0-6 (0 == Sunday)
```

Each field can be a combination of the following values:

- a wildcard `*` which equates to all valid values.
- a range `1-10` which equates to all valid values between start-end inclusive.
- a step `*/2` which equates to every second value starting at 0, or 1 for day of month and month.
- a single value 2 which would be 2.
- a combination of the above separated by a `,`

### Step-by-step

Initially create a ruby file that takes an argument and outputs hardcoded result. 

### Regex for parsing CRON

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems)
# │ │ │ │ │
# │ │ │ │ │
# * * * * * <command to execute>
```

