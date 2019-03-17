# Misc functions to help manage the OCR process
module OCRUtils
  # Fix the encoding of the text string
  def fix_encoding(text)
    text.unpack('C*').pack('U*')
  end
  
  # Get the path for the OCRed text
  def get_text_path(path, mime_subtype)
    split_path = path.split(".")

    # Set path to documents with extension
    if split_path.length > 1
      extension = "."+split_path.last
      return path.gsub(ENV['OCR_IN_PATH'], "#{ENV['OCR_IN_PATH']}/text").gsub(extension, ".txt")
    else # Set path to documents without extension
      return path.gsub(ENV['OCR_IN_PATH'], "#{ENV['OCR_IN_PATH']}/text")+".txt"
    end
  end
end
