# uspokoysa
Dead simple Nim app for making timebreaks

## How it works
There are short and long breaks.

Suppose you are using such config (numbers correlate to dots and dashes on the schema below):
```
shortBreakDuration: 1    # in seconds
shortBreakInterval: 6    # in minutes
longBreakDuration: 3     # in minutes
longBreakInterval: 3     # in short breaks count
```

```
------<.>------<.>------<.>------<...>------<.>------<.>------<.>------<...>
_______|        |        |         |         |
short break #1  |        |         |         |
                |        |         |         |
________________|        |         |         |
short break #2           |         |         |
                         |         |         |
_________________________|         |         |
short break #3                     |         |
                                   |         |
___________________________________|         |
long break                                   |
                                             |
_____________________________________________|
short break #1 (again)
and so on...
```

## Configuration
`uspokoysa` uses config file at `~/.uspokoysarc`.

### Breaks
The following params are responsible for break durations and intervals between them (see above for explanation, here are defaults):
```
shortBreakDuration: 20   # in seconds
shortBreakInterval: 15   # in minutes
longBreakDuration: 5     # in minutes
longBreakInterval: 3     # in short breaks count
```

### Break notifications
You can specify a command to be executed 5 seconds before the break starts. Use `notificationCmd` param in the config file (no command by default!):
```
notificationCmd: notify-send -a "uspokoysa" "Uspokoysa!!!!1!!" -t 5000
```
