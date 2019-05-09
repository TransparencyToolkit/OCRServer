require 'pry'
require 'json'
require 'listen'
load 'app/input_output/process_single_files.rb'
load 'app/decompress/decompress_file.rb'

# Load files from a directory and decompress as needed
class LoadFiles
  include DetectFiletype
  include DecompressFile

  def initialize(in_dir, out_dir)
    @in_dir = in_dir
    @out_dir = out_dir
  end

  # Listen for new files to OCR
  def listen_for_files
    # OCR if there are new files
    listener = Listen.to("#{@in_dir}/raw_docs/") do |_, new, _|
      load_and_ocr_all(new) if new
    end
    listener.start

    # Keep listening
    loop do
      sleep(0.5)
    end
  end

  # Check if file is a compressed file
  def is_compressed?(mime_subtype)
    compressed_mime_types = ["zip", "mbox"]

    # Check if mime type matches any on the compressed list
    return compressed_mime_types.select{|c| mime_subtype.downcase == c}.length > 0
  end

  # These files should be skipped entirely (and not included even without OCR)
  def skip_file?(mime_subtype)
    skip_mime_types = ["lnk"]

    # Check if mime type matches any on the skip list
    return skip_mime_types.select{|c| mime_subtype.downcase == c}.length > 0
  end

  # Process the compressed file
  def process_compressed(file_path, mime_subtype)
    extracted_files_path = decompress_by_type(mime_subtype, file_path)
    save_ocred_path = extracted_files_path.gsub(ENV['OCR_IN_PATH'], ENV['OCR_OUT_PATH'])
    l = LoadFiles.new(extracted_files_path, save_ocred_path)
    load_and_ocr_all(Dir.glob(extracted_files_path+"/**/*"))
  end

  # Get the file type and mime type
  def read_file_and_check_type(file)
    file_content = File.read(file)
    subtype, type = check_mime_type(file_content, file.split("/").last, file)
    return file_content, subtype
  end

  # Load in all files
  def load_and_ocr_all(files_to_ocr)
    files_to_ocr.each do |file|
      # Process if file rather than folder
      if File.file?(file)
        file_content, subtype = read_file_and_check_type(file)
        
        # Check if it is a compressed file
        if is_compressed?(subtype)
          process_compressed(file, subtype)
        elsif !skip_file?(subtype) # Is normal file- OCR directly
          metadata = load_metadata(file)
          p = ProcessSingleFiles.new(file, file_content, metadata, @in_dir, @out_dir)
          p.process_file
        end
      end
    end
  end

  # Load the file metadata (if it exists)
  def load_metadata(file)
    metadata_path = "#{@in_dir}/metadata/#{file.split("/").last}.json"

    # Load in the metadata
    if File.exist?(metadata_path)
      return JSON.parse(File.read(metadata_path)).to_hash
    end
  end
end
