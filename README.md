[![License: CC0-1.0](https://img.shields.io/badge/License-CC0%201.0-lightgrey.svg)](http://creativecommons.org/publicdomain/zero/1.0/)

[English](README.md) | [日本語](README.ja.md)

# bash-styleguide

The style guide is not absolute; break it if necessary. The aim of this style guide is to reduce the psychological barriers to writing Bash scripts and to provide answers to common problems encountered when writing Bash scripts. Bash scripts are often delicate, difficult to maintain, and can easily become disliked. However, writing Bash scripts is sometimes necessary, so this style guide has been prepared.

When in doubt, prioritize consistency. By using a single style consistently throughout the codebase, you can focus on other (more important) issues. Consistency also allows for automation. In many cases, the rule of "maintain consistency" means "choose one option and stop worrying about it." The potential value of allowing flexibility on these points is outweighed by the cost of people debating them. However, there are limits to consistency. Consistency is a good factor for making decisions when there is no clear technical argument or long-term direction. On the other hand, consistency should not be used to justify continuing with an outdated style when there are clear advantages to a new one.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
# Table of Contents

- [Introduction](#introduction)
  - [Automation Support](#automation-support)
  - [How the Style Guide Changes](#how-the-style-guide-changes)
- [Background](#background)
  - [Which Shell to Use](#which-shell-to-use)
  - [When to Use Shell](#when-to-use-shell)
  - [Shell Execution Environment](#shell-execution-environment)
- [Shell Files and Interpreter Invocation](#shell-files-and-interpreter-invocation)
  - [File Extensions](#file-extensions)
  - [SUID/SGID](#suidsgid)
- [Environment](#environment)
  - [Script Invocation](#script-invocation)
  - [Common Function Scripts](#common-function-scripts)
  - [Script Argument Control](#script-argument-control)
  - [Debug and Dry-run Mode](#debug-and-dry-run-mode)
  - [Make It Executable Locally](#make-it-executable-locally)
  - [STDOUT vs STDERR](#stdout-vs-stderr)
- [Naming Conventions](#naming-conventions)
  - [Function Names](#function-names)
  - [Variable Names](#variable-names)
- [Comments](#comments)
  - [File Header](#file-header)
  - [Implementation Comments](#implementation-comments)
  - [TODO Comments](#todo-comments)
- [Formatting](#formatting)
  - [Tabs and Spaces](#tabs-and-spaces)
  - [Line Length and Long Strings](#line-length-and-long-strings)
  - [Pipelines](#pipelines)
  - [Loops](#loops)
  - [Case statement](#case-statement)
  - [Variable Expansion](#variable-expansion)
  - [Quoting](#quoting)
  - [Function Declaration](#function-declaration)
- [Features and Bugs](#features-and-bugs)
  - [Use ShellCheck](#use-shellcheck)
  - [Command Substitution](#command-substitution)
  - [Test Expression](#test-expression)
  - [Testing Strings](#testing-strings)
  - [Wildcard Expansion of Filenames](#wildcard-expansion-of-filenames)
  - [Evalの禁止 (Eval is Evil)](#eval%E3%81%AE%E7%A6%81%E6%AD%A2-eval-is-evil)
  - [配列 (Arrays)](#%E9%85%8D%E5%88%97-arrays)
  - [Pipes to While](#pipes-to-while)
  - [For Loops](#for-loops)
  - [Arithmetic](#arithmetic)
- [Calling Commands](#calling-commands)
  - [Checking Return Values](#checking-return-values)
  - [Error Handling](#error-handling)
  - [Builtin Commands vs. External Commands](#builtin-commands-vs-external-commands)
- [Script Stabilization](#script-stabilization)
  - [Writing Rerunnable Scripts](#writing-rerunnable-scripts)
  - [Check State Before Changing](#check-state-before-changing)
  - [Safely Creating Temporary Files](#safely-creating-temporary-files)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Introduction

This style guide provides guidelines for writing Bash scripts. It is based on the [Google Shell Style Guide (rev 2.03)](https://google.github.io/styleguide/shellguide.html) and [icy/bash-coding-style](https://github.com/icy/bash-coding-style), with some custom rules. Items that are intentionally made custom are explicitly marked as `(custom)`.

The following symbols are used:

| Symbol | Meaning |
| --- | --- |
| ✔️ DO | Recommended. |
| ❌ DO NOT | Not recommended. Make an effort to avoid it. |
| ⚠️ CONSIDER | Consider if possible. It may be applied depending on the situation. |

## Automation Support

To help adhere to the style guide, the following automation support is provided. By following the recommendations from automation support, almost all aspects of the style guide will be met (script structure is not guaranteed).

* Running `shellcheck` on PRs: If there are any ShellCheck errors, they will be detected by CI and a warning will be issued
* Indentation is automatically corrected with EditorConfig. By installing [EditorConfig.EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig) in VSCode, it will be applied in real-time
* By installing [timonwong.shellcheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck) in VSCode, you can see the results of ShellCheck in real-time
* You can run shellcheck locally by executing the following steps. Run the following commands:

```shell
paths=(".")
for item in "${paths[@]}"; do
  for script in $(find "${item}" -type f -name "*.sh" | grep -v "/.git/"); do
    echo "## shellcheck: ${script}"
    shellcheck '--external-sources' "$script"
  done
done
```

## How the Style Guide Changes

Scripts that follow the style guide can be expected to include the following standard modifications:

* The script structure will be unified. Scripts will have a consistent structure as outlined in the style guide
* They will be compatible with shellcheck. No issues will be detected by standard shellcheck runs, and some excessive warnings will be disabled inline
* CI will automatically run `shellcheck`. This will detect any violations at the PR stage
* Procedures for running `shellcheck` locally will be specified. This allows warnings detected by CI to be reproduced and fixed locally
* Common functions will be supported, such as logging functions like `common::print` and enabling debugging. This ensures uniform log formatting and consistent enabling of debugging features
* The `--debug` argument will be supported. This allows the script to run with `set -e` enabled without modifying the script
* The `--dry-run` argument will be supported. This is set in scripts with side effects, allowing you to verify what will be executed without actually making any changes
* The `--aws-args` argument will be supported. This is set in scripts that include aws commands, allowing them to run with local credentials
* Script arguments will be displayed at runtime. This makes it clear what values are being used before execution begins

When writing scripts, ensure they follow the script structure and have no shellcheck issues. Meeting these two points will prevent most minor mistakes and ensure a certain level of script debuggability.

* Create scripts according to the [Script Structure](#スクリプトの構造-script-structure)
  * Include common arguments such as --dry-run and --debug
  * Initialize arguments
  * Use common functions for log output
  * Copy existing scripts to make it easier
* Ensure no shellcheck issues are detected locally or in PRs

# Background

## Which Shell to Use

> **Note** Custom rule (based on Google Shell Style Guide)

* ✔️ DO: Use Bash for all scripts
* ✔️ DO: Write `#!/bin/bash` at the top of the script
* ✔️ DO: Use `set -euo pipefail` for shell option settings. (custom)
* ⚠️ CONSIDER: If using other shells, explain the reason in comments. (custom)

Use Bash. Executable files should start with `#!/bin/bash` and minimal flags. Restricting all executable shell scripts to `bash` ensures a consistent shell installed on all machines. The only exception to this rule is when required by the coding target. For example, Alpine's default shell is ash, thus using `/bin/sh`.

Using `set` for shell option settings ensures that even if the script is called with `bash script_name`, its functionality is not impaired. `set -euo pipefail` automatically detects errors early and terminates the script if an error occurs. `set -e` terminates the script if an error occurs. `set -u` triggers an error when referencing undefined variables. `set -o pipefail` terminates the script if an error occurs in the middle of a pipeline.

**Recommended**

```shell
#!/bin/bash
set -euo pipefail
```

**Discouraged**

```shell
#!/bin/bash
# Missing set

#!/bin/bash -euo pipefail
# Use set. -euo is disabled when using bash ./function.sh.
```


## When to Use Shell

> **Note** Custom rule (based on Google Shell Style Guide)

* ✔️ DO: Use only for small utilities or simple wrapper scripts
* ✔️ DO: If you want to write a few lines of script in CI like GitHub Actions, create a shell script instead of embedding it in a yaml file. (custom)
* ✔️ DO: If calling the same process with different parameters in multiple workflows in CI like GitHub Actions, create a shell script instead of embedding it in a yaml file. (custom)
* ⚠️ CONSIDER: If performance is critical, consider other languages besides shell
* ⚠️ CONSIDER: If writing a script over 100 lines or using complex control flow logic, rewrite it in a more structured language as soon as possible. Anticipate that the script will grow. Rewriting early can avoid a time-consuming rewrite later
* ⚠️ CONSIDER: When evaluating code complexity (e.g., deciding whether to switch languages), consider whether the code can be easily maintained by someone other than the original author

Shell is a suitable choice for tasks that mainly involve calling other utilities and performing relatively few data manipulations. Although shell scripts are not a development language, they are used to create various utility scripts in CI. This style guide does not suggest extensive deployment of shell scripts but acknowledges their use.

Use shell scripts for small utilities or simple wrapper scripts. In particular, use shell scripts for "multi-line processing" or "reusable processing in multiple workflows" in GitHub Actions. While Bash makes it easy to handle text, it is not suitable for overly complex processing or language/app-specific processing. Consider using a structured language in such cases.


## Shell Execution Environment

> **Note** Custom rule

* ✔️ DO: Assume shell execution in GitHub Actions `ubuntu-latest` runner
* ✔️ DO: When running locally, use Ubuntu (WSL)
* ⚠️ CONSIDER: If running in other environments, adjust the shell script accordingly (e.g., macOS)

Shell scripts are assumed to be executed in the `ubuntu-latest` runner of GitHub Actions. When running locally, use Ubuntu (WSL). Since there is no guarantee of GNU commands in other environments, you need to adjust the shell script to match the environment.

# Shell Files and Interpreter Invocation

## File Extensions

> **Note** Custom rule (based on Google Shell Style Guide)

* ✔️ DO: Use the `.sh` extension for scripts called from outside
* ✔️ DO: Do not use extensions for scripts that are internal only. (custom)

Executable files should either have a `.sh` extension (strongly recommended) or no extension. Scripts called from outside must have a `.sh` extension and should not be made executable.

**Recommended**

```shell
# Script called from outside
foo.sh

# Script called only internally
_functions
```

**Discouraged**

```shell
# Avoid using no extension for scripts called from outside
foo

# Avoid using .sh for scripts called only internally
functions.sh
```

## SUID/SGID

> **Note** Custom rule (based on Google Shell Style Guide)

* ✔️ DO: Use `sudo` if you need to elevate privileges
* ❌ DO NOT: SUID and SGID are prohibited
* ❌ DO NOT: `sudo` is also prohibited in GitHub Actions scripts. (custom)

SUID and SGID are prohibited in shell scripts. Shell has many security issues, making it nearly impossible to ensure sufficient safety to allow SUID/SGID. Although bash makes SUID execution difficult, it is possible on some platforms, so it is explicitly prohibited. If privilege escalation is needed, use `sudo`.

As long as scripts are executed in GitHub Actions, `sudo`, SUID, and SGID are unnecessary and therefore prohibited.

**Recommended**

```shell
# Use sudo when calling (Except in GitHub Actions)
sudo ./foo.sh
```

**Discouraged**

```shell
# Switching to su or root user inside the script
```

# Environment

## Script Invocation

> **Note** Custom rule

* ✔️ DO: Invoke scripts through `bash`
* ✔️ DO: Enclose script arguments in quotes. However, if there is no possibility of spaces, such as in fixed strings, quotes can be omitted
* ❌ DO NOT: Do not execute scripts directly

Avoid executing scripts directly. By invoking scripts through `bash`, you ensure a consistent execution environment and prevent the current interactive shell from exiting due to an exit command.

**Recommended**

```shell
bash ./foo.sh

# Quotes can be omitted if there is no possibility of spaces
bash ./foo.sh --baz true

# Enclosing in quotes makes it safe even if there are spaces
bash ./foo.sh --foo "hello world" --bar "$bar"
```

**Discouraged**

```shell
# Direct invocation
. ./foo.sh

# Do not give execute permission with chmod +x and execute
chmod +x foo.sh
./foo.sh

# If the bar variable contains spaces or is an empty string, argument parsing may go wrong
bash foo.sh --foo hello world --bar $bar
```

## Common Function Scripts

> **Note** Custom rule

* ✔️ DO: Use `.` to invoke common functions

When calling common functions, use `.` instead of `source`. This is because `.` is POSIX compliant. However, avoiding shellcheck SC1091 can be difficult, so use shellcheck disable in such cases.

**Recommended**

```shell
# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_functions"
```

**Discouraged**

```shell
# Use . instead of source
source "$(dirname "${BASH_SOURCE[0]}")/_functions"
```


## Script Argument Control

> **Note** Custom rule

* ✔️ DO: Process arguments with a while loop and handle them with a case statement
* ✔️ DO: Accept script arguments in the form of `--parameter-name value`. Use understandable names for parameter names
* ✔️ DO: If using optional arguments that do not require specification, initialize them with local variables using `${_variable_name:=default_value}`
* ⚠️ CONSIDER: Avoid accepting `--parameter-name` alone; however, it is permissible in some situations, in which case use `shift` instead of `shift 2`
* ❌ DO NOT: Do not accept script arguments without parameter specification, such as `value1 value2 value3`
* ❌ DO NOT: Avoid using single-letter argument names like `--f` or abbreviated names like `--ns`

Control script arguments by looping through them with a while loop, using a case statement for evaluation, and shifting the arguments as they are parsed. When receiving script arguments, use `_UPPERCASE` for variables to distinguish them from local variables and constants. Ensure that script arguments are initialized before entering the main processing, and display them in logs to facilitate debugging.

**Recommended**

```shell
set -euo pipefail # -u stops processing with uninitialized variables

while [[ $# -gt 0 ]]; do
  case $1 in
    # required (mandatory arguments; processing stops if not specified)
    --bar-piyo) _BAR_PIYO=$2; shift 2; ;; # Accept with `--bar-piyo "value"`
    # optional (optional arguments; initialized with default values)
    --optional) _OPTIONAL=$2; shift 2; ;; # Optional. Initialized with default value when displaying variables.
    *) shift ;;
  esac
done

# Initialize variables
common::print "Arguments:"
common::print "--bar-piyo=${_BAR_PIYO}" # Optional arguments are initialized with default values here if omitted.
common::print "--optional=${_OPTIONAL:="true"}" # Optional arguments are initialized with default values here if omitted.
```

**Discouraged**

```shell
set -euo pipefail # -u stops processing with uninitialized variables

while [[ $# -gt 0 ]]; do
  case $1 in
    # required
    -f) _FOO_=$2; shift 2; ;; # Single hyphen argument names are not allowed
    --bar) _BAR=true; shift; ;; # Avoid accepting arguments without values; better to use true/false
    # optional
    -o) _OPTIONAL=$2; shift 2; ;; # No variable initialization, so it fails at runtime if not specified
    *) shift ;;
  esac
done

# No variable initialization
```


## Debug and Dry-run Mode

> **Note** Custom rule

* ✔️ DO: Provide a debug mode like `--debug true|false`
* ✔️ DO: Provide a dry-run mode like `--dry-run true|false` unless it is impractical
* ✔️ DO: Set the default value of the `--dry-run` argument to `true` when omitted

Consider including `--debug` and `--dry-run` as common arguments for scripts. Debug and dry-run modes are useful for debugging and testing as they change the script's behavior. Debug mode traces script execution by enabling `set -x`. Dry-run mode verifies script behavior by displaying the commands that would be executed or utilizing the command's dry-run mode without actually executing them. Although initializing these modes can make the script longer, necessary arguments for modifying script behavior are essential.

Setting the default value of the `--dry-run` argument to `true` prevents accidental execution when the script is run. This is very useful to avoid unintended runs.

**Recommended**

```shell
# ... omitted

# Argument processing
while [[ $# -gt 0 ]]; do
  case $1 in
    # optional
    --debug) _DEBUG=$2; shift 2; ;; # Debug mode
    --dry-run) _DRYRUN=$2; shift 2; ;; # Dry-run mode
    *) shift ;;
  esac
done

# Initialize variables
common::print "Arguments:"
common::print "--debug=${_DEBUG:="false"}" # Set default to false to enable debug mode only when needed
common::print "--dry-run=${_DRYRUN:="true"}" # Set default to true to avoid accidental execution

# Set debug mode
common::debug_mode # Common script enables set -x

# Prepare for dry-run
dryrun=""
dryrun_k8s=""
dryrun_aws=""
dryrun_az=""
if [[ "${_DRYRUN}" == "true" ]]; then
  dryrun="echo (dryrun) "
  dryrun_k8s="--dry-run=server"
  dryrun_aws="--dryrun"
  dryrun_az="--dryrun"
fi

# Use common functions to output debug messages. Imagine the implementation of common::debug as follows:
# function common::debug {
#   if [[ "${_DEBUG:=false}" == "true" ]]; then
#     echo "$*"
#   fi
# }
common::debug "Debug message"

# Replace command with echo for dry-run mode
$dryrun dotnet run ...

# Use --dry-run=server for kubectl to enable dry-run mode with server-side validation
kubectl apply -f ./manifests ${dryrun_k8s}

# Insert --dryrun for aws s3 cp to enable dry-run mode
aws s3 cp $dryrun_aws ...

# Most AWS commands except aws s3 do not have a dry-run mode, so replace them with echo
$dryrun aws scheduler ...

# Insert --dryrun for az webapp to enable dry-run mode
az webapp up $dryrun_az ...

# Replace az containerapp with echo as it does not have a dry-run mode
$dryrun az containerapp ...
```

**Discouraged**

```shell
# Forcing -x makes script execution hard to read, so provide a debug mode
set -euxo pipefail

# Argument processing
while [[ $# -gt 0 ]]; do
  case $1 in
    # --debug is essential. Please include it.
    # Why not include --dry-run if possible?
    *) shift ;;
  esac
done

# No debug mode, so standard output is used
echo "Debug message"

# No dry-run mode!?
dotnet run ...

# No dry-run mode!?
kubectl apply -f ./manifests

# No dry-run mode!?
aws s3 cp ...

# No dry-run mode!?
az webapp up ...
```

## Make It Executable Locally

> **Note** Custom rule

* ✔️ DO: Make scripts executable in the local environment
* ❌ DO NOT: Avoid requiring users to have knowledge of the CLI used in the script

Making scripts executable in the local environment facilitates script development and makes it easier to verify their operation. Providing options such as AWS arguments and dry-run mode is useful for making scripts executable. However, if authentication can be handled with a prior login session, such as with `az login`, this consideration is unnecessary.

**Recommended**

```shell
# Pass AWS credentials by specifying --aws-args during local execution
$ my_script.sh --aws-args "--profile aws-profile --region ap-northeast-1" --dry-run true
```

```shell
# ... omitted

# Argument processing
while [[ $# -gt 0 ]]; do
  case $1 in
    # optional
    --aws-args) _AWS_ARGS=$2; shift 2; ;;
    *) shift ;;
  esac
done

# Initialize variables
common::print "Arguments:"
common::print "--aws-args=${_AWS_ARGS:=""}"

# ... omitted

# Provide local authentication arguments during script execution
aws rds describe-db-clusters $_AWS_ARGS
```

**Discouraged**

```shell
# Pass AWS credentials using environment variables during local execution. Requires the user to have aws cli knowledge.
$ AWS_PROFILE=aws-profile AWS_REGION=ap-northeast-1 my_script.sh
```

```shell
# ... omitted

# Whether the aws command can be executed locally depends on the environment, limiting the user base.
aws rds describe-db-clusters
```

## STDOUT vs STDERR

> **Note** Custom rule (based on Google Shell Style Guide)

* ✔️ DO: Output error messages to STDERR
* ❌ DO NOT: Do not output error messages to STDOUT

By outputting error messages to `STDERR`, it becomes easier to distinguish between normal output and actual issues. Instead of defining custom functions for error messages in scripts, use the common function `common::error`.

**Recommended**

```shell
function common::error {
  echo "ERROR(${FUNCNAME[1]:-unknown}):: $*" >&2
}

if ! do_something; then
  common::error "Unable to do_something"
  exit 1
fi
```

**Discouraged**

```shell
if ! do_something; then
  echo "Unable to do_something"
  exit 1
fi
```

# Naming Conventions


## Function Names

> **Note** Custom rule (based on Google Shell Style Guide and icy/bash-coding-style)

* ✔️ DO: Use the `function` keyword. (custom)
* ✔️ DO: Use lowercase letters and underscores to separate words
* ✔️ DO: Separate package and function names with `::` in common scripts
* ✔️ DO: Prefix functions used only within common scripts with `__`. (custom)
* ❌ DO NOT: Do not use parentheses `()` after function names. (custom)

For single functions, use lowercase letters and underscores to separate words. For common functions, separate package names and function names with `::`.
Braces should be written on the same line as the function name. While the `function` keyword is not mandatory if parentheses `()` are used after the function name, use `function` to explicitly indicate it is a function, and do not use `()`.

**Recommended**

```shell
# Single function
function my_func {
  ...
}

# Function published as a package
function mypackage::my_func {
  ...
}

# Functions intended to be used only within the package are prefixed with __
function __super_internal_func {
  ...
}
```

**Discouraged**

```shell
# No function keyword and parentheses are used
MyFunc () {
  ...
}

# Function name in PascalCase
function MyFunc {
  ...
}

# Function name in camelCase
function myFunc {
  ...
}

# No :: to separate package and function name
function package_my_func {
  ...
}
```

## Variable Names

> **Note** Custom rule (based on Google Shell Style Guide and icy/bash-coding-style)

* ✔️ DO: Use lowercase letters and underscores to separate words, similar to function names
* ✔️ DO: Name loop variables similarly to the variables they iterate over

**Recommended**

```shell
for zone in "${zones[@]}"; do
  something_with "${zone}"
done
```

**Discouraged**

```shell
for item in "${zones[@]}"; do
  something_with "${item}"
done
```

Declare constants and environment variables in uppercase. Constants should be declared at the top of the file.

* ✔️ DO: Declare constants in uppercase with underscores to separate words, at the top of the file
* ✔️ DO: Declare constants and exported environment variables in uppercase


**Recommended**

```shell
# Constants
readonly PATH_TO_FILES='/some/path'

# Constants and environment variables
declare -xr ORACLE_SID='PROD'
```

**Discouraged**

```shell
# Declaring constants in lowercase
readonly path_to_file='/some/path'

# Declaring constants and environment variables in lowercase
declare -xr oracle_sid='PROD'
```

Variables provided by the user in the parent scope, such as script arguments, should be declared in `_UPPERCASE` with underscores to separate words.

Global variables are used throughout the shell, so it is important to catch errors when using them. Explicitly declare variables intended to be read-only.

* ⚠️ CONSIDER: Use `readonly` or `declare -r` to ensure they are read-only. This style should be applied whenever possible, but it is not mandatory. (custom)

**Recommended**

```shell
readonly zlib1g_version="$(dpkg --status zlib1g | grep Version: | cut -d ' ' -f 2)"
if [[ -z "${zlib1g_version}" ]]; then
  echo "error message"
fi
```

**Discouraged**

```shell
# Not read-only
zlib1g_version="$(dpkg --status zlib1g | grep Version: | cut -d ' ' -f 2)"
if [[ -z "${zlib1g_version}" ]]; then
  error_message
fi
```

When declaring variables within a function using `local`, it ensures that the variables are only visible inside the function and its children. If you use command substitution for assignment, declare and assign the value in separate statements. This prevents the command's exit code from being overwritten by `local`.

* ✔️ DO: Declare function-specific variables with `local`
* ✔️ DO: When using command substitution for assignment, separate the declaration and assignment to avoid overwriting the command's exit code with `local`

**Recommended**

```shell
my_func2() {
  # Declaration and assignment on the same line are fine if there is no error
  local name="$1"

  # Separate declaration and assignment when using command substitution
  local my_var
  my_var="$(my_func)"
  (( $? == 0 )) || return

  ...
}
```

**Discouraged**

```shell
my_func2() {
  # $? will always be zero because it holds the exit code of 'local', not 'my_func'
  local my_var="$(my_func)"
  (( $? == 0 )) || return

  ...
}
```

# Comments

## File Header

> **Note** Google Shell Style Guide

* ✔️ DO: Include a comment at the beginning of the file that concisely explains the purpose or content of the file. However, do not include comments before the shebang line

Files should start with a description of their content. All files should include a top-level comment that briefly describes their content.

**Recommended**

```shell
#!/bin/bash
#
# Perform hot backups of Oracle databases.
```

## Implementation Comments

> **Note** Google Shell Style Guide

* ✔️ DO: Add comments to code that is tricky, has significant meaning, or requires attention
* ✔️ DO: Keep comments short and easy to understand whenever possible
* ⚠️ CONSIDER: If a brief explanation is not sufficient, consider providing detailed background information

Comment on parts of the code that are tricky, not immediately obvious, interesting, or important. However, do not comment on everything. Add comments when there are complex algorithms or when doing something unusual. If a short comment cannot provide a clear explanation, include detailed background information.


## TODO Comments

> **Note** Custom rule (based on Google Shell Style Guide)

* ✔️ DO: Consider using TODO comments
* ❌ DO NOT: Do not include the name of the person who wrote the TODO comment. (custom)

Use TODO comments for temporary, short-term solutions, or code that is good enough but not perfect. TODO comments should include the uppercase string `TODO`. There is no need to include the individual's name, as it can be identified using `git blame`. The purpose of TODO comments is to provide a searchable and consistent `TODO` marker that can be looked up for more details as needed. Since the person referenced in the TODO is not necessarily committed to fixing the issue, it is helpful to include the expected resolution.

**Example**

```shell
# TODO: This code needs to be fixed due to insufficient error handling. Add error checks and exit with 1.
```

# Formatting

When editing existing files, follow the existing style, but apply the following style to new code.


## Tabs and Spaces

> **Note** Custom rule (based on Google Shell Style Guide and icy/bash-coding-style)

* ✔️ DO: Follow auto-formatting based on EditorConfig. (custom)
* ✔️ DO: Indent with two spaces. Do not use tabs
* ✔️ DO: Include blank lines between blocks for readability
* ✔️ DO: Do not include trailing spaces. (custom)
* ✔️ DO: Add a newline at the end of the file. (custom)
* ❌ DO NOT: Do not force the style on existing files. Maintain the style of existing files

EditorConfig will automatically fix indentation, trailing spaces, and newlines at the end of files. Indentation should be two spaces. Under no circumstances should tabs be used.

Many editors cannot switch between actual indentation and displayed spaces/tabs according to user preference. Another person's editor may not have the same settings as yours. Using spaces ensures that code looks the same in any editor.

In existing files, strictly follow the existing indentation. There is no need to force the style on existing files, but if auto-fixes by EditorConfig occur, include those in your commits.

## Line Length and Long Strings

> **Note** Custom rule

* ✔️ DO: Consider using here documents or embedded newlines for excessively long strings
* ⚠️ CONSIDER: Look for ways to shorten string literals

There is no maximum line length, nor a rule to break lines at N characters. However, if you need to write excessively long strings, consider using here documents or embedded newlines if possible. While the presence of string literals that cannot be appropriately divided is allowed, it is strongly recommended to look for ways to shorten them.

**Recommended**

```shell
# Use of here document
cat <<END
I am an exceptionally long
string.
END

# Embedded newline
long_string="I am an exceptionally
long string."

# Breaking array elements into separate lines
array=(
  "foo"
  "bar"
  "baz"
)
```

**Discouraged**

```shell
# Fitting into one line using \n (acceptable for specific cases like Slack API)
str="I am an exceptionally long\nstring."

# Array elements too crowded in one line
array=("foo" "bar" "baz" "piyo" "okonomi" "oosugiiiiii")
```


## Pipelines

> **Note** Custom rule (based on Google Shell Style Guide and icy/bash-coding-style)

* ✔️ DO: Write the entire pipeline on one line if it fits neatly
* ✔️ DO: Break the pipeline into separate lines if it is long and hard to read
* ✔️ DO: Apply the same rule to chains of commands with `|`, and logical operators `||` and `&&`

If a pipeline is long and hard to read, break it into separate lines. If the entire pipeline fits neatly on one line, write it on one line. When breaking lines, indicate continuation for the following pipe sections by adding a `\` at the end of the line, indent by two spaces, and place the pipe at the beginning of the next line. Do not break the line after a pipe.

This applies to chains of commands using `|`, and logical operators `||` and `&&`.

**Recommended**

```shell
# If it fits on one line
command1 | command2

# Long command
command1 \
  | command2 \
  | command3 \
  | command4
```

**Discouraged**

```shell
# Unnecessary line break when it fits on one line
command1 \
  | command2

# Difficult to read without line breaks
command1 | command2 | command3 | command4
```

## Loops

> **Note** Google Shell Style Guide

* ✔️ DO: Place `; do` and `; then` on the same line as `while`, `for`, and `if`
* ✔️ DO: Place `elif` and `else` on their own lines

Shell loops are a bit different, but following the principle of braces when declaring functions, place `; then` and `; do` on the same line as `if/for/while`. `else` should be placed on its own line, and closing constructs should also be on their own lines. They should be vertically aligned with their opening constructs.

**Recommended**

```shell
if [[ nantoka ]]; then
  ;;
fi

for i in $(seq 1 10); do
  echo $i
done
```

**Discouraged**

```shell
if [[ nantoka ]];
then
  ;;
fi

for i in $(seq 1 10)
do
  echo $i
done
```

## Case statement

> **Note** Google Shell Style Guide

* ✔️ DO: Indent cases by two spaces
* ✔️ DO: For single-line cases, place one space after the closing parenthesis of the pattern and before `;;`
* ✔️ DO: For long or multiple command cases, split the pattern, action, and `;;` into multiple lines
* ⚠️ CONSIDER: For short command cases, consider placing the pattern, action, and `;;` on one line if readability is maintained

Indent the conditions one level from `case` and `esac`. For multi-line actions, indent an additional level. There should be no opening parentheses before the pattern expression. Avoid using `;&` or `;;&`.

**Recommended**

```shell
case "${expression}" in
  "--a")
    _VARIABLE_="..."
    ;;
  "--absolute")
    _ACTIONS="relative"
    ;;
  *) shift ;;
esac
```

For simple commands, place the pattern and `;;` on the same line if readability is maintained. If the action does not fit on a single line, place the pattern on its own line, followed by the action on the next line, and then `;;` on its own line. When placing the pattern on the same line as the action, include one space after the closing parenthesis of the pattern and before `;;`.


## Variable Expansion

> **Note** Google Shell Style Guide

* ✔️ DO: Use consistent variable expansion
* ✔️ DO: Enclose variable expansions in double quotes. Single quotes do not expand variables
* ❌ DO NOT: Avoid bracing shell special variables/positional parameters unless explicitly necessary or to avoid serious confusion

Variables should be quoted. Use `${var}` instead of `$var`.
This is a strongly recommended guideline but not an absolute regulation. However, even though it is not mandatory, do not disregard it.

All other variables should preferably be enclosed in braces.

**Recommended**

```shell
# Preferred style for 'special' variables:
echo "Positional: $1" "$5" "$3"
echo "Specials: !=$!, -=$-, _=$_. ?=$?, #=$# *=$* @=$@ \$=$$ …"

# Braces necessary:
echo "many parameters: ${10}"

# Braces avoiding confusion:
# Output is "a0b0c0"
set -- a b c
echo "${1}0${2}0${3}0"

# Preferred style for other variables:
echo "PATH=${PATH}, PWD=${PWD}, mine=${some_var}"
while read -r f; do
  echo "file=${f}"
done < <(find /tmp)
```

**Discouraged**

```shell
# Unquoted vars, unbraced vars, brace-delimited single letter
# shell specials.
echo a=$avar "b=$bvar" "PID=${$}" "${1}"

# Confusing use: this is expanded as "${1}0${2}0${3}0",
# not "${10}${20}${30}
set -- a b c
echo "$10$20$30"
```

## Quoting

> **Note** Google Shell Style Guide

* ✔️ DO: Always quote variables, command substitutions, strings containing spaces or shell metacharacters, unless an unquoted expansion is required or the shell internal is an integer
* ✔️ DO: Use arrays to safely quote multiple elements, especially for command line flags. See [Arrays](#配列-arrays) below
* ✔️ DO: Quoting shell internal read-only special variables defined as integers is optional: `$?`, `$#`, `$$`, `$!` (see `man bash`). For consistency, quote internal integer variables like "${PPID}"
* ✔️ DO: Quote string variables like `("${words}")`
* ❌ DO NOT: Do not quote integer literals. Do not quote arithmetic expressions like `$((2 + 2))`
* ⚠️ CONSIDER: Pay attention to quoting rules for pattern matching within `[[...]]`. See [Test](#test) below
* ⚠️ CONSIDER: Use `"$@"` instead of `$*` unless you have a specific reason to concatenate arguments into a string or log message

```shell
# 'Single' quotes indicate that no substitution is desired.
# "Double" quotes indicate that substitution is required/tolerated.

# Simple examples

# "quote command substitutions"
# Note that quotes nested inside "$()" don't need escaping.
flag="$(some_command and its args "$@" 'quoted separately')"

# "quote variables"
echo "${flag}"

# Use arrays with quoted expansion for lists.
declare -a FLAGS
FLAGS=( --foo --bar='baz' )
readonly FLAGS
mybinary "${FLAGS[@]}"

# It's ok to not quote internal integer variables.
if (( $# > 3 )); then
  echo "ppid=${PPID}"
fi

# "never quote literal integers"
value=32
# "quote command substitutions", even when you expect integers
number="$(generate_number)"

# "prefer quoting words", not compulsory
readonly USE_INTEGER='true'

# "quote shell meta characters"
echo 'Hello stranger, and well met. Earn lots of $$$'
echo "Process $$: Done making \$\$\$."

# "command options or path names"
# ($1 is assumed to contain a value here)
grep -li Hugo /dev/null "$1"

# Less simple examples
# "quote variables, unless proven false": ccs might be empty
git send-email --to "${reviewers}" ${ccs:+"--cc" "${ccs}"}

# Positional parameter precautions: $1 might be unset
# Single quotes leave regex as-is.
grep -cP '([Ss]pecial|\|?characters*)$' ${1:+"$1"}

# For passing on arguments,
# "$@" is right almost every time, and
# $* is wrong almost every time:
#
# * $* and $@ will split on spaces, clobbering up arguments
#   that contain spaces and dropping empty strings;
# * "$@" will retain arguments as-is, so no args
#   provided will result in no args being passed on;
#   This is in most cases what you want to use for passing
#   on arguments.
# * "$*" expands to one argument, with all args joined
#   by (usually) spaces,
#   so no args provided will result in one empty string
#   being passed on.
#
# Consult
# https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html and
# https://mywiki.wooledge.org/BashGuide/Arrays for more

(set -- 1 "2 two" "3 three tres"; echo $#; set -- "$*"; echo "$#, $@")
(set -- 1 "2 two" "3 three tres"; echo $#; set -- "$@"; echo "$#, $@")
```

## Function Declaration

> **Note** Google Shell Style Guide

* ❌ DO NOT: Avoid writing executable code between function declarations

Writing processing code between function declarations makes it difficult to track the code and can lead to unexpected issues during debugging. Place function declarations immediately after the constant declarations section.

**Recommended**

```shell
function foo() {
  ...
}
function bar() {
  ...
}

echo "Some processing"
```

**Discouraged**

```shell
function foo() {
  ...
}

echo "Some processing"

function bar() {
  ...
}
```

# Features and Bugs

## Use ShellCheck

> **Note** Custom rule (based on Google Shell Style Guide)

* ✔️ DO: Use ShellCheck to identify bugs in shell scripts
* ✔️ DO: Resolve all ShellCheck warnings with a severity level of warning or higher. (custom)
* ⚠️ CONSIDER: Consider resolving all ShellCheck warnings with a severity level of info or higher. (custom)
* ⚠️ CONSIDER: If you cannot resolve ShellCheck warnings with a severity level of info, consider adding `# shellcheck disable=SCXXXX` comments to ignore them. (custom)

The [ShellCheck](https://www.shellcheck.net/) project detects common bugs and warnings in shell scripts. Apply it to all shell scripts, regardless of their size.

ShellCheck can be [installed](https://github.com/koalaman/shellcheck) on Windows, Ubuntu, and macOS.

```shell
# Debian/Ubuntu
sudo apt install shellcheck
# macOS
brew install shellcheck
# Windows
winget install --id koalaman.shellcheck
scoop install shellcheck
```

**Recommended**

```
# Use $() for command substitution.
foo=$(cmd ...)

# Enclose variables with potential spaces in quotes.
ls "/foo/bar/${nanika_file}"

# Ignoring SC1091 warning for unresolved source path is acceptable.
# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_functions"

# Using $_AWS_ARGS without quotes to avoid SC2086. This is acceptable as $_AWS_ARGS may be an empty string or multiple space-separated arguments.
aws s3 ls foo_bucket $_AWS_ARGS

# Using $dryrun without quotes to avoid SC2086. This is acceptable as $dryrun may be an empty string or multiple space-separated arguments.
$dryrun aws s3 ls foo_bucket $_AWS_ARGS
```

**Discouraged**

```shell
# Detected as SC2006. Using `` for command substitution is prohibited by both style guides and shellcheck; please correct it.
foo=$(cmd ...)

# Detected as SC2086. Variables that may contain spaces, such as paths, should be enclosed in quotes to avoid warnings. Please correct it.
ls "/foo/bar/${nanika_file}"
```

## Command Substitution

> **Note** Google Shell Style Guide

* ✔️ DO: Use `$(command)` instead of backticks `` ` ` ``

Nested backticks require escaping with `\`, but the `$(command)` format maintains readability without needing changes when nested.

**Recommended**

```shell
var=$(command "$(command1)")
```

**Discouraged**

```shell
var=`command \`command1\``
```

## Test Expression

> **Note** Google Shell Style Guide

* ✔️ DO: Use `[[ ... ]]` instead of `[ ... ]`

`[[ ... ]]` is preferred over `[ ... ]`, `test`, and `/usr/bin/[`. The `[[ ... ]]` construct reduces errors as pathname expansion and word splitting do not occur between `[[` and `]]`. Additionally, `[[ ... ]]` supports regular expression matching, unlike `[ ... ]`.

Refer to [FAQ E14](http://tiswww.case.edu/php/chet/bash/FAQ) for issues caused by `[]`.

**Recommended**

```shell
# This ensures the string on the left is made up of characters in
# the alnum character class followed by the string name.
# Note that the RHS should not be quoted here.
if [[ "filename" =~ ^[[:alnum:]]+name ]]; then
  echo "Match"
fi

# This matches the exact pattern "f*" (Does not match in this case)
if [[ "filename" == "f*" ]]; then
  echo "Match"
fi
```

**Discouraged**

```shell
# This gives a "too many arguments" error as f* is expanded to the
# contents of the current directory. It might also trigger the
# "unexpected operator" error because `[` does not support `==`, only `=`.
if [ "filename" == f* ]; then
  echo "Match"
fi
```

## Testing Strings

> **Note** Google Shell Style Guide

* ✔️ DO: Use `==` for string comparisons
* ✔️ DO: Use `(( ... ))` or `-lt` and `-gt` for numeric comparisons
* ⚠️ CONSIDER: Use `-z` instead of `== ""` for empty string comparisons
* ⚠️ CONSIDER: Avoid prefixing/suffixing fixed strings for whole string comparison in string comparisons
* ⚠️ CONSIDER: Be cautious when using `<` or `>` in string comparisons as they perform lexicographical comparisons
* ❌ DO NOT: Do not use `=` for string comparisons
* ❌ DO NOT: Do not use `>` or `<` for numeric comparisons

Bash handles empty strings efficiently with test. For code readability, use appropriate string checks. Avoid prefixing/suffixing fixed strings for whole string comparison in string comparisons.

**Recommended**

```shell
# Comparing strings
if [[ "${my_var}" == "some_string" ]]; then
  do_something
fi

# -z (string length is zero) and -n (string length is not zero) are
# preferred over testing for an empty string
if [[ -z "${my_var}" ]]; then
  do_something
fi

# This is OK (ensure quotes on the empty side), but not preferred:
if [[ "${my_var}" == "" ]]; then
  do_something
fi
```

**非推奨 (discouraged)**

```shell
# Avoid comparing the whole string with an additional string
if [[ "${my_var}X" == "some_stringX" ]]; then
  do_something
fi
```

To avoid confusion about what is being tested, explicitly use `-z` or `-n`.

**Recommended**

```shell
if [[ -n "${my_var}" ]]; then
  do_something
fi
```

**Discouraged**

```shell
if [[ "${my_var}" ]]; then
  do_something
fi
```

Use `==` for equality checks and avoid `=`. The former enforces the use of `[[`, while the latter can be confused with assignment. However, be cautious that `<` and `>` within `[[ ... ]]` perform lexicographical comparisons. For numeric comparisons, use `(( ... ))` or `-lt` and `-gt`.

**Recommended**

```shell
# Use ==
if [[ "${my_var}" == "val" ]]; then
  do_something
fi

# Use (())
if (( my_var > 3 )); then
  do_something
fi

# Use -gt or -lt for numeric comparisons
if [[ "${my_var}" -gt 3 ]]; then
  do_something
fi
```

**Discouraged**

```shell
# Do not use =
if [[ "${my_var}" = "val" ]]; then
  do_something
fi

# Likely unintended lexicographical comparison
if [[ "${my_var}" > 3 ]]; then
  # True if "4", false if "22"
  do_something
fi
```

## Wildcard Expansion of Filenames

> **Note** Google Shell Style Guide

* ✔️ DO: Use explicit paths when performing wildcard expansion of filenames
* ❌ DO NOT: Do not use `*` for wildcard expansion of filenames. Instead, use `./*`

Filenames may start with `-`, so using `./*` for wildcard expansion is safer than using `*`.

```shell
# Here's the contents of the directory:
# -f  -r  somedir  somefile
```

**Recommended**

```shell
# Prevent the accidental removal of files starting with `-`
$ rm -v ./*
removed `./-f'
removed `./-r'
rm: cannot remove `./somedir': Is a directory
removed `./somefile'
```

**Discouraged**

```shell
# Incorrectly deletes almost everything in the directory by force
$ rm -v *
removed directory: `somedir'
removed `somefile'
```

## Evalの禁止 (Eval is Evil)

> **Note** Google Shell Style Guide

* ❌ DO NOT: Do not use `eval`

`eval` obscures input code when used for variable assignments, setting variables without allowing confirmation of what they are. `eval` poses a security risk and should be avoided.

**Discouraged**

```shell
# What does this set?
# Did it succeed? In part or whole?
eval $(set_my_variables)

# What happens if one of the returned values has a space in it?
variable="$(eval some_function)"
```

## 配列 (Arrays)

> **Note** Google Shell Style Guide

* ✔️ DO: Use arrays to store multiple elements
* ✔️ DO: Consider using loops for newline-separated string output. It's simpler than converting to an array
* ❌ DO NOT: Avoid storing multiple elements in a single string

Bash arrays are used to store lists of elements, avoiding the complexity of quoting. Arrays should not be used to facilitate more complex data structures. (See [いつシェルを使うか (When to use Shell)](#いつシェルを使うか-when-to-use-shell) above.)

Arrays store ordered collections of strings and are safely expanded to individual elements for commands and loops. Using a single string for multiple command arguments can lead to the use of `eval` or nested quotes within strings, which should be avoided.

**Recommended**

```shell
# An array is assigned using parentheses, and can be appended to
# with +=( … ).
declare -a flags
flags=(--foo --bar='baz')
flags+=(--greeting="Hello ${name}")
mybinary "${flags[@]}"
```

**Discouraged**

```shell
# Don’t use strings for sequences.
flags='--foo --bar=baz'
flags+=' --greeting="Hello world"'  # This won’t work as intended.
mybinary ${flags}
```

```shell
# Command expansions return single strings, not arrays. Avoid
# unquoted expansion in array assignments because it won’t
# work correctly if the command output contains special
# characters or whitespace.

# This expands the listing output into a string, then does special keyword
# expansion, and then whitespace splitting. Only then is it turned into a
# list of words. The ls command may also change behavior based on the user's
# active environment!
declare -a files=($(ls /directory))

# The get_arguments writes everything to STDOUT, but then goes through the
# same expansion process above before turning into a list of arguments.
mybinary $(get_arguments)
```

**Advantages of Arrays**

* Using arrays allows for creating lists without confusing quotes. On the other hand, without arrays, you might end up making incorrect attempts to nest quotes within strings
* Arrays enable safe storage of sequences/lists consisting of any string with spaces

**Disadvantages of Arrays**

* Using arrays can make the script more complex
* Additional processing is needed to convert newline-separated string output into arrays. Consider using loops directly instead of conversion

```shell
# Convert newline-separated string output to an array
IFS=$'\n' read -r -d '' -a files < <(ls /directory && printf '\0')
```

Arrays are used when safely creating or passing lists, especially to avoid issues with confusing quotes when constructing sets of command arguments. When accessing arrays, use quoted expansion `"${array[@]}"`. However, if more advanced data manipulation is required, consider avoiding shell scripting altogether.

## Pipes to While

> **Note** Google Style Guide

* ✔️ DO: Use process substitution or the `readarray` builtin (bash4+) to pipe into `while`
* ❌ DO NOT: Avoid piping into `while` using `|` as it may lead to hard-to-trace bugs

When piping into `while`, prioritize using process substitution or the `readarray` builtin (bash4+). Process substitution creates a subshell but allows redirection to `while` without placing `while` or other commands inside the subshell. On the other hand, piping creates a subshell, and variable changes within the pipeline do not propagate to the parent shell, potentially leading to obscure bugs that are difficult to track.

Alternatively, use the readarray builtin to read the file into an array, then loop over the array’s contents. Notice that (for the same reason as above) you need to use a process substitution with readarray rather than a pipe, but with the advantage that the input generation for the loop is located before it, rather than after.

**Recommended**

```shell
# readarray is most recommended
last_line='NULL'
readarray -t lines < <(ls)
for line in "${lines[@]}"; do
  if [[ -n "${line}" ]]; then
    last_line="${line}"
  fi
done

# This will output the last non-empty line from your_command
echo "${last_line}"
```

```shell
# Process substitution is also acceptable
last_line='NULL'
while read line; do
  if [[ -n "${line}" ]]; then
    last_line="${line}"
  fi
done < <(ls)

# This will output the last non-empty line from your_command
echo "${last_line}"
```

**Discouraged**

```shell
# Pipe won't pass variable changes to outside
last_line='NULL'
ls | while read -r line; do
  if [[ -n "${line}" ]]; then
    last_line="${line}"
  fi
done

# This will always output 'NULL'!
echo "${last_line}"
```

## For Loops

> **Note** Google Style Guide

* ✔️ DO: Use `for` loops to iterate over lists when you are certain there are no spaces
* ✔️ DO: When using `for` loops to iterate over lists, use `"${array[@]}"`. Ensure the variable is either an array or a newline-separated string

Care must be taken when iterating with `for` loops. `for var in $(...)` splits output by spaces, not by lines. This is safe if you are sure the output does not contain unexpected spaces, but `while read` loops or `readarray` may be safer and clearer if the situation is ambiguous. When iterating over a list with `for`, using `"${array[@]}"` ensures compliance with quoting conventions.

**Recommended**

```shell
# use array when iterating space-separated list. (You cannot iterate with string "foo bar piyo")
lines=(foo bar piyo)
for line in "${lines[@]}"; do
  echo "1 ${line}"
done

# use array when iterating line-separated output
lines=$(ls -l)
for line in "${lines[@]}"; do
  echo "1 ${line}"
done
```

**Discouraged**

```shell
# shellcheck warns you SC2206 for quoting this
lines="foo bar piyo"
for line in ${lines[@]}; do
  echo "1 ${line}"
done

# Won't work. Output is `1 foo bar piyo`
lines="foo bar piyo"
for line in "${lines[@]}"; do
  echo "1 ${line}"
done

# Space-included lines won't iterate correctly
for line in $(ls -l); do
  echo "1 ${line}"
done
```

## Arithmetic

> **Note** Google Style Guide

* ✔️ DO: Use `(( ... ))` or `$(( ... ))` for arithmetic operations
* ❌ DO NOT: Avoid using `$[]` syntax, `let`, or `expr` for arithmetic operations
* ⚠️ CONSIDER: Avoid using `(( ... ))` as a standalone statement. Instead, use it in conditional expressions like `if (( ... ))`
* ⚠️ CONSIDER: Inside `(( ... ))` or `$(( ... ))`, you can omit the `$` or `${}` when referring to variables, e.g., `i` instead of `$i`

The operators `<` and `>` do not perform numeric comparison within `[[ ... ]]` expressions but rather perform lexicographic comparison. (Refer to [Testing Strings](#testing-strings) for details). Therefore, prefer using `(( ... ))` for all arithmetic operations instead of `[[ ... ]]`.

Be cautious with `(( ... ))` as a standalone statement, as it might evaluate to zero and cause issues, especially with `set -e`. For example, `set -e; i=0; (( i++ ))` will terminate the shell. Despite this, arithmetic operations with the shell builtin `(( ... ))` are often faster than `expr`.

**Recommended**

```shell
# Simple calculation used as text - note the use of $(( … )) within a string.
echo "$(( 2 + 2 )) is 4"

# When performing arithmetic comparisons for testing
if (( a < b )); then
  …
fi

# Some calculation assigned to a variable.
(( i = 10 * j + 400 ))
```

**Discouraged**

```shell
# This form is non-portable and deprecated
i=$[2 * 10]

# Despite appearances, 'let' isn't one of the declarative keywords,
# so unquoted assignments are subject to globbing word splitting.
# For the sake of simplicity, avoid 'let' and use (( … ))
let i="2 + 2"

# The expr utility is an external program and not a shell builtin.
i=$( expr 4 + 4 )

# Quoting can be error-prone when using expr too.
i=$( expr 4 '*' 4 )

# Shell will terminate
set -e
i=0
(( i++ ))
```

`$(())`で変数を利用する場合、シェルが`var`を変数と認識するため、`${var}`や`$var`は不要です。`${...}`を省略することで読みやすくなるため推奨しますが、この規約は先述のクォート規約と反するため必須ではありません。

**Recommended**

```shell
# N.B.: Remember to declare your variables as integers when
# possible, and to prefer local variables over globals.
local -i hundred="$(( 10 * 10 ))"
declare -i five="$(( 10 / 2 ))"

# Increment the variable "i" by three.
# Note that:
#  - We do not write ${i} or $i.
#  - We put a space after the (( and before the )).
(( i += 3 ))

# To decrement the variable "i" by five:
(( i -= 5 ))

# Do some complicated computations.
# Note that normal arithmetic operator precedence is observed.
hr=2
min=5
sec=30
echo "$(( hr * 3600 + min * 60 + sec ))" # prints 7530 as expected
```

# Calling Commands

## Checking Return Values

> **Note** Google Style Guide

* ✔️ DO: Always check return values and provide useful return values
* ✔️ DO: When handling command success or failure, directly check with `if` statements
* ❌ DO NOT: Avoid checking return values with `$?` or `PIPESTATUS` variables, as `set -euo pipefail` is assumed

**Recommended**

```shell
# It's okay if the command fails within the if statement
if ! mv "${file_list[@]}" "${dest_dir}/"; then
  echo "Unable to move ${file_list[*]} to ${dest_dir}" >&2
  exit 1
fi
```

**Discouraged**

```shell
# With set -euo pipefail, the script will exit if mv fails
mv "${file_list[@]}" "${dest_dir}/"
if (( $? != 0 )); then
  echo "Unable to move ${file_list[*]} to ${dest_dir}" >&2
  exit 1
fi

# With set -euo pipefail, do not use PIPESTATUS. Use it to check errors in the entire pipeline.
tar -cf - ./* | (cd "${dir}" && tar -xf -)
if (( PIPESTATUS[0] != 0 || PIPESTATUS[1] != 0 )); then
  echo "Unable to tar files to ${dir}" >&2
fi
```

## Error Handling

> **Note** Based on icy/bash-coding-style

* ✔️ DO: Handle errors that occur within a function inside that function. Avoid error handling at the caller level

Avoid handling errors from other functions at the caller level. If an error occurs within a function, handle it within that function. Use the `common::error` function to display error messages and end the function with `return 1`.

**Recommended**

```shell
_foobar_call() {
  # do something

  if [[ $? -ge 1 ]]; then
    _error "${FUNCNAME[0]} has some internal error"
  fi
}

_my_def() {
  _foobar_call || return 1
}
```

**Discouraged**

```shell
_my_def() {
  _foobar_call

  if [[ $? -ge 1 ]]; then
    echo >&2 "_foobar_call has some error"
    _error "_foobar_call has some error"
    return 1
  fi
}
```

## Builtin Commands vs. External Commands

> **Note** Google Style Guide

* ✔️ DO: Choose builtins over external commands when given the choice between a shell builtin call and an external process call
* ❌ DO NOT: Avoid sticking to builtins if using external commands like `sed` simplifies the task despite complex variable expansions in bash

Shell builtins are generally more robust and portable compared to external commands (e.g., `sed` varies between BSD and GNU), so using builtins like those in bash (e.g., variable expansions) is appropriate. However, if using external commands is simpler and more standard, there is no need to stick to builtins. Overly complex variable expansions can make the code harder for others to understand.

**Recommended**

```shell
addition=$(( X + Y ))
substitution="${string/#foo/bar}"
```

**Discouraged**

```shell
addition="$(expr "${X}" + "${Y}")"
substitution="$(echo "${string}" | sed -e 's/^foo/bar/')"
```

# Script Stabilization

Following style guides alone cannot guarantee script stabilization. Here are some best practices for stabilizing scripts.


## Writing Rerunnable Scripts

> **Note** Custom Guidelines

* ✔️ DO: Ensure that running the script with the same arguments yields the same results

Writing idempotent code is important. Idempotency means that running the script multiple times will yield the same result, allowing you to continue processing from where it left off if the script fails midway. By focusing on idempotency, you create more reliable and maintainable scripts.

**Recommended**

```shell
# This script is idempotent
file_name="foo_bar/per_run_unique_$(date +%s)"
mkdir -p "$(dirname "${file_name}")"
if [[ ! -f "${file_name}" ]]; then
  # Content is initialized and appended regardless of whether the file exists or not
  echo "nanika" > "${file_name}"
  echo "okonomiyaki" >> "${file_name}"
  echo "takoyaki" >> "${file_name}"
fi

# kubectl apply is an idempotent command and should be used
kubectl apply -f ./manifest.yaml
```

**Discouraged**

```shell
# The existence of the directory on the first run does not guarantee its presence in subsequent runs
file_name="foo_bar/per_run_unique_$(date +%s)"
if [[ ! -f "${file_name}" ]]; then
  # Appending to an existing file will not yield the same result
  echo "nanika" >> "${file_name}"
  echo "okonomiyaki" >> "${file_name}"
  echo "takoyaki" >> "${file_name}"
fi

# kubectl create is not idempotent and will result in an error if the resource already exists
kubectl create nanika
```

## Check State Before Changing

> **Note** Custom Guidelines

* ✔️ DO: Check the state before making changes to ensure that the intended command is executed

When performing operations that modify the system state, checking whether the desired state is already achieved helps avoid unnecessary processing and prevent errors.

**Recommended**

```shell
# Check if the variable is empty before proceeding
if [[ "${kubemanifest}" == "" ]]; then
  common::error "kubernetes manifest not generated. exit script."
  exit 1
fi

echo "${kubemanifest}" | kubectl apply -f -
```

**Discouraged**

```shell
# Performing operations without any checks. If kubemanifest is empty, it will lead to unintended results
echo "${kubemanifest}" | kubectl apply -f -
```

## Safely Creating Temporary Files

> **Note** Custom Guidelines

* ✔️ DO: Use `mktemp` to create temporary files safely
* ⚠️ CONSIDER: Use `trap` to ensure that temporary files are deleted when the script exits

Using `mktemp` ensures that temporary files are created safely, and `trap` can be used to ensure they are deleted when the script exits.

**Recommended**

```shell
# Create a temporary file safely using mktemp
temp_file=$(mktemp)

# Delete the temporary file on script exit
trap 'rm -f "$temp_file"' EXIT

# Perform operations using the temporary file safely
```

**Discouraged**

```shell
# Creating temporary files with custom rules can be prone to duplication issues
temp_file=$(/tmp/foobar_$(date +%s))

# Perform operations using the temporary file here

# There is a risk of missing file deletion
rm "${temp_file}"
```
