# wcurl(1)

**wcurl**
- a simple wrapper around curl to easily download files.

<a name="synopsis"></a>

# Synopsis

    wcurl [--curl-options <CURL_OPTIONS>|--curl-options=<CURL_OPTIONS>]... <URL>...

<a name="description"></a>

# Description

**wcurl** is a simple curl wrapper which lets you use curl to download files
without having to remember any parameters.

Simply call **wcurl** with a list of URLs you want to download and **wcurl** will pick
sane defaults.

If you need anything more complex, you can provide any of curl's supported
parameters via the **--curl-options** option. Just beware that you likely
should be using curl directly if your use case is not covered.


* By default, **wcurl** will:    
  * Encode whitespaces in URLs;  
  * Download multiple URLs in parallel;  
  * Follow redirects;  
  * Automatically choose a filename as output, without overwritting files;  
  * Perform retries;  
  * Set the downloaded file timestamp to the value provided by the server, if available;  
  * Disable **curl**'s URL globbing parser so **{}** and **\[\]** characters in URLs are not treated specially.

<a name="options"></a>

# Options


* **--curl-options &lt;CURL\_OPTIONS&gt;**...  
  Options to be passed to the curl invocation.
  Note that all options need to be passed as a single item, so you may
  need to surround it with quotes.

<a name="curl_options"></a>

# Curl_options

Any option supported by curl can be set here.
This is not used by **wcurl**; it's instead forwarded to the curl invocation.

<a name="url"></a>

# Url

Anything which is not a parameter will be considered an URL.
**wcurl** will encode whitespaces and pass that to curl, which will perform the
parsing of the URL.

<a name="examples"></a>

# Examples

Download a single file:  
**wcurl example.com/filename.txt**

Download two files in parallel:  
**wcurl example.com/filename1.txt example.com/filename2.txt**

Download a file passing the _--progress-bar_ and _--http2_ flags to curl:  
**wcurl --curl-options="--progress-bar --http2" example.com/filename.txt**

Resume from an interrupted download (if more options are used, this needs to be the last one in the list):  
**wcurl --curl-options="--continue-at -" example.com/filename.txt**

<a name="authors"></a>

# Authors

Samuel Henrique &lt;[samueloph@debian.org](mailto:samueloph@debian.org)&gt;  
Sergio Durigan Junior &lt;[sergiodj@debian.org](mailto:sergiodj@debian.org)&gt;

<a name="reporting-bugs"></a>

# Reporting Bugs

If you experience any problems with **wcurl** that you do not experience with curl,
submit an issue on the Debian Bug Tracking System.

<a name="copyright"></a>

# Copyright

**wcurl** is licensed under the curl license

<a name="see-also"></a>

# See Also

**curl**(1)
