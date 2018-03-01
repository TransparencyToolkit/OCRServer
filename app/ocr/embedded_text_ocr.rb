# Method for embedded text OCR of files with DocSplit and Tesseract
module EmbeddedTextOCR
  include OCRUtils
  
  # OCR embedded text PDFs with docsplit
  def ocr_with_docsplit(path, mime_subtype)
    Docsplit.extract_text(path, ocr: true, output: "raw_documents/text")
    return File.read(get_text_path(path, mime_subtype))
  end
end
