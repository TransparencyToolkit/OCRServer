# Adds metadata about the file to the JSON, automatically generates titles, etc
module MetadataExtractGen
  # Add metadata to thee file
  def add_metadata_to_file(file_details)
    # Add ID field (file hash and name)
    file_details[:rel_path] = file_details["file_path"].gsub(".gpg", "")
    
    # Add title and description
    file_details[:title] = add_title(file_details, file_details[:filetype])
    file_details[:description] = file_details["doc_desc"]

    # Add field with date added
    file_details[:date_added] = Time.now
  end

  # Extract the metadata
  def extract_metadata(file_details, path)
    metadata = Hash.new
    metadata[:date] = Docsplit.extract_date(path)
    metadata[:author] = Docsplit.extract_author(path)
    metadata[:creator] = Docsplit.extract_creator(path)
    metadata[:producer] = Docsplit.extract_producer(path)
    metadata[:keywords] = Donsplit.extract_keywords(path)
    return metadata
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
