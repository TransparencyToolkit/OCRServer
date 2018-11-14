# OCRs the document with ABBYY if available
module AbbyyOCR
  # OCR the file
  def ocr_with_abbyy(file)
    text = %x[abbyyocr11 -c -if #{"'"+file+"'"} -f TextVersion10Defaults -tel -tet UTF8 -tcp Latin].gsub(/\xef\xbb\xbf/, "")

    # Only return text from ABBYY if it exited successfully
    if $?.to_s.split("exit ").last == "0"
      return text
    else
      throw Error
    end
  end
end
