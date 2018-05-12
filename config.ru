require "pry"
require "json"
require "doc_integrity_check"
require "mimemagic"
require "docsplit"
require "curb"
require "filemagic"

# Set key to encrypt to
ENV['gpg_recipient'] = "360F8060"

# Load all files
Dir.glob('./app/{ocr,udp,controllers}/*.rb').each { |file| require file }

run ReceiveController

