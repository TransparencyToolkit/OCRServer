module DetectFiletype
  # Check the mime type of the file
  def check_mime_type(file, path, full_path)
    begin # First try MimeMagic to detect type
      subtype = MimeMagic.by_magic(file).subtype
      type = MimeMagic.by_magic(file).type

      # Fix not actually pdf
      subtype, type = nil if path.include?("pd_") && !path.include?("pdf")
    rescue # If mime magic can't detect, use other methods
      subtype, type = file_magic_type(file, path, full_path)
    end

    # Remap depending on subtype
    if subtype
      # Catches .docx and similar that may be wrongly categorized
      subtype, type = officex_remap(file, path, full_path) if subtype == "zip" || subtype.include?("x-ole-storage")

      # Remap mime subtypes for office files with long names
      subtype, type = vnd_remap(subtype, type) if subtype.include?("vnd")

      # Remap email types
      subtype, type = "email", "message" if subtype.include?("rfc822")
    end
    
    return subtype, type
  end

  # Remap files that may be mistaken for zip files
  def officex_remap(file, path, full_path)
    # Get the type from the extension
    subtype, type = file_magic_type(file, path, full_path)

    # Remap to appropriate types
    remap_hash = {
      "docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "pptx" => "application/vnd.openxmlformats-officedocument.presentationml.presentation",
      "xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "ppt" => "application/vnd.ms-powerpoint",
      "xls" => "application/vnd.ms-excel",
      "key" => "application/vnd.apple.keynote"
    }
    type = remap_hash[subtype]
    
    return subtype, type
  end

  # Remap vnd formats to be more readable subtypes
  def vnd_remap(subtype, type)
    remap_hash = {
      "vnd.oasis.opendocument.text" => "odt",
      "vnd.oasis.opendocument.presentation" => "odp",
      "vnd.oasis.opendocument.spreadsheet" => "ods"
    }
    subtype = remap_hash[subtype]
    
    return subtype, type
  end

  # For when mimemagic type checks fail
  def file_magic_type(file, path, full_path)
    FileMagic.open(:mime) do |fm|
      if fm.file(full_path).include?("binary")
        return process_unknown_binary_file(path)
      elsif fm.file(full_path).include?("text")
        return process_unknown_text_file(file, path)
      end
    end
  end

  # Process text files of unknown type (html or text)
  def process_unknown_text_file(file, path)
    if path.include?(".eml")
      return "rfc822", "message"
    else
      return "txt", "txt"
    end
  end

  # Process an unknown binary file
  def process_unknown_binary_file(path)
    if path.include?(".")
      return get_file_type_from_extension(path)
    else
      return "binary", "binary"
    end
  end
  
  # Get the file type  from file extension (as last resort)
  def get_file_type_from_extension(path)
    subtype = path.split(".").last
    type = path.split(".").last
    return subtype, type
  end  
end
