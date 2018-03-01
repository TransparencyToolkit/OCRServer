# This parses and saves input received from the upload form
module InputParser
  include DocIntegrityCheck
  include OCRManager
  include MetadataExtractGen
  
  # Decrypt metadata and add to file list
  def parse_metadata(metadata)
    # Decrypt the metadata
    decrypted = JSON.parse(decrypt(metadata))

    # Add metadata on each file to a hash
    decrypted.each do |file|
      @file_list[file["file_hash"]] = file.merge(slices_in: 0, encrypted_text: "", ocr_status: "Incomplete File")
    end
  end

  # Decrypt and process each chunk of the file that comes in
  def parse_file_chunk(chunk)
    file_details = @file_list[chunk["hash"]]

    # Increment the slice count for the file and append the text to text length
    file_details[:slices_in] += 1
    file_details[:encrypted_text] += chunk["slice"]

    # If file is fully received, decrypt it
    if file_fully_received?(file_details)
      decrypt_and_save_file(file_details)
    end
  end

  # Saves files that have fully arrived
  def decrypt_and_save_file(file_details)
    # Decrypt the file and save as object (if it matches the hash)
    file_details[:decrypted_file] = decrypt(file_details[:encrypted_text])

    # Save decrypted file as file
    file_name = file_details["file_path"].gsub(".gpg", "")
    File.write("raw_documents/#{file_name}", file_details[:decrypted_file])

    # OCR the file and check that it completed
    file_details[:text] = ocr_by_type(file_details[:decrypted_file], file_name)
    file_details[:ocr_status] = ocr_status_check(file_details[:text])
    add_metadata_to_file(file_details)

    # Add index name and item type
    file_details[:index_name] = file_details["project"]
    file_details[:item_type] = file_details["doc_type"]

    # Send file out
    SendController.send(filter_fields(file_details))
  end

  # Filter for just the approved list of fields in the dataspec
  def filter_fields(file_details)
    approved_fields = [:text, :title, :description, :date_added, :filetype, :ocr_status, :index_name, :item_type, :rel_path]
    return file_details.select{|k, v| approved_fields.include?(k)}
  end

  # Check if the number of expected slices equals the number of received slices AND that the hash is the same
  def file_fully_received?(file_details)
    return (file_details[:slices_in] == file_details["num_slices"]) && hash_verified?(file_details)
  end
end
