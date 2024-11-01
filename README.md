# calver

Generate a [CalVer] version string from a Git log or the current time.

`calver` is stateless and will only read your Git log or output from `date`.

## CalVer interpretation

`calver` will make a version string triple that is not incompatible with the
SemVer syntax: there are no leading zeroes.

### Based on Git commits

Given a git log, the version string `MAJOR.MINOR.PATCH` will be printed, where

* `MAJOR` is the year of the last commit
* `MINOR` is the month and day of the last commit
* `PATCH` is the number of commits on the last day

To stay somewhat readable and still be ordered properly and agree with SemVer
syntax, the `MINOR` version is calculated by adding the day with 100 * the
month: January 1 is `101`, January 11 is `111`, November 1 is `1101`, etc.

### Based on current time

With the `--timestamp` option, the string `MAJOR.MINOR.PATCH` is printed,

* `MAJOR` is the current year
* `MINOR` is the current month and day
* `PATCH` is the current hour and minute

To stay somewhat readable and still be ordered properly and agree with SemVer
syntax, the `MINOR` version is calculated by adding the day with 100 * the
month: January 1 is `101`, January 11 is `111`, November 1 is `1101`, etc.
and the `PATCH` version is calculated similarly using hours and minutes.

## Example

If this is your git log:

```
❯ git log --pretty=format:"%h %ad - %s" --date=short | head
7d050f0 2023-08-06 - add some notes on globals
3dfa35a 2023-08-06 - make render more clear
11532bf 2023-08-06 - make reciter more clear
b95f123 2023-08-06 - make it easier to build on macos
fea97f3 2023-08-06 - add gitignore
5c251dc 2023-08-06 - remove trailing whitespace
c86ea39 2018-09-23 - Fix breakage on Linux
525b1b6 2018-09-23 - Merge pull request #1 from ...
e393e19 2018-09-23 - Revert "Strip whitespace"
7d58136 2018-09-23 - Revert "CR/LF"
```

The last commit was on August 6 2023 and there were six commits in total that day. `calver` will yield:

```
❯ calver
2023.806.6
```

If you are executing the script using `--timestamp` on October 27 2024:

```
❯ ./calver --timestamp
2024.1027.1337
```

[CalVer]: https://calver.org
