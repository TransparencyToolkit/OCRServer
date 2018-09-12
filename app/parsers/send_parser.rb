module SendParser
  include DocIntegrityCheck

  # Send the file and metadata with UDP
  def send_file(json_data)
    # Send JSON to index
    encrypted_json = encrypt_data(JSON.pretty_generate([json_data]), ENV['gpg_recipient'], ENV['gpg_signer']).to_s
    metadata = prep_metadata(json_data, "json")
    send_data(encrypted_json, metadata)
    
    # Send document to be saved
    encrypted_file = encrypt_data(File.read(Dir.pwd+"/raw_documents/"+json_data[:rel_path]), ENV['gpg_recipient'], ENV['gpg_signer']).to_s 
    metadata = prep_metadata(json_data, "file")
    send_data(encrypted_file, metadata)
  end

  # Send data over UDP to OCR server. Must be in hash or other format convertable to JSON
  def send_data(content, metadata)
    formatted = {metadata: metadata, content: content}
    url = ENV['indexserver_url']+"/index"
    Curl.post(url, formatted)
  end

  # Prepared the metadata to send
  def prep_metadata(json_data, json_or_file)
    metadata = {
      index_name: json_data[:index_name],
      item_type: json_data[:item_type],
      rel_path: json_data[:rel_path],
      type: json_or_file
    }
    
    return encrypt_data(JSON.pretty_generate([metadata]), ENV['gpg_recipient'], ENV['gpg_signer'])
  end
end
