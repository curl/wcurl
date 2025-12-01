---
c: Copyright (C) Samuel Henrique <samueloph@debian.org>, Sergio Durigan Junior <sergiodj@debian.org> and many contributors, see the AUTHORS file.
SPDX-License-Identifier: curl
Title: wcurl
Section: 1
Source: wcurl
See-also:
  - curl (1)
  - trurl (1)
Added-in: n/a
---

# NAME

**wcurl** - a simple wrapper around curl to easily download files.

# SYNOPSIS

**wcurl \<URL\>...**

**wcurl [--curl-options \<CURL_OPTIONS\>]... [--dry-run] [--no-decode-filename] [-o|-O|--output \<PATH\>] [--] \<URL\>...**

**wcurl [--curl-options=\<CURL_OPTIONS\>]... [--dry-run] [--no-decode-filename] [--output=\<PATH\>] [--] \<URL\>...**

**wcurl [--save-call=\<NAME\>:\<CURL_OPTIONS\>]... [--list-save] [--rm-save=\<NAME\>]**

**wcurl [-r|--run-save=\<NAME\>] \<URL\>...**

**wcurl -V|--version**

**wcurl -h|--help**

# DESCRIPTION

**wcurl** is a simple curl wrapper which lets you use curl to download files
without having to remember any parameters.

Simply call **wcurl** with a list of URLs you want to download and **wcurl**
picks sane defaults.

If you need anything more complex, you can provide any of curl's supported
parameters via the **--curl-options** option. Just beware that you likely
should be using curl directly if your use case is not covered.

By default, **wcurl** does:

## * Percent-encode whitespace in URLs;

## * Download multiple URLs in parallel
    if the installed curl's version is \>= 7.66.0 (--parallel);

## * Use a total number of 5 parallel connections to the same protocol + hostname + port number target
    if the installed curl's version is \>= 8.16.0 (--parallel-max-host);

## * Follow redirects;

## * Automatically choose a filename as output;

## * Avoid overwriting files
    if the installed curl's version is \>= 7.83.0 (--no-clobber);

## * Perform retries;

## * Set the downloaded file timestamp
    to the value provided by the server, if available;

## * Default to https
    if the URL does not contain any scheme;

## * Disable curl's URL globbing parser
    so {} and [] characters in URLs are not treated specially;

## * Percent-decode the resulting filename;

## * Use 'index.html' as the default filename
    if there is none in the URL.

# OPTIONS

## --curl-options, --curl-options=\<CURL_OPTIONS\>...

Specify extra options to be passed when invoking curl. May be specified more
than once.

## -o, -O, --output, --output=\<PATH\>

Use the provided output path instead of getting it from the URL. If multiple
URLs are provided, resulting files share the same name with a number appended to
the end (curl \>= 7.83.0). If this option is provided multiple times, only the
last value is considered.

## --no-decode-filename

Do not percent-decode the output filename, even if the percent-encoding in the
URL was done by **wcurl**, e.g.: The URL contained whitespace.

## --dry-run

Do not actually execute curl, just print what would be invoked.

## --save-call=\<NAME\>:\<CURL_OPTIONS\>...

Save a curl call to `$HOME/.wcurlrc` without having to remember option
combinations, using a property value set; where the value is the set of options
to be reused, and the property is the name to invoke the saved option combo.
The name must contain only alphanumeric characters, dashes, and underscores for
security reasons. Supports parameter expansion using `!1`, `!2`, `!3`, etc. as
placeholders that will be replaced with actual values when invoked with **-r**
or **--run-save**. When using parameter expansion markers, enclose the curl
options in single quotes to prevent shell interpretation. The `.wcurlrc` file is
created with permissions 600 (owner read/write only) for security.


## -r, --run-save, --run-save=\<NAME\>

Run a saved curl call from `$HOME/.wcurlrc`. For saved calls without parameter
expansion, the saved options are applied to the URLs provided. For saved calls
with parameter expansion markers (`!1`, `!2`, `!3`, etc.), you must provide the
exact number of parameters required by the highest marker number. When using
parameter expansion, only one **--run-save** call can be used per command, and
the command executes curl directly with the expanded options. Parameters are
provided as separate arguments following the **--run-save** option.

## --list-save

Output the name and the option combination for each name from `$HOME/.wcurlrc`
that have been saved for later reuse.

## --rm-save=\<NAME\>

Remove a saved curl call.

## -V, \--version

Print version information.

## -h, \--help

Print help message.

# CURL_OPTIONS

Any option supported by curl can be set here. This is not used by **wcurl**; it
is instead forwarded to the curl invocation.

# URL

URL to be downloaded. Anything that is not a parameter is considered
an URL. Whitespace is percent-encoded and the URL is passed to curl, which
then performs the parsing. May be specified more than once.

# EXAMPLES

Download a single file:

**wcurl example.com/filename.txt**

Download two files in parallel:

**wcurl example.com/filename1.txt example.com/filename2.txt**

Download a file passing the **--progress-bar** and **--http2** flags to curl:

**wcurl --curl-options="--progress-bar --http2" example.com/filename.txt**

* Resume from an interrupted download. The options necessary to resume the download (`--clobber --continue-at -`) must be the **last** options specified in `--curl-options`. Note that the only way to resume interrupted downloads is to allow wcurl to overwrite the destination file:

**wcurl --curl-options="--clobber --continue-at -" example.com/filename.txt**

Download multiple files without a limit of concurrent connections per host (the default limit is 5):

**wcurl --curl-options="--parallel-max-host 0" example.com/filename1.txt example.com/filename2.txt**

Save simple curl option combinations to be reused later:

**wcurl --save-call=quiet:"--silent --show-error" --save-call=progress:"--progress-bar -L -v"**

Save a curl option combination with parameter expansion (use !1, !2, !3 for placeholders, and enclose in single quotes):

**wcurl --save-call=dumpVerb:'-I !1 -o !2 --next -v !3 -o !4'**

**wcurl --save-call=getFile:'-o !1 !2'**

List all saved curl option combinations:

**wcurl --list-save**

Remove a saved curl option combination:

**wcurl --rm-save=quiet**

Use a saved curl option combination without parameter expansion:

**wcurl --run-save="quiet" example.com/file1.txt**

**wcurl -r="progress" example.com/file1.txt example.com/file2.txt**

Use a saved curl option combination with parameter expansion. The number of parameters after the name must match the highest marker (!1, !2, etc.):

**wcurl --run-save="dumpVerb" example.com dump.txt example.com/file.txt file.txt**

This expands to: `curl -I example.com -o dump.txt --next -v example.com/file.txt -o file.txt`

**wcurl -r="getFile" output.html example.com/index.html**

This expands to: `curl -o output.html example.com/index.html`

# AUTHORS

    Samuel Henrique \<samueloph@debian.org\>
    Sergio Durigan Junior \<sergiodj@debian.org\>
    and many contributors, see the AUTHORS file.

# REPORTING BUGS

If you experience any problems with **wcurl** that you do not experience with
curl, submit an issue on GitHub: https://github.com/curl/wcurl

# COPYRIGHT

**wcurl** is licensed under the curl license
