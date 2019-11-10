# Adds metadata about the file to the JSON, automatically generates titles, etc
module MetadataExtractGen
  # Add metadata to thee file
  def add_metadata_to_file(metadata, ocr_hash)
    # Add title and description
    ocr_hash[:file_hash] = get_hash(@file)
    ocr_hash[:lg_pdf_view] = @lg_pdf_view
    ocr_hash[:title] = add_title(metadata, ocr_hash)
    ocr_hash[:description] = metadata["doc_desc"] if metadata
    
    # Add field with date added
    ocr_hash[:date_added] = Time.now
  end

  # Get the hash for the file
  def get_hash(path)
    file_read = File.read(path)
    return Digest::MD5.hexdigest(file_read)
  end

  # Extract the metadata
  def extract_metadata(file_details, path)
    metadata = Hash.new
    metadata[:date] = Docsplit.extract_date(path)
    metadata[:author] = Docsplit.extract_author(path)
    metadata[:creator] = Docsplit.extract_creator(path)
    metadata[:producer] = Docsplit.extract_producer(path)
    metadata[:keywords] = Docsplit.extract_keywords(path)
    return metadata
  end

  # Generate a title for the document
  def add_title(metadata, ocr_hash)
    # If title isn't empty, use that
    if metadata && metadata["doc_title"] && !metadata["doc_title"].empty?
      return metadata["doc_title"]
      
    else # Trim file name and automatically generate a title
      trimmed_name = @file.split("/").last.split(".#{ocr_hash[:filetype]}")[0]
      md5_removed = trimmed_name.gsub(ocr_hash[:file_hash]+"_", "")
      return md5_removed.gsub("_", " ").gsub("/", "").gsub("-", " ").split.map(&:capitalize).join(" ")
    end
  end
end
