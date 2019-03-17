require "curb"
require "mail"

# Methods for OCRing files with Tika
module EmlOCR
  include OCRUtils

  # OCR the email
  def ocr_rfc822(full_path)
    email = Mail.read(full_path)
    
    parsed_mail = {
      subject: email.subject,
      from: parse_to_from_names(email.from),
      from_addresses: parse_to_from_addresses(email.from),
      to: parse_to_from_names(email.to),
      to_addresses: parse_to_from_addresses(email.to),
      cc: parse_to_from_names(email.cc),
      cc_addresses: parse_to_from_addresses(email.cc),
      bcc: parse_to_from_names(email.bcc),
      bcc_addresses: parse_to_from_addresses(email.bcc),
      date: email.date,
      message_id: get_header_field(email, "message-id"),
      thread_id: get_header_field(email, "thread"),
      references: get_header_field(email, "references"),
      body: get_mail_text_body(email)
    }.merge(process_attachments(email, full_path))
    
    return parsed_mail
  end

  # Generate a name for the attachment file
  def gen_attachment_filename(full_path, attachment_name)
    mail_extension = full_path.split(".").last
    save_name = full_path.split("/").last.gsub(".#{mail_extension}", "")+"_"+attachment_name.split("tmp", 2).last

    # Trim if needed
    if save_name.length > 255
      file_extension = save_name.split(".").last
      return save_name.gsub(".#{file_extension}", "")[0..230]+".#{file_extension}"
    end
    return save_name
  end

  # Process the attachments
  def process_attachments(email, full_path)
    attachment_text = ""
    attachment_list = []
    file_types = ["email"]

    # OCR each attachment
    email.attachments.each do |attachment|
      attachment_text, attachment_list, file_types = ocr_attachment(attachment, attachment_text,
                                                                    attachment_list, file_types, full_path)
    end

    # Return the list of attachments
    return {
      attachment_text: attachment_text,
      attachment_list: attachment_list,
      filetype: file_types.uniq
    }
  end

  # OCR individual attachments
  def ocr_attachment(attachment, attachment_text, attachment_list, file_types)
    attach_path = ENV['OCR_OUT_PATH']+"/raw_docs/"+gen_attachment_filename(full_path, attachment.filename)

    # Save and OCR
    File.write(attach_path, attachment.decoded)
    ocred = ocr_file(attachment.decoded, attach_path.split("/").last, attach_path)

    # Add attachment text and path to the mail
    attachment_text = append_attachment_text(attachment_text, attachment, ocred)
    attachment_list.push(attach_path)
    file_types.push(ocred[:filetype])
    return attachment_text, attachment_list, file_types
  end

  # Append attachment text to the email and fix encoding if needed
  def append_attachment_text(attachment_text, attachment, ocred)
    begin
      attachment_text += "\n#{attachment.filename.split("tmp", 2).last}:\n#{ocred[:text].to_s}"
    rescue # Handle encoding issues
      begin
        attachment_text += "\n#{attachment.filename.split("tmp", 2).last}:\n#{ocred[:text].to_s.force_encoding('UTF-8')}"
      rescue
        attachment_text = attachment_text.force_encoding('UTF-8')
        attachment_text += "\n#{attachment.filename.split("tmp", 2).last}:\n#{fix_encoding(ocred[:text].to_s)}"
      end
    end
    return attachment_text
  end

  # Output the names for emails
  def parse_to_from_names(input)
    input = input.to_s.split(",") if !input.is_a?(Array)
    return input.map{|i| just_get_name(i)}
  end

  # Generate the list of addresses
  def gen_address_list(cleaned_input)
    email_regex = '(?<=(?:\b|\s|>|^))(?:\w|-|\.)+@(?:\w|-|\.)+\.\w+(?<=(?:\b|\s|<|$))'
    raw_matches = cleaned_input.to_enum(:scan, /#{email_regex}/).map{Regexp.last_match}
    return raw_matches.map{|match| match.to_s}
  end

  # Parse the addresses in to/from/cc/bcc
  def parse_to_from_addresses(input)
    input = input.join(",") if input.is_a?(Array)
    cleaned_input = input.to_s.gsub(/\/[oO]=[\w\/=\s\\r()-]*/, "outlook_group")
    return gen_address_list(cleaned_input)
  end

  # Just get the name from an email
  def just_get_name(item)
    return item.split("<").first.strip.lstrip.gsub('"', "").gsub("'", "") if item
  end

  # Get a field from the header
  def get_header_field(email, field)
    field_info = email.header.fields.select{|f| f.name.downcase.include?(field)}
    if field_info.length > 0
      return field_info.first.value
    end
  end

  # Get the main body of the text
  def get_mail_text_body(email)
    if email.text_part
      return email.text_part.body.decoded
    else
      return email.body.decoded
    end
  end
end
