# Generates a PDF with Unoconv for office formats
module UnoconvPdf
  
  # Generate a PDF of office documents
  def generate_pdf_of_doc(path, mime_subtype)
    # Setup the doctype and path needed
    doctype = get_doc_type(mime_subtype)
    @lg_pdf_view, lg_pdf_path = set_pdf_version_path(path)

    # Convert file
    clean_path = '"'+path+'"'
    system("unoconv --doctype #{doctype} --output #{lg_pdf_path} -f pdf #{clean_path}")
  end

  # Set output path
  def set_pdf_version_path(path)
    lg_pdf_path = ENV['OCR_OUT_PATH']+"/lg_pdf_view/"+get_hash(path)+".pdf"
    return [[path.split("/").last, lg_pdf_path]], lg_pdf_path
  end

  # Determine the type of the file
  def get_doc_type(mime_subtype)
    case mime_subtype.downcase
    when "odt", "doc", "docx", "rtf", "msword", "wbk"
      return "document"
    when "xls", "xlsx", "ods"
      return "spreadsheet"
    when "pptx", "ppt", "odp"
      return "presentation"
    end
  end
end
