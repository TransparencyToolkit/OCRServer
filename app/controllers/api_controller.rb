class ApiController < Sinatra::Base
  include InputParser
  
  post "/ocr" do
    process_file(params)
  end
end
