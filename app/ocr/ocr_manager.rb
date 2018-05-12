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
    when "pdf", "html"
      # First try to OCR using Tika (for embedded text PDF or html)
      text = fix_encoding(ocr_with_tika(full_path, mime_type, mime_subtype))

      # Tika OCR failed. Try Tesseract with Docsplit
      if text.strip.empty? && mime_subtype == "pdf"
        text = fix_encoding(ocr_with_docsplit(full_path, mime_subtype))
      end

      return text
    when "txt"
      return file
    when "bmp", "png", "gif", "tiff", "tif", "jpeg", "svg+xml"
      return fix_encoding(ocr_with_docsplit(full_path, mime_subtype)) 
    else
      
    end
  end
end
