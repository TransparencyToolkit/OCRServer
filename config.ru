require "pry"
require "json"
require "doc_integrity_check"

# Load all files
Dir.glob('./app/{parsers,controllers}/*.rb').each { |file| require file }

run ReceiveController

