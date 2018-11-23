load 'app/ocr/metadata_extract_gen.rb'
load 'app/ocr/ocr_utils.rb'
load 'app/ocr/ocr_methods/tika_ocr.rb'
load 'app/ocr/ocr_methods/tesseract_ocr.rb'
load 'app/ocr/ocr_methods/abbyy_ocr.rb'
load 'app/ocr/ocr_methods/eml_ocr.rb'
load 'app/ocr/ocr_methods_by_filetype.rb'
load 'app/ocr/detect_filetype.rb'

# Manages the OCR process by routing to appropriate method for doc type, checking if it worked, etc.
module OCRManager
  include MetadataExtractGen
  include OCRUtils
  include TikaOCR
  include TesseractOCR
  include AbbyyOCR
  include EmlOCR
  include OCRMethodsByFiletype
  include DetectFiletype

  # OCR the file
  def ocr_file(file, file_name, full_path)
    ocr_hash = Hash.new

    # File details 
    ocr_hash[:filetype], mime_type = check_mime_type(file, file_name, full_path)
    
    # OCR file
    output = ocr_by_type(file, file_name, full_path, ocr_hash[:filetype], mime_type)
    if output.is_a?(Hash)
      ocr_hash = ocr_hash.merge(output)
    else
      ocr_hash[:text] = output
    end

    # Check the status of the OCR
    fields_to_check = [:text, :body, :attachment_text]
    text_fields = ocr_hash.to_a.select{|f| fields_to_check.include?(f[0])}.map{|t| t[1]}
    ocr_hash[:ocr_status] = text_fields.map{|f| ocr_status_check(f)}.uniq
    
    return ocr_hash
  end
  
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
      return file

    # Image formats
    when "bmp", "png", "gif", "tiff", "tif", "jpeg", "svg+xml"
      return ocr_image(full_path, mime_subtype, mime_type)

    # Email OCR formats
    when "rfc822", "email"
      return ocr_mail(full_path, mime_subtype, mime_type)
    else
      # It isn't a file type that supports OCR with our software
    end
  end
end
