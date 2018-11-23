require "pry"
require "json"
require "doc_integrity_check"
require "mimemagic"
require "docsplit"
require "curb"
require "filemagic"


Dir.glob('./app/{ocr,local}/*.rb').each { |file| require file }

in_path = ""
out_path = ""
ENV['attachment_save_path'] = "raw_documents"

l = LocalOcr.new(in_path, out_path)
l.loop_through_files


