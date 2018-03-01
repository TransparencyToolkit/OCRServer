# This sends OCRed documents to DocManager
class SendController
  extend UdpSend

  # Send file over UDP with UDP send module
  def self.send(file_details)
    send_file(file_details)
  end
end
