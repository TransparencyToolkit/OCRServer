# Misc functions to help manage the OCR process
module OCRUtils
  # Get the path for the OCRed text
  def get_text_path(path, mime_subtype)
    return path.gsub("raw_documents", "raw_documents/text").gsub(".#{mime_subtype}", ".txt")
  end
end
