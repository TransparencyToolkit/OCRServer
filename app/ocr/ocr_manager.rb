load 'app/ocr/metadata_extract_gen.rb'
load 'app/ocr/ocr_utils.rb'
load 'app/ocr/ocr_methods/tika_ocr.rb'
load 'app/ocr/ocr_methods/tesseract_ocr.rb'
load 'app/ocr/ocr_methods/abbyy_ocr.rb'
load 'app/ocr/ocr_methods_by_filetype.rb'

# Manages the OCR process by routing to appropriate method for doc type, checking if it worked, etc.
module OCRManager
  include MetadataExtractGen
  include OCRUtils
  include TikaOCR
  include TesseractOCR
  include AbbyyOCR
  include OCRMethodsByFiletype
  
  # Check if the OCR succeeded
  def ocr_status_check(text)
    # No OCRed data available
    if text == nil
      return "Failed"

    # OCR is empty but seems to have run through OCR software
    elsif text.strip.empty?
      return "Empty"

    # Tika error in OCRed documents
    elsif text.include?("java.io.IOException: Stream Closed")
      return "Tika Error"
      
    # Check if there is substantial text
    elsif /[\w|\W]{100,}/.match?(text) && /[a-zA-Z]{5,}/.match?(text)
      return "Success"
      
    else # No substantial text, but not empty either
      return "Indeterminate"
    end
  end

  # Choose the type of file to index
  def ocr_by_type(file, path, full_path, mime_subtype, mime_type)
    case mime_subtype
    when "pdf"
      return ocr_pdf(full_path, mime_type, mime_subtype)

    # Office docs and HTML
    when "rtf", "msword", "docx", "odt", "ppt", "pptx", "odp", "xls", "xlsx", "ods", "html", "xml", "key"
      return ocr_office_doc(full_path, mime_type, mime_subtype)
      
    # Text formats
    when "txt", "sql", "json", "csv"
      return fix_encoding(file)

    # Image formats
    when "bmp", "png", "gif", "tiff", "tif", "jpeg", "svg+xml"
      return fix_encoding(ocr_image(full_path, mime_subtype, mime_type))
    else
      # It isn't a file type that supports OCR with our software
    end
  end
end
