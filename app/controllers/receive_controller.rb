# This receives documents send by the upload form and passes them to be OCRed
class ReceiveController
  extend InputParser
  extend UdpListen

  # List for data to receive via UDP
  listen_for_data
end
