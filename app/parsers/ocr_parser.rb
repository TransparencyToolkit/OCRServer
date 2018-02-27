require "curb"
load 'app/parsers/metadata_parser.rb'

# Functions to OCR the documents
module OCRParser
  include MetadataParser
  
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
  def ocr_by_type(file, path)
    mime_subtype, mime_type = check_mime_type(file)
    full_path = "raw_documents/#{path}"

    case mime_subtype
    when "pdf"
      # First try to OCR using Tika (for embedded text)
      text = ocr_with_tika(full_path, mime_type, mime_subtype)

      # Tika OCR failed. Try Tesseract with Docsplit
      if text.strip.empty?
        text = ocr_with_docsplit(full_path, mime_subtype)
      end

      return text
    else
      
    end
  end

  # OCR embedded text PDFs with docsplit
  def ocr_with_docsplit(path, mime_subtype)
    Docsplit.extract_text(path, ocr: true, output: "raw_documents/text")
    return File.read(get_text_path(path, mime_subtype))
  end

  # OCR the file with tika
  def ocr_with_tika(path, mime_type, mime_subtype)
    # Make a Curl request to Tika
    c = Curl::Easy.new("http://localhost:9998/tika")
    file_data = File.read(path)
    c.headers['Content-Type'] = mime_type
    c.headers['Accept'] = "text/plain"
    c.http_put(file_data)
    text = c.body_str

    # Save and return the text
    File.write(get_text_path(path, mime_subtype), text)
    return text
  end

  # Get the path for the OCRed text 
  def get_text_path(path, mime_subtype)
    return path.gsub("raw_documents", "raw_documents/text").gsub(".#{mime_subtype}", ".txt")
  end  
end
