$root = File.dirname(__FILE__)
$:.unshift $root + '/vendor/actionpack-3.2.13/lib'
require $root + '/tasks'
run Tasks
