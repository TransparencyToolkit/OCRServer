# OCRs the document with ABBYY if available
module AbbyyOCR
  # OCR the file
  def ocr_with_abbyy(file)
    return %x[abbyyocr11 -c -if #{"'"+file+"'"} -f TextVersion10Defaults -tel -tet UTF8 -tcp Latin].gsub(/\xef\xbb\xbf/, "")
  end
end
