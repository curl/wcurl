#!/bin/sh

# wcurl - a simple wrapper around curl to easily download files.
#
# This is wcurl's testsuite.
#
# Copyright (C) Sergio Durigan Junior, <sergiodj@debian.org>
# Copyright (C) Guilherme Puida Moreira, <guilherme@puida.xyz>
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

REALPATH_CMD="realpath"
if command -v grealpath >/dev/null; then
    REALPATH_CMD="grealpath"
fi

ROOTDIR="$(${REALPATH_CMD} -e "$(dirname "$0")/../")"
readonly ROOTDIR

export PATH="${ROOTDIR}:${PATH}"

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

testParallelIfMoreThanOneUrl()
{
    urls='example.com/1 example.com/2'
    ret=$(${WCURL_CMD} ${urls})
    assertContains "Verify whether 'wcurl' uses '--parallel' if more than one url is provided" "${ret}" '--parallel'
}

testEncodingWhitespace()
{
    url='example.com/white space'
    ret=$(${WCURL_CMD} "${url}")
    assertContains "Verify 'wcurl' encodes spaces in URLs as '%20'" "${ret}" 'example.com/white%20space'
}

testDoubleDash()
{
    params='example.com --curl-options=abc'
    ret=$(${WCURL_CMD} -- ${params})
    assertTrue "Verify whether 'wcurl' accepts '--' without erroring" "$?"
    assertContains "Verify whether 'wcurl' considers everywhing after '--' a url" "${ret}" '--curl-options=abc'
}

testCurlOptions()
{
    params='example.com --curl-options=--foo --curl-options --bar'
    ret=$(${WCURL_CMD} ${params})
    assertTrue "Verify 'wcurl' accepts '--curl-options' with and without trailing '='" "$?"
    assertContains "Verify 'wcurl' correctly passes through --curl-options=<option>" "${ret}" '--foo'
    assertContains "Verify 'wcurl' correctly passes through --curl-options <option>" "${ret}" '--bar'
}

testNextAmount()
{
    urls='example.com/1 example.com/2 example.com3'
    ret=$(${WCURL_CMD} ${urls})
    next_count=$(printf '%s' "${ret}" | grep -c -- --next)
    assertEquals "Verify whether 'wcurl' includes '--next' for every url besides the first" "${next_count}" "2"
}

testUrlStartingWithDash()
{
    url='-example.com'
    ret=$(${WCURL_CMD} ${url} 2>&1)
    assertFalse "Verify wether 'wcurl' considers an URL starting with '-' as an option" "$?"
    assertEquals "${ret}" "Unknown option: '-example.com'."
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
