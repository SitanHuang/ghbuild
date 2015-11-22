# ghbuild
colorized build system using ruby

Current Version: alpha 0.1.91

# sample output
	bash ;) 16:36:42 [SitanHuang@localhost ghb](master) ghbuild --version
	| ghbuild alpha 0.1.91
	bash ;) 16:36:46 [SitanHuang@localhost ghb](master) ghbuild --exclude=.+-test-[0-9].+ --exclude=.+-t-[0-9].+
	| Welcome to ghbuild (alpha 0.1.91)
	| ghbuild working directory: /home/D/ruby/ghb
	| Mode: 
	| Files excluded:
	| 	#1 (?-mix:.+-test-[0-9].+)
	| 	#2 (?-mix:.+-t-[0-9].+)
	| Loading files
	| 	Excluded: test-test-0.rb
	| 	Excluded: test1-test-1.rb
	| OK
	| Found target preprocess with 1 object(s)
	| 	Processing ./test in step 0
	| 	ghbuild executable found
	bash ;) 16:37:58 [SitanHuang@localhost ghb](master) 


# installation
	gem install colorize
	
	cp ghbuild* /usr/local/bin

# single paged documentation
test if ghbuild is working:

	[user@localhost test] ghbuild --version

initialize a ghbuild directory in a normal directory:

	[user@localhost test] ghbuild

destroying a ghbuild directory:

	[user@localhost test] ghbuild --destory

set $mode variable: --mode=xxx

only necessary outputs: --quiet

exclude filename: --exclude=regex

no duplicates: --no_basename_dups

only list files without processing: --no_proc

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

*note: '_' in name will be replaced with a space*

then ghbuild will follow:

	pre{step 0-9} > build{step 0-9} > install{step 0-9} > test{step 0-9}

##functions
info(string) - normal logging without new line

warn(string) - warning logging without new line

log(string) - operational logging without new line

error(string) - error logging without new line then terminate

request_root(l,s) - request root permission, l:output if success, s:output if failed
assert(object,[message])

##variables
$mode - command line --mode argument

$bwd - shell working directory

$VERSION - version of ghbuild

$exclude - a list of exclude patterns

$no_basename_dups

$no_proc

lwd - current script directory

##colorize
see the document for ruby colorize
