<!--
Copyright (C) Samuel Henrique <samueloph@debian.org>, Sergio Durigan
Junior <sergiodj@debian.org> and many contributors, see the AUTHORS
file.

SPDX-License-Identifier: curl
-->

# Changelog

## [UNRELEASED]

## [v2025.11.04]
 * Fix CVE-2025-11563: Don't percent-decode `/` and `\` in output file name to
   avoid path traversal.
 * Fix typos reported by pyspelling.
 * Multiple improvements to GitHub Actions.

## [v2025.09.27]
 * Set `parallel-max-host` to 5 if curl>=8.16.0.
 * Fix example for `--continue-at`.
 * Consistent variable names for feature checks.
 * Set `CURL_OPTIONS` right before the URL, allowing override of output file name.
 * Apply `shfmt` in all shellscript files.
 * Minor Markdown tweaks in README.md.
 * Update installation instructions.
 * Fix typos.
 * Update AUTHORS.

## [v2025.05.26]
 * Increase number of retries to 5 (32 sec total time), fixing the problem with
   misleading output. Previously, it was showing a higher number of retries
   than what would be done and it always did only 3.

## [v2025.04.20]
 * Update manpage, help output, README and comments, fixing typos and
   standardizing to curl's documentation format.

## [v2025.02.24]
 * Allow `-o` and `-O` to be used without whitespace (e.g.: `-oNAME`).
 * Fix capitalization of the name of copyright owner sergiodj.
 * Use the standard copyright header in manpage.
 * Create a GitHub workflow for tests and linting.
 * Add missing breakline to README to fix formatting.
 * Update manpage to describe that `--output` can be used without the equal sign.
 * Add installation instructions to README.
 * Fix punctuation in the list of features.
 * Throw an error message on tests if shunit's version is lower than 2.1.8.
 * Update AUTHORS.

## [v2024.12.08]
 * New parameter `-o|-O|--output|output=` which allows the user to choose the output filename.
 * Default to `index.html` as filename if none can be inferred from the URL.
 * Percent-decode output filenames by default.
 * New option to disable percent-decoding of output filenames: `--no-decode-filename`.
 * Fix typo in the list of features of the manpage.
 * README/manpage: Point to the curl issue tracker.
 * README:
   - Add a missing dash to the `--dry-run` command.
   - Add a logo.
   - Add a brief section explaining about our testsuite.
   - Remove HTML `<a name>` anchors.
 * Symlink LICENSE to LICENSES/curl.txt.
 * Update AUTHORS.

## [v2024.07.10]
 * Change versioning to use dots as separators instead of dashes:
     - Previous version: `2024-07-07`.
     - New version: `2024.07.10`.
 * Support older curl releases, minimum required version is now 7.46.0:
     - Only set `--no-clobber` if curl is 7.83 or newer.
     - Only set `--parallel` if curl is 7.66 or newer.
 * Set `--fail` when invoking curl, in order to display possible errors instead of saving them as
   output files.
 * Add more tests.
 * Remove the need for GNU coreutils' `realpath` for tests.
 * Update manpage with links to GitHub and Debian's Salsa.
 * Update LICENSE file with new contributors.

## [v2024-07-07]
 * Drop `getopt` usage, non-GNU/Linux environments are supported now.
 * Replace `-o`/`--opts=` parameters with `--curl-options`/`--curl-options=`.
   This alternative is more descriptive and it does not coincide with any of curl's parameters.
 * Stop auto-resuming downloads and don't overwrite files instead by default.
   Safer alternative as otherwise curl can corrupt a file if the name clashes and the size of the existing one is smaller.
   One can easily change that behavior with `--curl-options="--continue-at -"`.
 * New `--dry-run` option: just print what would be invoked.
 * Choose HTTPS as a default protocol, in case there's none in the URL.
 * Disable curl's URL globbing parser so `{}` and `[]` characters in URLs are not treated specially.
 * Implement support for `--`.
 * Implement `-V`/`--version` options.
 * Basic testsuite implemented.
 * Update manpage, README and help output.

## [v2024-07-02]
 * First "public" release, announcing the project.
 * Use `exec` instead of `eval`.
 * Only set `--parallel` if there's more than one URL.
 * Fix manpage typo.
 * Update COPYRIGHT and AUTHORS in manpage.
 * Rewrite wcurl to remove bash dependency, it's now a POSIX shell script.
 * Add README.md.
 * Add LICENSE.

## [v2024-06-26]
 * Simplify `--help` output.
 * Download multiple URLs in parallel.
 * Use remote timestamp for output file.
 * Update REPORTING BUGS section of the manpage.

## [v2024-05-14]
 * First release.
