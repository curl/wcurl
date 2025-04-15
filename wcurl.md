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

wcurl - download URLs

# SYNOPSIS

**wcurl [options / URLs]**

# DESCRIPTION

**wcurl** is a simple curl wrapper which lets you use curl to download files
without having to remember any parameters.

Simply call **wcurl** with a list of URLs you want to download and **wcurl**
picks sane defaults.

If you need anything more complex, you can provide any of curl's supported
parameters via the **--curl-options** option. Just beware that you likely
should be using curl directly if your use case is not covered.

By default, **wcurl** does:

## Encode whitespaces in URLs

## Download multiple URLs in parallel
if the installed curl's version is \>= 7.66.0

## Follow redirects

## Automatically choose a filename as output

## Avoid overwriting files
if the installed curl's version is \>= 7.83.0 (**--no-clobber**)

## Perform retries

## Set the downloaded file timestamp
to the value provided by the server, if available

## Default to https
if the URL does not contain any scheme

## Disable curl's URL globbing parser
so **{}** and **\[\]** characters in URLs are not treated specially.

# OPTIONS

## --curl-options=\<CURL_OPTIONS\>

Specify extra options to be passed when invoking curl. May be specified more
than once.

## --dry-run

Do not actually execute curl, just print what would be invoked.

## -V, \--version

Print version information.

## -h, \--help

Print help message.

# CURL_OPTIONS

Any option supported by curl can be set here. This is not used by **wcurl** it
is instead forwarded to the curl invocation.

# URL

Anything which is not a parameter is considered an URL. **wcurl** encodes
whitespaces and pass that to curl, which performs the parsing of the URL.

# EXAMPLES

Download a single file:\

    wcurl example.com/filename.txt

Download two files in parallel:

    wcurl example.com/filename1.txt example.com/filename2.txt

Download a file passing the **--progress-bar** and **--http2** flags to curl:

    wcurl --curl-options="--progress-bar --http2" example.com/filename.txt

Resume from an interrupted download (if more options are used, this needs to
be the last one in the list):

    wcurl --curl-options="--continue-at -" example.com/filename.txt

# AUTHORS

- Samuel Henrique \<samueloph@debian.org\>
- Sergio durigan junior \<sergiodj@debian.org\>
- Ryan Carsten Schmidt \<git@ryandesign.com\>
- Ben Zanin

# REPORTING BUGS

If you experience any problems with **wcurl** that you do not experience with
curl, submit an issue on Github: https://github.com/curl/wcurl

# COPYRIGHT

**wcurl** is licensed under the curl license

# SEE ALSO

**curl**(1)
