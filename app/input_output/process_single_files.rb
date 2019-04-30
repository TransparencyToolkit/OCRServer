require 'pry'
require 'json'

# Process and OCR single files
class ProcessSingleFiles
  include OCRManager
  include DetectFiletype
  include MetadataExtractGen

  def initialize(file, file_content, metadata, in_dir, out_dir)
    @file = file
    @file_content = file_content
    @metadata = metadata
    @in_dir = in_dir
    @out_dir = out_dir
  end

  # Process the individual file
  def process_file
    ocred_file = ocr
    json_out = prep_json(ocred_file)
    save_file(json_out)
  end

  # Save the file
  def save_file(json_out)
    ocred_metadata = JSON.parse(json_out)
    
    # Move raw file to out path
    FileUtils.mv(@file, ocred_metadata['full_path'])

    # Save metadata file
    File.write("#{@out_dir}/ocred_docs/#{ocred_metadata['rel_path']}.json", json_out)
  end

  # Set the save name for the file (accounts for > 250 chars or directories in name)
  def set_save_name
    # Include directories in saved name
    save_name = @file.gsub("#{@in_dir}/raw_docs/", "").gsub("#{@in_dir}/compressed/", "").gsub("/", "_")
    
    # Handle names that are above file system limit
    if save_name.length > 250
      extension = save_name.split(".").last
      save_name = save_name.gsub(".#{extension}", "")[0..230]+".#{extension}"
    end

    return save_name
  end

  # Determine the document type class that should be used when indexing the document
  def determine_doc_type(filetype)
    case filetype
    when "eml", "pst", "mbox", "email", "message"
      return "Email"
    else # This is the best option for most file formats
      return "ArchiveDoc"
    end
  end

  # Offer two options for getting the project index (for use with and without pipeline)
  def get_project_index
    if @metadata && @metadata["project"]
      return @metadata["project"]
    else
      return ENV['PROJECT_INDEX']
    end
  end

  # Get array of folders
  def get_folders(full_path, rel_path)
    folders = @file.gsub("#{@in_dir}/raw_docs/", "").gsub("#{@in_dir}/compressed/", "").split("/").reject(&:empty?)[0...-1]

    # Remap folders to remove prefix before compressed dirs
    return folders.map do |folder|
      if folder.include?(".")
        folder = folder.split("_", 2).last
      end
      folder
    end
  end

  # Prepare the OCRed JSON
  def prep_json(ocred_file)
    # Add paths and folders
    ocred_file[:rel_path] = set_save_name
    ocred_file[:full_path] = "#{@out_dir}/raw_docs/#{ocred_file[:rel_path]}"
    ocred_file[:folders] = get_folders(ocred_file[:full_path], ocred_file[:rel_path])
    
    # Adds title, description, date_added to OCRed hash
    add_metadata_to_file(@metadata, ocred_file)
    
    # Add fields for index manager
    ocred_file[:index_fields] = {
      index_name: get_project_index,
      item_type: determine_doc_type(ocred_file[:filetype])
    }

    return gen_json(ocred_file)
  end

  # OCR the file
  def ocr
    # Get path and read file 
    file_name = @file.split("/").last

    # OCR file
    puts "OCRing #{@file}"
    return ocr_file(@file_content, file_name, @file)
  end

  # Generate the JSON of the file and handle encoding issues
  def gen_json(ocred_file)
    begin # Generate JSON without any encoding fixes
      return JSON.pretty_generate(ocred_file)
    rescue
      puts "Encoding issue, attempting to fix..."
      begin # Fix encoding issue by forcing UTF-8 encoding
        return JSON.pretty_generate(ocred_file.to_a.map do |field|
                                      field[1] = field[1].force_encoding('UTF-8') if field[1].class == String
                                      [field[0], field[1]]
                                    end.to_h)
      rescue # Fix encoding with pack/unpack
        puts "That failed. Trying to fix in another way."
        return JSON.pretty_generate(ocred_file.to_a.map do |field|
                                      field[1] = fix_encoding(field[1]) if field[1].class == String
                                      [field[0], field[1]]
                                    end.to_h)
      end
    end
  end
end
