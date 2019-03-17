# Method for image style PDF  OCR of files with DocSplit/Tesseract
module TesseractOCR
  include OCRUtils
    
  # OCR embedded text PDFs with docsplit
  def ocr_with_docsplit(path, mime_subtype)
    # OCR document
    `docsplit text #{"'"+path+"'"}  --pages all --output #{ENV['OCR_IN_PATH']}/text`

    # Collect text
    text = ""
    base_path = path.split("/").last.gsub("."+mime_subtype, "")
    text_files = Dir.glob("#{ENV['OCR_IN_PATH']}/text/#{base_path}_*.txt")
    text_files.length.times do |num|
      text += File.read("#{ENV['OCR_IN_PATH']}/text/#{base_path}_#{num+1}.txt")
    end

    # Delete the files after reading
    text_files.each{|file| system('rm "'+file+'"')}
    
    return text
  end
end
