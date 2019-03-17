require "pry"
require "json"
require "mimemagic"
require "docsplit"
require "curb"
require "filemagic"


Dir.glob('./app/{ocr,input_output}/*.rb').each { |file| require file }

ENV['OCR_IN_PATH'] = "/home/user/ocr_in" if ENV['OCR_IN_PATH'] == nil
ENV['OCR_OUT_PATH'] = "/home/user/ocr_out" if ENV['OCR_OUT_PATH'] == nil

l = LoadFiles.new(ENV['OCR_IN_PATH'], ENV['OCR_OUT_PATH'])
l.load_and_ocr_all

