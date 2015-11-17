# ghbuild
colorized build system using ruby

Current Version: alpha(after PRE-RELEASE)

# sample output
	bash ;) 20:15:24 [SitanHuang@localhost xxx_web_project] ghbuild --version
	| ghbuild alpha(after PRE-RELEASE)
	bash ;) 20:15:38 [SitanHuang@localhost xxx_web_project] ghbuild
	| Welcome to ghbuild (alpha(after PRE-RELEASE))
	| ghbuild working directory: /home/D/JAVA-dev/xxx_web_project
	| No ghb file detected, creating the file
	bash ;( 20:15:46 [SitanHuang@localhost xxx_web_project] ghbuild --mode=local
	| Mode: local
	| Welcome to ghbuild (alpha(after PRE-RELEASE))
	| ghbuild working directory: /home/D/JAVA-dev/xxx_web_project
	| Loading files
	| OK
	| Found target preprocess with 4 object(s)
	| 	Processing out/artifacts/xxx_web_project_war_exploded/seekcab in step 0
	| 		SeekCab~~~~~~~~~~
	| 		ghbuild version == alpha(after PRE-RELEASE)
	| 	Processing ./seekcab in step 0
	| 		SeekCab~~~~~~~~~~
	| 		ghbuild version == alpha(after PRE-RELEASE)
	| 	Processing out/artifacts/xxx_web_project_war_exploded/WEB-INF/classes/conf/config.properties in step 1
	| 		remoteImageDir = 192.168.0.5:8080
	| 		Updated: config.properties
	| 	Processing src/conf/config.properties in step 1
	| 		remoteImageDir = 192.168.0.5:8080
	| 		Updated: config.properties


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

$VERSION - version of ghbuild

##colorize
see the document for ruby colorize
