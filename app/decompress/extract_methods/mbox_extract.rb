# Split mbox files into multiple
module MboxExtract
  include OCRUtils

  # Split mbox file into smaller .eml files
  def split_mbox_to_eml(file, save_dir)
    FileUtils.mkdir_p(save_dir)

    # Go through emails and save in .eml
    emails = get_individual_emails(file)
    emails.each do |email|
      # Cut the header so it isn't parsed as mbox
      eml_str = email.lines[1..-1].join

      # Save the file as eml
      save_path = save_dir+"/"+set_file_name(eml_str)
      File.write(save_path, eml_str)
    end
  end

  # Split to get individual emails 
  def get_individual_emails(file)
    begin
      return File.read(file).split(/(?=^From )/)
    rescue # Fix encoding issues if needed
      return fix_encoding(File.read(file)).split(/(?=^From )/)
    end
  end

  # Set file name for the email
  def set_file_name(email)
    return Digest::SHA256.hexdigest(email)+".eml"
  end
end
