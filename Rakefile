lib_dir = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib_dir)
$LOAD_PATH.uniq!

require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'dice_bag/tasks'

Dir['tasks/**/*.rake'].each { |rake| load rake }
