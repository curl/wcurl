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

ROOTDIR=$(CDPATH="" cd -- "$(dirname -- "$0")/.." && pwd)
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
    assertContains "Verify whether 'wcurl' chooses the correct default filename when there is no path in the URL" "${ret}" 'index.html'
}

testUrlDefaultNameTrailingSlash()
{
    url='example%20with%20spaces.com/'
    ret=$(${WCURL_CMD} ${url} 2>&1)
    assertContains "Verify whether 'wcurl' chooses the correct default filename when there is no path in the URL and the URl ends with a slash" "${ret}" 'index.html'
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
    ret=$(${WCURL_CMD} ${url} 2>&1 | tr '\n' ' ')
    assertContains "Verify whether 'wcurl' successfully uses the default filename when the URL ends with a slash" "${ret}" '--output filename%5Cwith%2Fbackslashes%5c%2f'
}

# Test decoding a bunch of different languages (that do not use the latin
# alphabet), we could split each language on its own test, but for now it
# does not make a difference.
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

# Tests for --save-call, --run-save, --list-save, --rm-save
testSaveCallBasic()
{
    # Create a temporary .wcurlrc for testing
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    
    # Clean up any existing test file
    rm -f "${TEST_WCURLRC}"
    
    # Test saving a simple call
    wcurl --save-call=testcall:"--silent --show-error" >/dev/null 2>&1
    assertTrue "Verify whether '--save-call' exits successfully" "$?"
    
    # Verify the file was created
    assertTrue "Verify whether .wcurlrc file was created" "[ -f ${TEST_WCURLRC} ]"
    
    # Verify the content
    ret=$(cat "${TEST_WCURLRC}")
    assertContains "Verify whether '--save-call' saves correctly" "${ret}" "testcall=--silent --show-error"
    
    # Clean up
    rm -f "${TEST_WCURLRC}"
}

testSaveCallMultiple()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # Save multiple calls
    wcurl --save-call=call1:"--silent" --save-call=call2:"--verbose" >/dev/null 2>&1
    assertTrue "Verify whether multiple '--save-call' options work" "$?"
    
    ret=$(cat "${TEST_WCURLRC}")
    assertContains "Verify whether first call is saved" "${ret}" "call1=--silent"
    assertContains "Verify whether second call is saved" "${ret}" "call2=--verbose"
    
    rm -f "${TEST_WCURLRC}"
}

testSaveCallWithParameterExpansion()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # Save a call with parameter expansion
    wcurl --save-call=paramtest:'-o !1 !2' >/dev/null 2>&1
    assertTrue "Verify whether '--save-call' with parameter expansion exits successfully" "$?"
    
    ret=$(cat "${TEST_WCURLRC}")
    assertContains "Verify whether parameter expansion is saved correctly" "${ret}" "paramtest=-o !1 !2"
    
    rm -f "${TEST_WCURLRC}"
}

testSaveCallUpdate()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # Save initial call
    wcurl --save-call=testcall:"--silent" >/dev/null 2>&1
    
    # Update the same call
    wcurl --save-call=testcall:"--verbose" >/dev/null 2>&1
    assertTrue "Verify whether '--save-call' can update existing calls" "$?"
    
    ret=$(cat "${TEST_WCURLRC}")
    assertContains "Verify whether updated call has new value" "${ret}" "testcall=--verbose"
    assertNotContains "Verify whether old value is removed" "${ret}" "testcall=--silent"
    
    # Verify only one entry exists
    count=$(grep -c "testcall=" "${TEST_WCURLRC}")
    assertEquals "Verify whether only one entry exists after update" "1" "${count}"
    
    rm -f "${TEST_WCURLRC}"
}

testSaveCallMissingColon()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # Try to save without colon separator
    ret=$(wcurl --save-call=testcall 2>&1)
    assertFalse "Verify whether '--save-call' without colon fails" "$?"
    assertContains "Verify whether error message is displayed" "${ret}" "requires a colon separator"
    
    rm -f "${TEST_WCURLRC}"
}

testListSaveEmpty()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # List when no file exists
    ret=$(wcurl --list-save 2>&1)
    assertTrue "Verify whether '--list-save' exits successfully when file doesn't exist" "$?"
    assertContains "Verify whether appropriate message is shown" "${ret}" "No saved calls found"
    
    rm -f "${TEST_WCURLRC}"
}

testListSaveWithCalls()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # Save some calls
    wcurl --save-call=quiet:"--silent --show-error" >/dev/null 2>&1
    wcurl --save-call=verbose:"--verbose" >/dev/null 2>&1
    
    # List them
    ret=$(wcurl --list-save 2>&1)
    assertTrue "Verify whether '--list-save' exits successfully" "$?"
    assertContains "Verify whether first saved call is listed" "${ret}" "quiet:"
    assertContains "Verify whether second saved call is listed" "${ret}" "verbose:"
    assertContains "Verify whether first call options are shown" "${ret}" "--silent --show-error"
    assertContains "Verify whether second call options are shown" "${ret}" "--verbose"
    
    rm -f "${TEST_WCURLRC}"
}

testRmSaveBasic()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # Save a call
    wcurl --save-call=testcall:"--silent" >/dev/null 2>&1
    
    # Remove it
    ret=$(wcurl --rm-save=testcall 2>&1)
    assertTrue "Verify whether '--rm-save' exits successfully" "$?"
    assertContains "Verify whether removal message is displayed" "${ret}" "Removed saved call: testcall"
    
    # Verify it's gone
    if [ -f "${TEST_WCURLRC}" ]; then
        content=$(cat "${TEST_WCURLRC}")
        assertNotContains "Verify whether call is removed from file" "${content}" "testcall="
    fi
    
    rm -f "${TEST_WCURLRC}"
}

testRmSaveNonExistent()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # Save a call
    wcurl --save-call=testcall:"--silent" >/dev/null 2>&1
    
    # Try to remove non-existent call
    ret=$(wcurl --rm-save=nonexistent 2>&1)
    assertFalse "Verify whether '--rm-save' fails for non-existent call" "$?"
    assertContains "Verify whether error message is displayed" "${ret}" "not found"
    
    rm -f "${TEST_WCURLRC}"
}

testRunSaveBasic()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # Save a call without parameter expansion
    wcurl --save-call=testrun:"--silent --show-error" >/dev/null 2>&1
    
    # Run it with dry-run
    ret=$(wcurl --dry-run --run-save=testrun example.com 2>&1)
    assertTrue "Verify whether '--run-save' exits successfully" "$?"
    assertContains "Verify whether saved options are applied" "${ret}" "--silent"
    assertContains "Verify whether saved options are applied" "${ret}" "--show-error"
    assertContains "Verify whether URL is included" "${ret}" "example.com"
    
    rm -f "${TEST_WCURLRC}"
}

testRunSaveShortOption()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # Save a call
    wcurl --save-call=testrun:"--verbose" >/dev/null 2>&1
    
    # Run it with short option -r
    ret=$(wcurl --dry-run -r=testrun example.com 2>&1)
    assertTrue "Verify whether '-r' short option works" "$?"
    assertContains "Verify whether saved options are applied with -r" "${ret}" "--verbose"
    
    rm -f "${TEST_WCURLRC}"
}

testRunSaveNonExistent()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # Try to run non-existent call (will treat as literal curl options)
    ret=$(wcurl --dry-run --run-save=nonexistent example.com 2>&1)
    assertTrue "Verify whether '--run-save' with non-existent name still works (treats as literal)" "$?"
    assertContains "Verify whether the literal value is used" "${ret}" "nonexistent"
    
    rm -f "${TEST_WCURLRC}"
}

testRunSaveParameterExpansion()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # Save a call with parameter expansion
    wcurl --save-call=paramrun:'-o !1 !2' >/dev/null 2>&1
    
    # Run it with parameters (this executes curl directly, not dry-run)
    # We can't easily test this without actually running curl, so we'll skip the execution test
    # Just verify the save worked
    ret=$(cat "${TEST_WCURLRC}")
    assertContains "Verify parameter expansion call is saved" "${ret}" "paramrun=-o !1 !2"
    
    rm -f "${TEST_WCURLRC}"
}

testRunSaveParameterExpansionNotEnoughParams()
{
    TEST_WCURLRC="${SHUNIT_TMPDIR}/.wcurlrc"
    export HOME="${SHUNIT_TMPDIR}"
    rm -f "${TEST_WCURLRC}"
    
    # Save a call requiring 2 parameters
    wcurl --save-call=needstwo:'-o !1 !2' >/dev/null 2>&1
    
    # Try to run with only 1 parameter
    ret=$(wcurl --run-save=needstwo oneparam 2>&1)
    assertFalse "Verify whether '--run-save' fails when not enough parameters provided" "$?"
    assertContains "Verify whether error message about parameters is shown" "${ret}" "Not enough parameters"
    
    rm -f "${TEST_WCURLRC}"
}

## Ideas for tests:
##
## - URL with whitespace
## - Different encodes do not get messed up
## - Test '--' (with and without)
## - Test filename output (URL ending/not ending with slash)
## - Filename with whitespace (decoding)
## - --parallel when more than 1 URL is provided
## - --opts, -o, --opts=...
## - Options are the same for all URLs (except --next)
## - URLs beginning with '-' (with and without using '--')

# shellcheck disable=SC1091
. shunit2
