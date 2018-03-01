module UdpListen
  def listen_for_data
    # Open UDP socket to receive data
    @socket = UDPSocket.new
    @socket.bind(nil, 1234)

    # List of files program is expecting to receive
    @file_list = Hash.new

    # Process incoming messages to socket
    Socket.udp_server_loop_on([@socket]) do |message, sender|
      parsed = JSON.parse(message)

      # Handle metadata- setup doc list
      if parsed["metadata"]
        parse_metadata(parsed["metadata"])

        # Process each file slice as it comes in
      elsif parsed["chunk_num"]
        parse_file_chunk(parsed)
      end
    end
  end
end
