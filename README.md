# uspokoysa
Dead simple Nim app for making timebreaks

## How it works
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
