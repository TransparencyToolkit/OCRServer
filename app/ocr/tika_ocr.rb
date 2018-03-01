require "curb"

# Methods for OCRing files with Tika
module TikaOCR
  include OCRUtils
  
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
end
