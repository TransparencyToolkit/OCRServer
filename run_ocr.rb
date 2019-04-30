require "pry"
require "json"
require "mimemagic"
require "docsplit"
require "curb"
require "ruby-filemagic"
require "zip"
require "securerandom"

Dir.glob('./app/{ocr,decompress,input_output}/*.rb').each { |file| require file }

ENV['OCR_IN_PATH'] = "/home/user/ocr_in" if ENV['OCR_IN_PATH'] == nil
ENV['OCR_OUT_PATH'] = "/home/user/ocr_out" if ENV['OCR_OUT_PATH'] == nil
ENV['PROJECT_INDEX'] = "archive_test" if ENV['PROJECT_INDEX'] == nil

l = LoadFiles.new(ENV['OCR_IN_PATH'], ENV['OCR_OUT_PATH'])
l.listen_for_files

