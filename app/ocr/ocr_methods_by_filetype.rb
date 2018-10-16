# Goes through a set of different OCR methods depending on file type, programs available, and success/failure
module OCRMethodsByFiletype
  # OCR PDFs
  def ocr_pdf(full_path, mime_type, mime_subtype)
    # First try to OCR using Tika (for embedded text PDF or html)
    text = fix_encoding(ocr_with_tika(full_path, mime_type, mime_subtype))

    # Tika OCR failed. Likely image style PDF. Try Tesseract with Docsplit or ABBYY
    if ocr_status_check(text) != "Success"
      text = fix_encoding(ocr_image(full_path, mime_subtype))
    end

    return text
  end

  # OCR office file formats
  def ocr_office_doc(full_path, mime_type, mime_subtype)
    text = fix_encoding(ocr_with_tika(full_path, mime_type, mime_subtype))

    # Tika OCR failed. Try with ABBYY
    if ocr_status_check(text) != "Success"
      begin
        text = fix_encoding(ocr_with_abbyy(full_path))
      rescue
      end
    end
    return text
  end

  # OCR images, using ABBYY when available or docsplit when not
  def ocr_image(file, mime_subtype)
    begin
      return ocr_with_abbyy(file)
    rescue
      return ocr_with_docsplit(file, mime_subtype)
    end
  end
end
