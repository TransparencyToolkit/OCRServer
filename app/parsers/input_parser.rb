# This parses and saves input received from the upload form
module InputParser
  include DocIntegrityCheck
  include OCRManager
  include MetadataExtractGen
  include DetectFiletype
  include SendParser
  
  # Process the file
  def process_file(params)
    # Parse out the parameters
    metadata = JSON.parse(decrypt(params["metadata"]))
    file = decrypt(params["file"])

    # Save and OCR file
    file_name = metadata["file_path"].gsub(".gpg", "")
    full_path = save_decrypted_file(file, file_name)
    ocr_hash = ocr_file(metadata, file, file_name, full_path)
    filtered = prepare_data_to_index(ocr_hash, metadata)
    send_file(filtered)
  end

  # Save the decrypted file as a file path
  def save_decrypted_file(file, file_name)
    full_path = "raw_documents/#{file_name}"
    File.write(full_path, file)
    return full_path
  end

  # Add metadataand index info
  def prepare_data_to_index(ocr_hash, metadata)
    ocr_hash[:index_name] = metadata["project"]
    ocr_hash[:item_type] = metadata["doc_type"]
    add_metadata_to_file(metadata, ocr_hash)
    filtered = filter_fields(ocr_hash)
  end
  
  # OCR the file
  def ocr_file(metadata, file, file_name, full_path)
    ocr_hash = Hash.new

    # OCR the file
    ocr_hash[:filetype], mime_type = check_mime_type(file, file_name, full_path)
    ocr_hash[:text] = ocr_by_type(file, file_name, full_path, ocr_hash[:filetype], mime_type)
    ocr_hash[:ocr_status] = ocr_status_check(ocr_hash[:text])
    ocr_hash[:rel_path] = file_name
    return ocr_hash
  end

  # Filter for just the approved list of fields in the dataspec
  def filter_fields(file_details)
    approved_fields = [:text, :title, :description, :date_added, :filetype, :ocr_status, :index_name, :item_type, :rel_path]
    return file_details.select{|k, v| approved_fields.include?(k)}
  end
end
