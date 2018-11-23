require 'pry'
require 'json'

class LocalOcr
  include OCRManager
  include MetadataExtractGen
  include DetectFiletype
  
  def initialize(in_dir, out_dir)
    @in_dir = in_dir
    @out_dir = out_dir
  end

  # Set the save name
  def set_save_name(file)
    save_name = file.gsub(@in_dir, "").gsub("/", "_")+".json"
    if save_name.length > 255
      extension = file.gsub(@in_dir, "").gsub("/", "_").split(".").last
      return file.gsub(@in_dir, "").gsub("/", "_").gsub(".#{extension}", "")[0..230]+".#{extension}.json"
    end
    return save_name
  end

  # Go through files in path and OCR
  def loop_through_files
    Dir.glob("#{@in_dir}/**/*") do |file|
      if File.file?(file)
        save_name = set_save_name(file)

        # Only OCR if not already
        if !File.exist?(@out_dir+save_name)
          json = ocr(file, save_name)
          File.write(@out_dir+save_name, json)
          puts "OCRed #{save_name}"
        end
      end
    end
  end

  # OCR a file
  def ocr(file_path, save_name)
    name = file_path.split("/").last
    file_details = Hash.new
    content = File.read(file_path)
      
    # Set paths
    file_details[:rel_path] = file_path.gsub(@in_dir, "")
    file_details[:full_path] = file_path.gsub(@in_dir, "")

    # Set folders and title
    file_details[:folders] = file_details[:rel_path].split("/").reject!(&:empty?)-[name]
    file_details[:title] = file_details[:rel_path].split("/").join(" ").strip.lstrip.gsub("_", " ").gsub(".#{file_details[:filetype]}", "")

    # OCR
    file_details = file_details.merge(ocr_file(content, name, file_path))
    
    begin
      return JSON.pretty_generate(file_details)
    rescue # Fix encoding if JSON generate fails (but not otherwise to avoid causing issues with text)
      puts "Encoding issue, attempting to fix..."
      begin
        file_details[:text] = file_details[:text].to_s.force_encoding('UTF-8') if file_details[:text]
        file_details[:body] = file_details[:body].to_s.force_encoding('UTF-8') if file_details[:body]
        file_details[:attachment_text] = file_details[:attachment_text].to_s.force_encoding('UTF-8') if file_details[:attachment_text]
        return JSON.pretty_generate(file_details)
      rescue
        puts "That failed. Trying to fix in another way."
        file_details[:text] = fix_encoding(file_details[:text].to_s) if file_details[:text]
        file_details[:body] = fix_encoding(file_details[:body].to_s) if file_details[:body]
        file_details[:attachment_text] = fix_encoding(file_details[:attachment_text].to_s) if file_details[:attachment_text]
        return JSON.pretty_generate(file_details)
      end
    end
  end
end
