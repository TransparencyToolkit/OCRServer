load 'app/ocr/metadata_extract_gen.rb'
load 'app/ocr/ocr_utils.rb'
load 'app/ocr/tika_ocr.rb'
load 'app/ocr/image_style_pdf_ocr.rb'

# Manages the OCR process by routing to appropriate method for doc type, checking if it worked, etc.
module OCRManager
  include MetadataExtractGen
  include OCRUtils
  include TikaOCR
  include ImageStylePdfOCR
  
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
      # First try to OCR using Tika (for embedded text PDF or html)
      text = fix_encoding(ocr_with_tika(full_path, mime_type, mime_subtype))

      # Tika OCR failed. Try Tesseract with Docsplit
      if text.strip.empty? 
        text = fix_encoding(ocr_with_docsplit(full_path, mime_subtype))
      end

      return text

    # Office docs and HTML
    when "rtf", "msword", "docx", "odt", "ppt", "pptx", "odp", "xls", "xlsx", "ods", "html", "xml", "key"
      text = fix_encoding(ocr_with_tika(full_path, mime_type, mime_subtype))
      
    # Text formats
    when "txt", "sql", "json", "csv"
      return fix_encoding(file)

    # Image formats
    when "bmp", "png", "gif", "tiff", "tif", "jpeg", "svg+xml"
      return fix_encoding(ocr_with_docsplit(full_path, mime_subtype)) 
    else
      # It isn't a file type that supports OCR with our software
    end
  end
end
