#!/bin/sh

# wcurl - a simple wrapper around curl to easily download files.
#
# This is wcurl's testsuite.
#
# Copyright (C) Sergio Durigan Junior, <sergiodj@debian.org>
#
# Permission to use, copy, modify, and distribute this software for any purpose
# with or without fee is hereby granted, provided that the above copyright
# notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD PARTY RIGHTS. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
# OR OTHER DEALINGS IN THE SOFTWARE.
#
# Except as contained in this notice, the name of a copyright holder shall not be
# used in advertising or otherwise to promote the sale, use or other dealings in
# this Software without prior written authorization of the copyright holder.
#
# SPDX-License-Identifier: curl

readonly ROOTDIR=$(realpath -e "$(dirname "$0")/../")
export PATH="${ROOTDIR}:${PATH}"

readonly CURL_NAME="curl"
readonly WCURL_CMD="wcurl --dry-run "

debug()
{
    if [ -n "${DEBUG}" ]; then
        printf "D: %s\n" "$*"
    fi
}

testUsage()
{
    ret=$(${WCURL_CMD} --help)
    assertTrue "Verify whether '--help' option exits successfully" "$?"

    debug "Verifying: '${ret}'"
    printf "%s\n" "${ret}" | grep -qF "wcurl -- a simple wrapper around curl to easily download files"
    assertTrue "Verify whether the usage command works" "$?"
}

testNoOptionError()
{
    ret=$(${WCURL_CMD} 2>&1)
    assertFalse "Verify whether 'wcurl' without options exits with an error" "$?"
    assertEquals "Verify whether 'wcurl' without options displays an error message" "${ret}" "You must provide at least one URL to download."
}

testInvalidOptionError()
{
    invalidoption="--frobnicator"
    ret=$(${WCURL_CMD} ${invalidoption} 2>&1)
    assertFalse "Verify whether 'wcurl' with an invalid option exits with an error" "$?"
    assertEquals "Verify whether 'wcurl' with an invalid option displays an error message" "${ret}" "Unknown option: '${invalidoption}'."
}

## Ideas for tests:
##
## - URL with whitespace
## - Different encodes don't get messed up
## - Test '--' (with and without)
## - Test filename output (URL ending/not ending with slash)
## - Filename with whitespace (decoding)
## - --parallel when more than 1 URL is provided
## - --opts, -o, --opts=...
## - Options are the same for all URLs (except --next)
## - URLs beginning with '-' (with and without using '--')

. shunit2
