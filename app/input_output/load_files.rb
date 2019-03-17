require 'pry'
require 'json'

class LoadFiles
  include OCRManager
  include DetectFiletype
  include MetadataExtractGen

  def initialize(in_dir, out_dir)
    @in_dir = in_dir
    @out_dir = out_dir
  end

  # Load in all files
  def load_and_ocr_all
    Dir.glob("#{@in_dir}/raw_docs/**/*") do |file|
      if File.file?(file)
        metadata = load_metadata(file).to_hash
        ocred_file = ocr(file)
        json_out = prep_json(ocred_file, metadata, file)
        save_file(json_out, file)
      end
    end
  end

  # Save the file
  def save_file(json_out, file)
    ocred_metadata = JSON.parse(json_out)
    
    # Move raw file to out path
    FileUtils.mv(file, ocred_metadata['full_path'])

    # Save metadata file
    File.write("#{@out_dir}/ocred_docs/#{ocred_metadata['rel_path']}.json", json_out)
  end

  # Set the save name for the file (accounts for > 250 chars or directories in name)
  def set_save_name(file)
    # Include directories in saved name
    save_name = file.gsub("#{@in_dir}/raw_docs/", "").gsub("/", "_")

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
    when "eml", "pst", "mbox"
      return "Email"
    else # This is the best option for most file formats
      return "ArchiveDoc"
    end
  end

  # Offer two options for getting the project index (for use with and without pipeline)
  def get_project_index(metadata)
    if metadata && metadata["project"]
      return metadata["project"]
    else
      return ENV['PROJECT_INDEX']
    end
  end

  # Get array of folders
  def get_folders(full_path, rel_path)
    return full_path.gsub(rel_path, "").gsub("#{@out_dir}/raw_docs/", "").split("/").reject!(&:empty?)
  end

  # Prepare the OCRed JSON
  def prep_json(ocred_file, metadata, file)
    # Add paths and folders
    ocred_file[:rel_path] = set_save_name(file)
    ocred_file[:full_path] = "#{@out_dir}/raw_docs/#{ocred_file[:rel_path]}"
    ocred_file[:folders] = get_folders(ocred_file[:full_path], ocred_file[:rel_path])
    
    # Adds title, description, date_added to OCRed hash
    add_metadata_to_file(metadata, ocred_file)
    
    # Add fields for index manager
    ocred_file[:index_fields] = {
      index_name: get_project_index(metadata),
      item_type: determine_doc_type(ocred_file[:filetype])
    }

    return gen_json(ocred_file)
  end

  # OCR the file
  def ocr(file_path)
    # Get path and read file
    content = File.read(file_path) 
    file_name = file_path.split("/").last

    # OCR file
    puts "OCRing #{file_path}"
    return ocr_file(content, file_name, file_path)
  end

  # Load the file metadata (if it exists)
  def load_metadata(file)
    metadata_path = "#{@in_dir}/metadata/#{file.split("/").last}.json"

    # Load in the metadata
    if File.exist?(metadata_path)
      return JSON.parse(File.read(metadata_path))
    end
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
