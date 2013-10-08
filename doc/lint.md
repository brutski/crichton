## Crichton Lint

Crichton Lint is a means to determine if a resource descriptor file is well structured and meets the 
requirements of Crichton.

Since a resource descriptor document is a .yml file, it first must meet the requirements of a
well-formed YAML file. This website is one of many to help check to see if the file is well
formed: [yaml parser] (http://yaml-online-parser.appspot.com/)

Crichton lint works to validate the logic of a single resource descriptor file, outputting errors, warning
and hints to help generate an optimal document.

Lint can be invoked in two ways, once crichton is added to your project as a gem:

### A lint gem ruby executable  (rdlint)

`bundle exec rdlint <options> <resource desciptor file>`

rdlint can validate a single descriotor file or, with a -all option, will validate all the descriptor files
found in the current project (the location of descriptor files defaults to an api_descriptors directory).

The options to rdlint are:

* -v or --version: Display the version number of the crichton library
* -w or --no_warnings: Suppress all warnings and display errors messages only, if any
* -s or --strict: Strict mode, returns true for all validations passing, false if any descriptor file fails lint
* -a or --all: Lint all (*.yml, *.yaml) files found in the resource descriptor directory (defaults to api_descriptors)
* -h or --help: Displays the standard usage dialog

Some examples, run from the root of a project

* `bundle exec rdlint api_descriptors/file.yml`  Lint validates a single file
* `bundle exec rdlint -a (or --all) ` Lint validate all files in the resource descriptor directory
* `bundle exec rdlint -w api_descriptors/file.yml` Lint single file and suppress warning messages
* `bundle exec rdlint -aw` Lint all descriptor files and suppress warning messages
* `bundle exec rdlint -v api_descriptors/file.yml` Display a version message and lint a single file
* `bundle exec rdlint -s api_descriptors/file.yml` Lint a single file and outputs "true" or "false" (pass / fail).
* `bundle exec rdlint -as` Lint all descriptor file and outputs "true" / "false". Returns on the first fail.

Mutual exclusive options:
* -s takes precedence over -w, the warning option will be ignored if specified together with strict mode (e.g. -sw)
* -a with a specified file name will ignore the file name, the "all" option takes precedence

### Running from rake

Projects bundled with the crichton gem can also lint validate resource descriptor files using rake.

Rake takes up to two parameters with the following invocation possibilities:

1. "path_to_filename"
2. "all"
3. "path_to_filename", with options "strict"/"no_warnings"/"version"
4. "all", with options "strict"/"no_warnings"/"version"

For example:

* `bundle exec rake crichton:lint[<path_to_a_file>]`
* `bundle exec rake crichton:lint[<path_to_a_file>,no_warnings]`
* `bundle exec rake crichton:lint[<path_to_a_file>,strict]`
* `bundle exec rake crichton:lint[<path_to_a_file>,version]`
* `bundle exec rake crichton:lint[all]`
* `bundle exec rake crichton:lint[all,no_warnings]`
* `bundle exec rake crichton:lint[all,no_warnings]`
* `bundle exec rake crichton:lint[all,version]`

For those unfamiliar with rake, arguments to rake require brackets. In zsh, you must escape
the brackets with `\[...\]`. No spaces between the two parameters.

### Pure strict mode
For native ruby access to lint validation, you can do the following (provided that proper requires have been setup to
the crichton/lib/lint folder). This will return a pure ruby true / false return value.

`Lint.validate(<filename>, {strict: true})  # => true or false`