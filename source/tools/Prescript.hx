package tools;

import sys.io.Process;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import StringTools;

class Prescript {
	public static function main():Void {
		trace('[Prescript] Starting pre-build script...');

		// Platform Check
		var platform = Sys.systemName();
		trace('[Prescript] Platform: $platform');
		if (platform.toLowerCase() == "html5") {
			trace("[Prescript] Skipping checks for HTML5 target.");
			Sys.exit(0);
		}

		// Project Structure Check
		var expectedPaths = [
			"assets/shared/images/credits",
			"source/funkin/ui",
			"source/Main.hx",
			"project.hxp",
			"export/"
		];
		for (path in expectedPaths) {
			if (!FileSystem.exists(path)) {
				trace('[ERROR] Missing: $path');
			} else {
				trace('[OK] Found: $path');
			}
		}

		// Haxelib Checks
		var requiredLibs = [
			"flixel", "openfl", "lime", "flixel-ui", "hxjson"
		];
		trace('\n[Prescript] Checking required Haxe libraries...');
		for (lib in requiredLibs) {
			try {
				var proc = new Process("haxelib", ["path", lib]);
				var output = proc.stdout.readAll().toString();
				if (output.indexOf("Error") != -1) {
					trace('[ERROR] $lib not installed.');
				} else {
					trace('[OK] $lib is installed.');
				}
			} catch (e:Dynamic) {
				trace('[ERROR] Failed to check haxelib: $lib. Try: haxelib install $lib');
			}
		}

		// Git Info
		trace('\n[Prescript] Retrieving Git version info...');
		try {
			var branch = new Process("git", ["rev-parse", "--abbrev-ref", "HEAD"]);
			var commit = new Process("git", ["rev-parse", "HEAD"]);
		    trace('[Git] Branch: ' + StringTools.trim(branch.stdout.readAll().toString()));
            trace('[Git] Commit: ' + StringTools.trim(commit.stdout.readAll().toString()));

		} catch (e:Dynamic) {
			trace('[WARNING] Git info not available.');
		}

		// Asset Folder Check
		var iconPath = "assets/shared/images/credits";
		if (!FileSystem.exists(iconPath)) {
			trace('[ERROR] Missing credits image folder: $iconPath');
		} else {
			var icons = FileSystem.readDirectory(iconPath);
			if (icons.length == 0) {
				trace('[WARNING] No icons found in: $iconPath');
			} else {
				for (file in icons) {
					if (!StringTools.endsWith(file, ".png")) {
						trace('[WARNING] Non-PNG file in credits folder: $file');
					}
				}
			}
		}

		// Extra Suggestions
		trace('\n[Prescript] Helpful Tips:');
		trace('- Clean builds with: lime clean');
		trace('- Delete export/ if your build is stuck.');
		trace('- Run lime rebuild openfl -clean if weird display errors occur.');

		trace('\n[Prescript] Pre-build checks complete. Proceeding...\n');
	}
}
