<!--
Copyright (C) Samuel Henrique <samueloph@debian.org>, Sergio Durigan
Junior <sergiodj@debian.org> and many contributors, see the AUTHORS
file.

SPDX-License-Identifier: curl
-->

# [![wcurl logo](https://curl.se/logo/wcurl-logo.svg)](https://curl.se/wcurl)

# Install wcurl

First check if your distro/OS vendor ships `wcurl` as part of their official
repositories, `wcurl` might be shipped as part of the `curl` package.

If they don't ship it, consider making a request for it.

You can always install wcurl by simply downloading the script:

```console
curl -fLO https://github.com/curl/wcurl/releases/latest/download/wcurl
chmod +x wcurl
```

# Install wcurl's manpage
```console
curl -fLO https://github.com/curl/wcurl/releases/latest/download/wcurl.1
sudo mv wcurl.1 /usr/share/man/man1/wcurl.1
```

# wcurl(1)

**wcurl**
- a simple wrapper around curl to easily download files.

# Synopsis

    wcurl <URL>...
    wcurl [--curl-options <CURL_OPTIONS>]... [--no-decode-filename] [-o|-O|--output <PATH>] [--dry-run] [--] <URL>...
    wcurl [--curl-options=<CURL_OPTIONS>]... [--no-decode-filename] [--output=<PATH>] [--dry-run] [--] <URL>...
    wcurl -V|--version
    wcurl -h|--help

# Description

**wcurl** is a simple curl wrapper which lets you use curl to download files
without having to remember any parameters.

Simply call **wcurl** with a list of URLs you want to download and **wcurl** will pick
sane defaults.

If you need anything more complex, you can provide any of curl's supported
parameters via the `--curl-options` option. Just beware that you likely
should be using curl directly if your use case is not covered.


* By default, **wcurl** will:
  * Percent-encode whitespaces in URLs;
  * Download multiple URLs in parallel if the installed curl's version is >= 7.66.0;
  * Follow redirects;
  * Automatically choose a filename as output;
  * Avoid overwriting files if the installed curl's version is >= 7.83.0 (`--no-clobber`);
  * Perform retries;
  * Set the downloaded file timestamp to the value provided by the server, if available;
  * Disable **curl**'s URL globbing parser so `{}` and `[]` characters in URLs are not treated specially;
  * Percent-decode the resulting filename;
  * Use "index.html" as default filename if there's none in the URL.

# Options

* `--curl-options, curl-options=<CURL_OPTIONS>`...

  Specify extra options to be passed when invoking curl. May be specified more than once.

* `-o, -O, --output, --output=<PATH>`

  Use the provided output path instead of getting it from the URL. If multiple
  URLs are provided, all files will have the same name with a number appended to
  the end (curl >= 7.83.0). If this option is provided multiple times, only the
  last value is considered.

* `--no-decode-filename`

  Don't percent-decode the output filename, even if the percent-encoding in the
  URL was done by wcurl, e.g.: The URL contained whitespaces.

* `--dry-run`

  Don't actually execute curl, just print what would be invoked.

* `-V, --version`

  Print version information.

* `-h, --help`

  Print help message.

# Url

Anything which is not a parameter will be considered an URL.
**wcurl** will percent-encode whitespaces and pass that to curl, which will perform the
parsing of the URL.

# Examples

* Download a single file:

  `wcurl example.com/filename.txt`

* Download two files in parallel:

  `wcurl example.com/filename1.txt example.com/filename2.txt`

* Download a file passing the _--progress-bar_ and _--http2_ flags to curl:

  `wcurl --curl-options="--progress-bar --http2" example.com/filename.txt`

* Resume from an interrupted download (if more options are used, this needs to be the last one in the list):

  `wcurl --curl-options="--continue-at -" example.com/filename.txt`

# Running the testsuite

If you would like to run the tests, you will first need to install the
`shunit2` package.  On Debian-like and Fedora-like systems, the
package is called `shunit2`.

After that, you can run the testsuite by simply invoking the test
script:

```sh
./tests/tests.sh
```

# Lint

To lint the shell scripts, you need to install `shellcheck` and `checkbashisms`. Those tools will check the scripts for issues and ensure they follow best practices.

- On Debian-like systems: `apt install shellcheck devscripts`
- On Fedora-like systems: `dnf install shellcheck devscripts`

After installation, you can run `shellcheck` and `checkbashisms` by executing the following commands:

```sh
shellcheck wcurl ./tests/*

checkbashisms wcurl ./tests/*
```

# Authors

Samuel Henrique &lt;[samueloph@debian.org](mailto:samueloph@debian.org)&gt;  
Sergio Durigan Junior &lt;[sergiodj@debian.org](mailto:sergiodj@debian.org)&gt;  
and many contributors, see the AUTHORS file.

# Reporting Bugs

If you experience any problems with **wcurl** that you do not experience with curl,
submit an issue [here](https://github.com/curl/wcurl/issues).

# Copyright

**wcurl** is licensed under the curl license

# See Also

**curl**(1)
