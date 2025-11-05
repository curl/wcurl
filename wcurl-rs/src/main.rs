// SPDX-FileCopyrightText: 2025 Eric Curtin <eric.curtin@docker.com>
//
// SPDX-License-Identifier: curl

use std::process::Command;

#[derive(Debug)]
struct Args {
    urls: Vec<String>,
    curl_options: Vec<String>,
    output: Option<String>,
    no_decode_filename: bool,
    dry_run: bool,
}

impl Args {
    fn parse() -> Self {
        // Process arguments manually to handle complex patterns
        let mut args: Vec<String> = std::env::args().collect();
        args.remove(0); // Remove program name

        let mut i = 0;
        let mut after_double_dash = false;
        let mut urls = Vec::new();
        let mut curl_options = Vec::new();
        let mut output = None;
        let mut no_decode_filename = false;
        let mut dry_run = false;
        let mut version = false;
        let mut help = false;

        while i < args.len() {
            let arg = &args[i];

            if arg == "--" {
                after_double_dash = true;
                i += 1;
                continue;
            }

            if arg == "-h" || arg == "--help" {
                help = true;
                i += 1;
                continue;
            } else if arg == "-V" || arg == "--version" {
                version = true;
                i += 1;
                continue;
            }

            if arg.starts_with("--curl-options=") && !after_double_dash {
                let opt = arg.strip_prefix("--curl-options=").unwrap().to_string();
                curl_options.push(opt);
                i += 1;
            } else if arg == "--curl-options" && i + 1 < args.len() && !after_double_dash {
                i += 1;
                curl_options.push(args[i].clone());
                i += 1;
            } else if arg.starts_with("--output=") && !after_double_dash {
                output = Some(arg.strip_prefix("--output=").unwrap().to_string());
                i += 1;
            } else if (arg == "-o" || arg == "-O" || arg == "--output") && !after_double_dash {
                if i + 1 < args.len() {
                    i += 1;
                    output = Some(args[i].clone());
                    i += 1;
                } else {
                    eprintln!("Unknown option: '{}'.", arg);
                    std::process::exit(1);
                }
            } else if arg.starts_with("-o") && arg.len() > 2 && !after_double_dash {
                // Handle -o filename
                let opt = arg[2..].to_string();
                output = Some(opt);
                i += 1;
            } else if arg.starts_with("-O") && arg.len() > 2 && !after_double_dash {
                // Handle -O filename
                let opt = arg[2..].to_string();
                output = Some(opt);
                i += 1;
            } else if arg == "--no-decode-filename" && !after_double_dash {
                no_decode_filename = true;
                i += 1;
            } else if arg == "--dry-run" && !after_double_dash {
                dry_run = true;
                i += 1;
            } else if arg.starts_with("-") && !after_double_dash {
                eprintln!("Unknown option: '{}'.", arg);
                std::process::exit(1);
            } else {
                // This is a URL
                urls.push(arg.clone());
                i += 1;
            }
        }

        // Handle version and help after parsing
        if version {
            println!("{}", env!("CARGO_PKG_VERSION"));
            std::process::exit(0);
        }

        if help {
            println!("{}", get_usage());
            std::process::exit(0);
        }

        Self {
            urls,
            curl_options,
            output,
            no_decode_filename,
            dry_run,
        }
    }
}

fn get_usage() -> String {
    r#"wcurl -- a simple wrapper around curl to easily download files.

Usage: wcurl <URL>...
       wcurl [--curl-options <CURL_OPTIONS>]... [--no-decode-filename] [-o|-O|--output <PATH>] [--dry-run] [--] <URL>...
       wcurl [--curl-options=<CURL_OPTIONS>]... [--no-decode-filename] [--output=<PATH>] [--dry-run] [--] <URL>...
       wcurl -h|--help
       wcurl -V|--version

Options:

  --curl-options <CURL_OPTIONS>: Specify extra options to be passed when invoking curl. May be
                                 specified more than once.

  -o, -O, --output <PATH>: Use the provided output path instead of getting it from the URL. If
                           multiple URLs are provided, resulting files share the same name with a
                           number appended to the end (curl >= 7.83.0). If this option is provided
                           multiple times, only the last value is considered.

  --no-decode-filename: Don't percent-decode the output filename, even if the percent-encoding in
                        the URL was done by wcurl, e.g.: The URL contained whitespace.

  --dry-run: Don't actually execute curl, just print what would be invoked.

  -V, --version: Print version information.

  -h, --help: Print this usage message.

  <CURL_OPTIONS>: Any option supported by curl can be set here. This is not used by wcurl; it is
                 instead forwarded to the curl invocation.

  <URL>: URL to be downloaded. Anything that is not a parameter is considered
         an URL. Whitespace is percent-encoded and the URL is passed to curl, which
         then performs the parsing. May be specified more than once."#.to_string()
}

#[derive(Debug)]
struct Wcurl {
    args: Args,
}

impl Wcurl {
    fn new(args: Args) -> Self {
        Self { args }
    }

    fn run(&self) -> Result<(), Box<dyn std::error::Error>> {
        // If no URLs provided, show error
        if self.args.urls.is_empty() {
            eprintln!("You must provide at least one URL to download.");
            std::process::exit(1);
        }

        // Get curl version and features
        let curl_features = Self::get_curl_features()?;

        // Build the command
        let mut cmd_parts = vec!["curl".to_string()];

        // Add parallel flag if multiple URLs and curl supports it
        if self.args.urls.len() > 1 && curl_features.supports_parallel {
            cmd_parts.push("--parallel".to_string());
            if curl_features.supports_parallel_max_host {
                cmd_parts.push("--parallel-max-host".to_string());
                cmd_parts.push("5".to_string());
            }
        }

        // Handle each URL
        for (i, url) in self.args.urls.iter().enumerate() {
            if i > 0 {
                cmd_parts.push("--next".to_string());
            }

            // Add per-URL parameters
            cmd_parts.extend_from_slice(&[
                "--fail".to_string(),
                "--globoff".to_string(),
                "--location".to_string(),
                "--proto-default".to_string(),
                "https".to_string(),
                "--remote-time".to_string(),
                "--retry".to_string(),
                "5".to_string(),
            ]);

            // Add --no-clobber if supported and no user output was specified
            if curl_features.supports_no_clobber && self.args.output.is_none() {
                cmd_parts.push("--no-clobber".to_string());
            }

            // Determine output path
            let output_path = if let Some(ref output) = self.args.output {
                output.clone()
            } else {
                let processed_url = Self::encode_whitespace(url);
                let filename = Self::get_url_filename(&processed_url, !self.args.no_decode_filename);
                if filename.is_empty() {
                    "index.html".to_string()
                } else {
                    filename
                }
            };

            cmd_parts.push("--output".to_string());
            cmd_parts.push(output_path);

            let processed_url = Self::encode_whitespace(url);
            cmd_parts.push(processed_url);
        }

        // Add user's curl options at the end
        for opt in &self.args.curl_options {
            cmd_parts.push(opt.clone());
        }

        if self.args.dry_run {
            println!("{}", cmd_parts.join(" "));
        } else {
            let mut cmd = Command::new("curl");
            for part in &cmd_parts[1..] { // skip "curl" at index 0
                cmd.arg(part);
            }
            let status = cmd.status()?;
            if !status.success() {
                std::process::exit(status.code().unwrap_or(1));
            }
        }

        Ok(())
    }

    fn get_curl_features() -> Result<CurlFeatures, Box<dyn std::error::Error>> {
        let output = Command::new("curl").arg("--version").output()?;
        let version_str = String::from_utf8(output.stdout)?;

        // Extract version by looking for the main curl version in the output.
        // Format is like: "curl 8.7.1 (x86_64-apple-darwin25.0) libcurl/8.7.1 [...]"
        // Look for the first occurrence of a version pattern
        let words: Vec<&str> = version_str.split_whitespace().collect();
        let mut found_version = None;
        
        for word in words {
            if word.chars().next().unwrap_or('0').is_ascii_digit() {
                // This might be a version number like "8.7.1"
                let version_parts: Vec<&str> = word.split('.').collect();
                if version_parts.len() >= 2 && 
                   version_parts[0].chars().all(|c| c.is_ascii_digit()) &&
                   version_parts[1].chars().all(|c| c.is_ascii_digit()) {
                    found_version = Some(word);
                    break;
                }
            }
        }
        
        // If we didn't find it by the first approach, try the "curl X.Y.Z" pattern
        if found_version.is_none() {
            let parts: Vec<&str> = version_str.split_whitespace().collect();
            for i in 0..parts.len().saturating_sub(1) {
                if parts[i] == "curl" {
                    let next_part = parts[i + 1];
                    let version_parts: Vec<&str> = next_part.split('.').collect();
                    if version_parts.len() >= 2 && 
                       version_parts[0].chars().all(|c| c.is_ascii_digit()) &&
                       version_parts[1].chars().all(|c| c.is_ascii_digit()) {
                        found_version = Some(next_part);
                        break;
                    }
                }
            }
        }
        
        if let Some(version) = found_version {
            let version_parts: Vec<&str> = version.split('.').collect();
            if version_parts.len() >= 2 {
                if let (Ok(major), Ok(minor)) = (version_parts[0].parse::<u32>(), version_parts[1].parse::<u32>()) {
                    // Determine features based on version
                    let supports_no_clobber = (major == 7 && minor >= 83) || major >= 8;
                    let supports_parallel = (major == 7 && minor >= 66) || major >= 8;
                    let supports_parallel_max_host = major >= 8 && minor >= 16;

                    Ok(CurlFeatures {
                        supports_no_clobber,
                        supports_parallel,
                        supports_parallel_max_host,
                    })
                } else {
                    // Default values if we can't parse version numbers
                    Ok(CurlFeatures {
                        supports_no_clobber: false,
                        supports_parallel: false,
                        supports_parallel_max_host: false,
                    })
                }
            } else {
                // Default values if we can't parse version
                Ok(CurlFeatures {
                    supports_no_clobber: false,
                    supports_parallel: false,
                    supports_parallel_max_host: false,
                })
            }
        } else {
            // Default values if we can't find version
            Ok(CurlFeatures {
                supports_no_clobber: false,
                supports_parallel: false,
                supports_parallel_max_host: false,
            })
        }
    }

    fn encode_whitespace(url: &str) -> String {
        url.replace(' ', "%20")
    }

    fn get_url_filename(url: &str, decode_filename: bool) -> String {
        // Remove protocol (http://, https://, etc.) and query string
        // Find the position where protocol ends, which is after "://"
        let hostname_and_path = if let Some(protocol_end) = url.find("://") {
            // Skip past the "://"
            &url[protocol_end + 3..]
        } else {
            url
        };
        
        // Remove query string if present
        let hostname_and_path = hostname_and_path.split('?').next().unwrap_or(hostname_and_path);

        // If contains a slash, extract the filename part
        if hostname_and_path.contains('/') {
            let filename = hostname_and_path.split('/').last().unwrap_or(hostname_and_path);
            
            // If URL ends with slash, return empty string (defaults to index.html)
            if url.ends_with('/') || filename.is_empty() {
                return String::new();
            }
            
            if decode_filename {
                Self::percent_decode_filename(filename)
            } else {
                filename.to_string()
            }
        } else {
            // No path means just hostname, return empty string (defaults to index.html)
            String::new()
        }
    }

    fn percent_decode_filename(filename: &str) -> String {
        // Define unsafe percent codes that should not be decoded
        // 2F = /, 5C = \
        let unsafe_codes = ["2F", "5C"];
        
        // Process percent-encoded sequences character by character
        let mut result = String::new();
        let chars: Vec<char> = filename.chars().collect();
        let mut i = 0;
        
        while i < chars.len() {
            if chars[i] == '%' && i + 2 < chars.len() {
                let hex1 = chars[i + 1];
                let hex2 = chars[i + 2];
                
                // Check if hex1 and hex2 are valid hex characters
                if hex1.is_ascii_hexdigit() && hex2.is_ascii_hexdigit() {
                    // Check if the code is unsafe
                    let hex_code = format!("{}{}", hex1.to_ascii_uppercase(), hex2.to_ascii_uppercase());
                    let is_unsafe = unsafe_codes.contains(&hex_code.as_str());
                    
                    if is_unsafe {
                        // Don't decode unsafe codes, just append the percent sequence
                        result.push('%');
                        result.push(hex1);
                        result.push(hex2);
                        i += 3;
                    } else {
                        // Decode the percent-encoded character
                        let hex_str = format!("{}{}", hex1, hex2);
                        if let Ok(byte_val) = u8::from_str_radix(&hex_str, 16) {
                            if byte_val < 32 { // Control characters (00-1F) are passed through
                                result.push('%');
                                result.push(hex1);
                                result.push(hex2);
                                i += 3;
                            } else {
                                match std::str::from_utf8(&[byte_val]) {
                                    Ok(decoded_char) => {
                                        result.push_str(decoded_char);
                                        i += 3;
                                    }
                                    Err(_) => {
                                        // Invalid UTF-8, keep the original percent encoding
                                        result.push('%');
                                        result.push(hex1);
                                        result.push(hex2);
                                        i += 3;
                                    }
                                }
                            }
                        } else {
                            // Invalid hex, just append the character
                            result.push(chars[i]);
                            i += 1;
                        }
                    }
                } else {
                    // Not a valid percent-encoding, just append the character
                    result.push(chars[i]);
                    i += 1;
                }
            } else {
                // Not a %, just append the character
                result.push(chars[i]);
                i += 1;
            }
        }
        
        result
    }
}

#[derive(Debug)]
struct CurlFeatures {
    supports_no_clobber: bool,
    supports_parallel: bool,
    supports_parallel_max_host: bool,
} // End of Wcurl impl

fn main() {
    let args = Args::parse();
    let wcurl = Wcurl::new(args);
    
    if let Err(e) = wcurl.run() {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
}
