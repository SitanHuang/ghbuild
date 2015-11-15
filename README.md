# ghbuild
colorized build system using ruby

# sample output
	| Welcome to ghbuild (PRE-RELEASE)
	| ghbuild working directory: /home/D/ruby/ghb
	| Loading files
	| OK
	| Found target preprocess with 1 object(s)
	|	Processing ./test in step 0
	|	ghbuild executable found
	| Found target test with 2 object(s)
	|	Processing ./test in step 0
	|	Processing ./test1 in step 1

# installation
	gem install colorize
	
	cp ghbuild* /usr/local/bin

# single paged documentation
test if ghbuild is working:

	[user@localhost test] ghbuild --version

	| ghbuild PRE-RELEASE

initialize a ghbuild directory in a normal directory:

	[user@localhost test] ghbuild

destroying a ghbuild directory:

	[user@localhost test] ghbuild --destory

set $mode variable: --mode=xxx

only necessary outputs: --quiet

run:
	[user@localhost test] ghbuild # you must have ghbuild initialized on this directory

##cycle
1. pre-processing
2. building
3. installing
4. testing

*Not all above are required*

##creating a task
just create a file named:

	(name)-(pre|p|build|b|install|i|test|t)-(step number 0-9).rb

then ghbuild will follow:

	pre{step 0-9} > build{step 0-9} > install{step 0-9} > test{step 0-9}

##functions
info(string) - normal logging without new line

log(string) - operational logging without new line

error(string) - error logging without new line then terminate

##variables
$mode - command line --mode argument

$bwd - shell working directory

##colorize
see the document for ruby colorize
