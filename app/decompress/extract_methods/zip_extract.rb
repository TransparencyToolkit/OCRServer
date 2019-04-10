# Unzip files
module ZipExtract
  def unzip(file, save_dir)
    Zip::File.open(file) do |zip_file|
      zip_file.each do |included_file|
        # Get path to save at and create it first
        save_file_path = File.join(save_dir, included_file.name)
        FileUtils.mkdir_p(File.dirname(save_file_path))

        # Extract file
        included_file.extract(save_file_path)
      end
    end
  end
end
