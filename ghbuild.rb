require 'rubygems'

require 'colorize'

$preproc_list = []
$build_list   = []
$install_list = []
$test_list    = []

$mode         = ''

def assert a,s = "assertion failed: #{a}"
    if !a
        error "#{s}\n"
    end
end

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

$VERSION = 'alpha 0.1.96'

$exclude_args = []
$tasks = []

$no_basename_dups = false

$no_proc = false

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
  elsif arg == '--no_basename_dups'
      $no_basename_dups = true
  elsif arg == '--version'
      log "ghbuild #{$VERSION}\n"
      exit 0
  elsif arg == '--no_proc'
      $no_proc = true
  elsif arg.start_with? '--task='
      task = arg.split('=')[1]
      $tasks << task
  else
      error "Unknown option: #{arg}\n"
  end
end

info "Welcome to ghbuild (#{$VERSION})\n"
info "ghbuild working directory: #{$bwd.bold}\n"
if $no_basename_dups
    log "No duplicates of basenames\n"
end
log "Mode: #{$mode}\n"
log "Files excluded:\n"
if $exclude_args.length != 0
  $exclude_args.each_with_index do |e, index|
      log "\t##{index + 1} #{e.to_s}\n"
  end
else
    log "\t(nothing)\n"
end
if $tasks.length != 0
  log "Tasks:\n"
  $tasks.each_with_index do |e, index|
    log "\t##{index + 1} #{e.to_s}\n"
  end
end
class Step
  attr_accessor :name
  attr_accessor :shortName
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
            step.shortName = basename.sub(reg, '\1')
            step.name = File.dirname(file) + '/' + step.shortName
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
            skip=false
            case type
                when 'pre'
                    $preproc_list.each do |e|
                        if e.shortName == step.shortName
                            skip = true
                            break
                        end
                    end
                when 'build'
                    $build_list.each do |e|
                        if e.shortName == step.shortName
                            skip = true
                            break
                        end
                    end
                when 'install'
                    $install_list.each do |e|
                        if e.shortName == step.shortName
                            skip = true
                            break
                        end
                    end
                when 'test'
                    $test_list.each do |e|
                        if e.shortName == step.shortName
                            skip = true
                            break
                        end
                    end
            end
            if !$no_basename_dups
                skip = false
            end
            if !skip
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
            else
                info "\tDuplicate: #{step.name}\n"
            end
        elsif exclude? basename
            info "\tExcluded: #{basename}\n"
        end
    end
end
log "OK\n"
if $no_proc
    info "No processing\n"
end
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
          if (step.step == index and $tasks.empty?) or ($tasks.include?(step.shortName) and !$tasks.empty? and step.step == index)
            if !$no_proc
                log "\tProcessing '#{step.name.light_green}' in step #{index.to_s.bold.light_green}\n"
                execute do
                    eval "lwd=#{"./#{File.dirname(step.name)}".inspect}\n#{step.content}"
                end
            else
                info "\tFound '#{step.name.bold.light_blue}' in step #{index.to_s.bold.light_blue}\n"
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
