# Goes through a set of different OCR methods depending on file type, programs available, and success/failure
module OCRMethodsByFiletype
  # OCR PDFs
  def ocr_pdf(full_path, mime_type, mime_subtype)
    # First try to OCR using Tika (for embedded text PDF or html)
    text = ocr_with_tika(full_path, mime_type, mime_subtype)

    # Tika OCR failed. Likely image style PDF. Try Tesseract with Docsplit or ABBYY
    if ocr_status_check(text) != "Success"
      text = ocr_image(full_path, mime_subtype, mime_type)
    end

    return text
  end

  # OCR office file formats
  def ocr_office_doc(full_path, mime_type, mime_subtype)
    # Make a PDF of most office formats
    no_pdf = ["html", "htm", "xml", "key"]
    generate_pdf_of_doc(full_path, mime_subtype) if !no_pdf.include?(mime_subtype.downcase)
    
    # Try OCRing with Tika
    text = ocr_with_tika(full_path, mime_type, mime_subtype)

    # Tika OCR failed. Try with ABBYY
    if ocr_status_check(text) != "Success"
      begin
        text = ocr_with_abbyy(full_path)
      rescue
      end
    end
    return text
  end

  # OCR images, using ABBYY when available or docsplit when not
  def ocr_image(file, mime_subtype, mime_type)
    begin
      return ocr_with_abbyy(file)
    rescue
      # If a PDF, use docsplit as tesseract works best with image-style pdfs
      if mime_subtype.downcase.include?("pdf")
        return ocr_with_docsplit(file, mime_subtype)
      else # If not a pdf, try with tika
        return ocr_with_tika(file, mime_type, mime_subtype)
      end
    end
  end

  # OCR emails
  def ocr_mail(full_path, mime_subtype, mime_type)
    return ocr_rfc822(full_path)
  end
end
