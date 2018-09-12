require "pry"
require "json"
require "doc_integrity_check"
require "mimemagic"
require "docsplit"
require "curb"
require "filemagic"
require "sinatra"

# Set key to encrypt to
ENV['gpg_recipient'] = "6684E718"
ENV['gpg_signer'] = "6684E718"

# Set urls to servers
ENV['indexserver_url'] = "http://localhost:9494"

# Load all files
Dir.glob('./app/{ocr,parsers,controllers}/*.rb').each { |file| require file }

run ApiController

