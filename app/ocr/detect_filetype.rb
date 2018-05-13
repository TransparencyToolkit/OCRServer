module DetectFiletype
  # Check the mime type of the file
  def check_mime_type(file, path, full_path)
    begin
      subtype = MimeMagic.by_magic(file).subtype
      type = MimeMagic.by_magic(file).type
    rescue # If mime magic can't detect, use other methods
      subtype, type = file_magic_type(file, path, full_path)
    end
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
    return "txt", "txt"
  end

  # Process an unknown binary file
  def process_unknown_binary_file(path)
    if path.include?(".")
      return get_file_type_from_extension(path)
    else
      return "binary", "binary"
    end
  end
  
  # Get the file type
  def get_file_type_from_extension(path)
    subtype = path.split(".").last
    type = path.split(".").last
    return subtype, type
  end  
end
