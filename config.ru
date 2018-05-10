require "pry"
require "json"
require "doc_integrity_check"
require "mimemagic"
require "docsplit"
require "curb"

# Set key to encrypt to
ENV['gpg_recipient'] = "3E491C10"

# Load all files
Dir.glob('./app/{ocr,udp,controllers}/*.rb').each { |file| require file }

run ReceiveController

