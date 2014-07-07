
# Xenuti

Xenuti is a continuous integration framework for security testing.

Attention: this is Work In Progress !

## Usage

1. Check out the source of Xenuti and run

	bundle install

   to install dependencies of Xenuti.

2. Generate example configuration file and edit it to configure Xenuti for your 
   application:

	bin/xenuti generate_config --file <name of config file>

3. Execute Xenuti scan:

	bin/xenuti run <name of config file>


## Contributing

Before commiting the code, please make sure to run `rake spec` and `rake rubocop`.
To automate this process, copy `pre-commit` to `.git/hooks/pre-commit`.

Please write a testcase for every functionality you add and make sure coverage
is reasonably high.

## License

Xenuti is released under the MIT License.