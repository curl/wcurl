<!--
Copyright (C) Samuel Henrique <samueloph@debian.org>, Sergio Durigan
Junior <sergiodj@debian.org> and many contributors, see the AUTHORS
file.

SPDX-License-Identifier: curl
-->

# Changelog

## [UNRELEASED]
 * Default to index.html as filename if non can be parsed from the URL.
 * Percent-decode output filenames by default.
 * New option to disable percent-decoding of output filenames: --no-decode-filename.
 * wcurl.1: Fix typo on list of features.
 * README/manpage: point to the curl issue tracker.
 * README:
   - Add a missing dash to the --dry-run command.
   - Add a logo.
   - Add brief section explaining about our testsuite.
   - Remove HTML <a name> anchors.
 * Symlink LICENSE to LICENSES/curl.txt.

## [v2024.07.10]
 * Change versioning to use dots as separators instead of dashes:
     - Previous version: 2024-07-07
     - New version: 2024.07.10
 * Support older curl releases, minimum required version is now 7.46.0:
     - Only set --no-clobber if curl is 7.83 or newer
     - Only set --parallel if curl is 7.66 or newer
 * Set --fail on curl, in order to return errors instead of saving as
   output files.
 * Add more tests.
 * Remove the need for GNU coreutils' realpath for tests.
 * wcurl.1: Update manpage with links to Github and Debian's Salsa.
 * Update LICENSE file with new contributors.

## [v2024-07-07]
 * Drop getotp usage, non-linux environments are supported now.
 * Replace "-o/--opts=" parameters with "--curl-options/--curl-options=".
   This alternative is more descriptive and it does not coincide with any of curl's parameters.
 * Stop auto-resuming downloads and don't overwrite files instead by default.
   Safer alternative as otherwise curl can corrupt a file if the name clashes and the size of the existing one is smaller.
   One can easily change that behavior with '--curl-options="--continue-at -'.
 * New --dry-run option: just print what would be invoked.
 * Choose https as a default protocol, in case there's none in the URL.
 * Disable curl's URL globbing parser so {} and [] characters in URLs are not treated specially.
 * Implement support for '--'.
 * Implement a -V and --version options.
 * Basic testsuite implemented.
 * Update manpage, README and help output.

## [v2024-07-02]
 * First release to be shipped on Debian.

## [v2024-06-26]
 * Second release.

## [v2024-05-14]
 * First release.
