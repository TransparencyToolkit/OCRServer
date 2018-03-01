module UdpSend
  include DocIntegrityCheck

  # Send the file and metadata with UDP
  def send_file(file_details)
    # Send file to index
    encrypted_json = encrypt_data(JSON.pretty_generate([file_details]), ENV['gpg_recipient']).to_s
    prep_send_metadata(file_details, encrypted_json, "json")
    send_doc_json(file_details, encrypted_json)

    # Send document
    encrypted_file = encrypt_data(File.read(Dir.pwd+"/raw_documents/"+file_details[:rel_path]), ENV['gpg_recipient']).to_s
    prep_send_metadata(file_details, encrypted_file, "file")
    send_doc_json(file_details, encrypted_file)
  end
  
  # Slice string into appropriate size chuks for UDP
  def slice_string(str)
    size = 60000
    return Array.new(((str.length + size - 1) / size)) { |i| str.byteslice(i * size, size) }
  end

  # Send data over UDP to OCR server. Must be in hash or other format convertable to JSON
  def send_data(data)
    s = UDPSocket.new
    s.send(JSON.generate(data), 0, 'localhost', 1235)
    s.close
  end

  # Parse the metadata, encrypt it, and send it to OCR server
  def prep_send_metadata(json, encrypted_json, json_or_file)
    # Get hash and number of slices
    hashed_json = hash_file(encrypted_json)
    num_slices = slice_string(encrypted_json).length

    # Prep the metadata
    metadata = {
      num_slices: num_slices,
      file_hash: hashed_json,
      type: json_or_file,
      index_name: json[:index_name],
      item_type: json[:item_type],
      rel_path: json[:rel_path]
    }
    
    # Encrypt and send the metadata
    encrypted_metadata = encrypt_data(JSON.pretty_generate([metadata]), ENV['gpg_recipient'])

    # Send the metadata
    send_data({metadata: encrypted_metadata.to_s})
  end

  # Send uploaded doc specified
  def send_doc_json(json, encrypted_json)
    # Encrypt and hash the JSON
    hashed_json = hash_file(encrypted_json)
    
    # Send each slice of the doc (chunks of 60000 bytes so that UDP can handle it)
    sliced = slice_string(encrypted_json.to_s)
    sliced.each_with_index do |slice, i|
      send_data({chunk_num: i, hash: hashed_json, slice: slice})
    end
  end
end
