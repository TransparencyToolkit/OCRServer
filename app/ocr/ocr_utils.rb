# Misc functions to help manage the OCR process
module OCRUtils
  # Fix the encoding of the text string
  def fix_encoding(text)
    text.unpack('C*').pack('U*')
  end
  
  # Get the path for the OCRed text
  def get_text_path(path, mime_subtype)
    return path.gsub("raw_documents", "raw_documents/text").gsub(".#{mime_subtype}", ".txt")
  end
end
