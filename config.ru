require "pry"
require "json"
require "doc_integrity_check"
require "mimemagic"
require "docsplit"
require "curb"

# Load all files
Dir.glob('./app/{parsers,controllers}/*.rb').each { |file| require file }

run ReceiveController

