require 'rubygems'

require 'colorize'

$preproc_list = []
$build_list   = []
$install_list = []
$test_list    = []

$mode         = ''

def info s
	if !$quiet
		print "#{'|'.bold.colorize(:light_blue)} #{s}"
	end
end

def warn s
	print "#{'|'.bold.colorize(:yellow)} #{s}"
end

$quiet = false

def log s
	if !$quiet
		print "#{'|'.bold.colorize(:green)} #{s}"
	end
end

def error s
	print "#{'|'.bold.colorize(:red)} #{s}"
	exit 1
end

def request_root l,s
	if `/usr/bin/env id` =~ /\(root\)/
		log l
	else
		error s
	end
end

def execute &block
	begin
		block.call
	rescue Exception => e
		error "#{e.to_s}\n"
	end
end

$bwd = Dir.pwd

$VERSION = 'alpha 0.1.6aft'

$exclude_args = []

ARGV.each do |arg|
	if arg.start_with? '--mode='
		$mode = arg.gsub '--mode=', ''
	elsif arg == '--quiet'
		$quiet = true
	elsif arg == '--destroy'
		log "Destroying ghb files\n"
		execute do
			Dir.delete '.ghb'
		end
		exit 0
	elsif arg.start_with? '--exclude='
		tmp_exclude = arg.gsub '--exclude=', ''
		compiled = Regexp.new tmp_exclude
		$exclude_args.push compiled
	elsif arg == '--version'
		log "ghbuild #{$VERSION}\n"
		exit 0
	else
		error "Unknown option: #{arg}\n"
	end
end

info "Welcome to ghbuild (#{$VERSION})\n"
info "ghbuild working directory: #{$bwd.bold}\n"

log "Mode: #{$mode}\n"
log "Files excluded:\n"
if $exclude_args.length != 0
	$exclude_args.each_with_index do |e, index|
		log "\t##{index + 1} #{e.to_s}\n"
	end
else
	log "\t(nothing!)\n"
end
class Step
	attr_accessor :name
	attr_accessor :type
	attr_accessor :step
	attr_accessor :content
end

if not File.directory?('.ghb')
	Dir.mkdir '.ghb'
	error "No ghb file detected, creating the file\n"
end

log "Loading files\n"

def exclude? name
	$exclude_args.each do |e|
		if e =~ name
			return true
		end
	end
	return false
end

execute do
	Dir['**/*.rb'].select do |file|
		basename = File.basename file
		if basename =~ /^([^-]+)-(pre|p|build|b|install|i|test|t)-([0-9])\.rb$/ \
			and not exclude? basename; then
			step = Step.new
			step.content = IO.read file
			reg = /^([^-]+)-(pre|p|build|b|install|i|test|t)-([0-9])\.rb$/
			step.name = File.dirname(file) + '/' + basename.sub(reg, '\1')
			type = basename.sub(reg, '\2')
			case type
				when 'p'
					type = 'pre'
				when 'b'
					type = 'build'
				when 'i'
					type = 'install'
				when 't'
					type = 'test'
			end
			step.type = type
			step.step = Integer(basename.sub(reg, '\3'))
			case step.type
				when 'pre'
					$preproc_list.push step
				when 'build'
					$build_list.push step
				when 'install'
					$install_list.push step
				when 'test'
					$test_list.push step
				else
					error "fixme:this is not possible step.type\n"
			end
		elsif exclude? basename
			info "\tExcluded: #{basename}\n"
		end
	end
end
log "OK\n"
def processTarget(target)
	list = []
	case target
		when 'pre'
			list = $preproc_list
		when 'build'
			list = $build_list
		when 'install'
			list = $install_list
		when 'test'
			list = $test_list
	end
	index = 0
	9.times do
		list.each do |step|
			if step.step == index
				log "\tProcessing #{step.name} in step #{index}\n"
				execute do
					eval step.content
				end
			end
		end
		index += 1
	end
end
if !$preproc_list.empty?
	log "Found target preprocess with #{$preproc_list.length} object(s)\n"
	processTarget 'pre'
end
if !$build_list.empty?
	log "Found target build with #{$build_list.length} object(s)\n"
	processTarget 'build'
end
if !$install_list.empty?
	log "Found target install with #{$install_list.length} object(s)\n"
	processTarget 'install'
end
if !$test_list.empty?
	log "Found target test with #{$test_list.length} object(s)\n"
	processTarget 'test'
end
