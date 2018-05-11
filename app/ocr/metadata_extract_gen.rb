# Adds metadata about the file to the JSON, automatically generates titles, etc
module MetadataExtractGen
  # Add metadata to thee file
  def add_metadata_to_file(file_details)
    # Add ID field (file hash and name)
    file_details[:rel_path] = file_details["file_path"].gsub(".gpg", "")
    
    # Add data on the file type
    file_details[:filetype] = check_mime_type(file_details[:decrypted_file], file_details[:rel_path])[0]
      
    # Add title and description
    file_details[:title] = add_title(file_details, file_details[:filetype])
    file_details[:description] = file_details["doc_desc"]

    # Add field with date added
    file_details[:date_added] = Time.now
  end

  # Check the mime type of the file
  def check_mime_type(file, path)
    begin
      subtype = MimeMagic.by_magic(file).subtype
      type = MimeMagic.by_magic(file).type
    rescue # If mime magic can't detect, use extension
      subtype = path.split(".").last
      type = path.split(".").last
    end
    return subtype, type
  end

  # Generate a title for the document
  def add_title(file_details, mime_type)
    # If title isn't empty, use that
    if file_details["doc_title"] && !file_details["doc_title"].empty?
      return file_details["doc_title"]
      
    else # Trim file name and automatically generate a title
      trimmed_name = file_details["file_path"].split("_", 2)[1].split(".#{mime_type}")[0]
      return trimmed_name.gsub("_", " ").gsub("/", "").gsub("-", " ").split.map(&:capitalize).join(" ")
    end
  end
end
