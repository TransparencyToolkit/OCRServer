load 'app/decompress/extract_methods/zip_extract.rb'
load 'app/decompress/extract_methods/mbox_extract.rb'

# Decompress the file (unzip, untar, etc)
module DecompressFile
  include ZipExtract
  include MboxExtract

  # Decompress the file
  def decompress_by_type(mime_subtype, full_path)
    # Set and create path where decompressed should save
    save_dir = set_decompression_path(full_path)

    # Decompress different file types
    case mime_subtype
    when "zip"
      unzip(full_path, save_dir)
    when "mbox"
      split_mbox_to_eml(full_path, save_dir)
    end

    # Return location of files so OCR software can find them
    move_raw_uploaded(full_path)
    return save_dir
  end

  # Move compressed file initially uploaded so it doesn't keep running
  def move_raw_uploaded(full_path)
    FileUtils.mv(full_path, full_path.gsub(ENV['OCR_IN_PATH'], ENV['OCR_OUT_PATH']))
  end
  
  # Set and create the path to decompress to
  def set_decompression_path(full_path)
    file_name = full_path.gsub("#{ENV['OCR_IN_PATH']}/raw_docs/", "").gsub("#{ENV['OCR_IN_PATH']}/compressed/", "")
    save_file_path = "#{ENV['OCR_IN_PATH']}/compressed/"+file_name

    # Prepend random to compressed file (to avoid name collision)
    if File.exist?(save_file_path)
      split_file = file_name.split("/")
      split_file[-1] = SecureRandom.hex(5)+"_"+split_file.last
      return "#{ENV['OCR_IN_PATH']}/compressed/"+split_file.join("/")
    end
    return save_file_path
  end
end
