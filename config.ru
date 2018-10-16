require "pry"
require "json"
require "doc_integrity_check"
require "mimemagic"
require "docsplit"
require "curb"
require "filemagic"
require "sinatra"

# Set key to encrypt to
ENV['gpg_recipient'] = "6684E718" if ENV['gpg_recipient'] == nil
ENV['gpg_signer'] = "6684E718" if ENV['gpg_signer'] == nil

# Set urls to servers
ENV['indexserver_url'] = "http://localhost:9494" if ENV['indexserver_url'] == nil

# Load all files
Dir.glob('./app/{ocr,parsers,controllers}/*.rb').each { |file| require file }

run ApiController

