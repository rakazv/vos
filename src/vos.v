module vos

import os

pub fn is_wsl() bool {
	$if linux {
		if os.uname().release.contains('microsoft') {
			return true
		}
	}
	return false
}

// user_os returns the user's operating system name, including wsl.
pub fn user_os() string {
	$if linux {
		if os.uname().release.contains('microsoft') {
			return 'wsl'
		}
	}
	return os.user_os()
}

// open_uri opens uri, supporting wsl
pub fn open_uri(uri string) ! {
	if is_wsl() {
		if os.exists(uri) {
			open_path_from_wsl(uri)!
			return
		}
		result := os.execute('rundll32.exe url.dll,FileProtocolHandler ${uri}')
		if result.exit_code != 0 {
			return error('unable to open url: ${result.output}')
		}
		return
	}
	os.open_uri(uri)!
}

fn open_path_from_wsl(file string) ! {
	result := os.execute('rundll32.exe url.dll,FileProtocolHandler "\$(wslpath -w "${file}")"')
	if result.exit_code != 0 {
		return error('unable to open file: ${result.output}')
	}
}