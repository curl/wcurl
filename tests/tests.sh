#!/bin/sh

# wcurl - a simple wrapper around curl to easily download files.
#
# This is wcurl's testsuite.
#
# Copyright (C) Samuel Henrique <samueloph@debian.org>, Sergio Durigan
# Junior <sergiodj@debian.org> and many contributors, see the AUTHORS
# file.
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

ROOTDIR=$(CDPATH=$(cd -- "$(dirname -- "$0")/.." && pwd))
readonly ROOTDIR
export PATH="${ROOTDIR}:${PATH}"

readonly WCURL_CMD="wcurl --dry-run "

oneTimeSetUp()
{
    if ! assertContains "Check compatibility" "test" "test"; then
        echo "Error: shunit2 version 2.1.8 or higher is required."
        echo "Please install a compatible version of shunit2."
        exit 1
    fi
}

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
    # TODO: This test is wrong for curl 7.65 or older, since --parallel was only introduced in 7.66.
    #       We should check curl's version and skip this test instead.
    url_1='example.com/1'
    url_2='example.com/2'
    ret=$(${WCURL_CMD} ${url_1} ${url_2})
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
    ret=$(${WCURL_CMD} -- "${params}")
    assertTrue "Verify whether 'wcurl' accepts '--' without erroring" "$?"
    assertContains "Verify whether 'wcurl' considers everywhing after '--' a url" "${ret}" '--curl-options=abc'
}

testCurlOptions()
{
    params='example.com --curl-options=--foo --curl-options --bar'
    ret=$(${WCURL_CMD} "${params}")
    assertTrue "Verify 'wcurl' accepts '--curl-options' with and without trailing '='" "$?"
    assertContains "Verify 'wcurl' correctly passes through --curl-options=<option>" "${ret}" '--foo'
    assertContains "Verify 'wcurl' correctly passes through --curl-options <option>" "${ret}" '--bar'
}

testNextAmount()
{
    url_1='example.com/1'
    url_2='example.com/2'
    url_3='example.com3'
    ret=$(${WCURL_CMD} ${url_1} ${url_2} ${url_3})
    next_count=$(printf '%s' "${ret}" | grep -c -- --next)
    assertEquals "Verify whether 'wcurl' includes '--next' for every url besides the first" "${next_count}" "2"
}

testUrlStartingWithDash()
{
    url='-example.com'
    ret=$(${WCURL_CMD} ${url} 2>&1)
    assertFalse "Verify whether 'wcurl' considers an URL starting with '-' as an option" "$?"
    assertEquals "${ret}" "Unknown option: '-example.com'."
}

testOutputFileName()
{
    url='example.com'
    ret=$(${WCURL_CMD} -o "test filename" ${url} 2>&1)
    assertContains "Verify whether 'wcurl' correctly sets a custom output filename" "${ret}" '--output'
    assertContains "Verify whether 'wcurl' correctly sets a custom output filename" "${ret}" 'test filename'
}

testOutputFileNameWithoutSpaces()
{
    url='example.com'
    ret=$(${WCURL_CMD} -o"test filename" ${url} 2>&1)
    assertContains "Verify whether 'wcurl' correctly sets --output" "${ret}" '--output'
    assertContains "Verify whether 'wcurl' correctly sets --output with the correct filename" "${ret}" 'test filename'
}

testOutputFileNameRepeatedOption()
{
    url='example.com'
    ret=$(${WCURL_CMD} -o "test filename" -o "test filename2" ${url} 2>&1)
    assertContains "Verify whether 'wcurl' correctly sets a custom output filename" "${ret}" '--output'
    assertContains "Verify whether 'wcurl' correctly sets a custom output filename" "${ret}" 'test filename2'
}

testUrlDefaultName()
{
    url='example%20with%20spaces.com'
    ret=$(${WCURL_CMD} ${url} 2>&1)
    assertContains "Verify whether 'wcurl' chooses the correct default filename when there's no path in the URL" "${ret}" 'index.html'
}

testUrlDefaultNameTrailingSlash()
{
    url='example%20with%20spaces.com/'
    ret=$(${WCURL_CMD} ${url} 2>&1)
    assertContains "Verify whether 'wcurl' chooses the correct default filename when there's no path in the URL and the URl ends with a slash" "${ret}" 'index.html'
}

testUrlDecodingWhitespace()
{
    url='example.com/filename%20with%20spaces'
    ret=$(${WCURL_CMD} ${url} 2>&1)
    assertContains "Verify whether 'wcurl' successfully decodes percent-encoded whitespace in URLs" "${ret}" 'filename with spaces'
}

testUrlDecodingWhitespaceTwoFiles()
{
    url='example.com/filename%20with%20spaces'
    url_2='example.com/filename2%20with%20spaces'
    ret=$(${WCURL_CMD} ${url} ${url_2} 2>&1)
    assertContains "Verify whether 'wcurl' successfully decodes percent-encoded whitespace in URLs" "${ret}" 'filename with spaces'
    assertContains "Verify whether 'wcurl' successfully decodes percent-encoded whitespace in URLs" "${ret}" 'filename2 with spaces'
}

testUrlDecodingDisabled()
{
    url='example.com/filename%20with%20spaces'
    ret=$(${WCURL_CMD} --no-decode-filename ${url} 2>&1)
    assertContains "Verify whether 'wcurl' successfully decodes percent-encoded whitespace in URLs" "${ret}" 'filename%20with%20spaces'
}

testUrlDecodingWhitespaceQueryString()
{
    url='example.com/filename%20with%20spaces?query=string'
    ret=$(${WCURL_CMD} "${url}" 2>&1)
    assertContains "Verify whether 'wcurl' successfully decodes percent-encoded whitespace in URLs with query strings" "${ret}" 'filename with spaces'
}

testUrlDecodingWhitespaceTrailingSlash()
{
    url='example.com/filename%20with%20spaces/'
    ret=$(${WCURL_CMD} ${url} 2>&1)
    assertContains "Verify whether 'wcurl' successfully uses the default filename when the URL ends with a slash" "${ret}" 'index.html'
}

testUrlDecodingBackslashes()
{
    url='example.com/filename%5Cwith%2Fbackslashes%5c%2f'
    ret=$(${WCURL_CMD} ${url} 2>&1)
    assertContains "Verify whether 'wcurl' successfully uses the default filename when the URL ends with a slash" "${ret}" 'filename%5Cwith%2Fbackslashes%5c%2f'
}

# Test decoding a bunch of different languages (that don't use the latin
# alphabet), we could split each language on its own test, but for now it
# doesn't make a difference.
testUrlDecodingNonLatinLanguages()
{
    # Arabic
    url='example.com/%D8%AA%D8%B1%D9%85%D9%8A%D8%B2_%D8%A7%D9%84%D9%86%D8%B3%D8%A8%D8%A9_%D8%A7%D9%84%D9%85%D8%A6%D9%88%D9%8A%D8%A9'
    ret=$(${WCURL_CMD} ${url} 2>&1)
    assertContains "Verify whether 'wcurl' successfully decodes percent-encoded Arabic in URLs" "${ret}" 'ترميز_النسبة_المئوية'

    # Persian
    url='example.com/%DA%A9%D8%AF%D8%A8%D9%86%D8%AF%DB%8C_%D8%AF%D8%B1%D8%B5%D8%AF%DB%8C'
    ret=$(${WCURL_CMD} ${url} 2>&1)
    assertContains "Verify whether 'wcurl' successfully decodes percent-encoded Persian in URLs" "${ret}" 'کدبندی_درصدی'

    # Japanese
    url='example.com/%E3%83%91%E3%83%BC%E3%82%BB%E3%83%B3%E3%83%88%E3%82%A8%E3%83%B3%E3%82%B3%E3%83%BC%E3%83%87%E3%82%A3%E3%83%B3%E3%82%B0'
    ret=$(${WCURL_CMD} ${url} 2>&1)
    assertContains "Verify whether 'wcurl' successfully decodes percent-encoded Japanese in URLs" "${ret}" 'パーセントエンコーディング'

    # Korean
    url='example.com/%ED%8D%BC%EC%84%BC%ED%8A%B8_%EC%9D%B8%EC%BD%94%EB%94%A9'
    ret=$(${WCURL_CMD} ${url} 2>&1)
    assertContains "Verify whether 'wcurl' successfully decodes percent-encoded Korean in URLs" "${ret}" '퍼센트_인코딩'
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

# shellcheck disable=SC1091
. shunit2
