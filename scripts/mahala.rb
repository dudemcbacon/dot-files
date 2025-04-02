require 'rexml/document'

# Replace 'smses.xml' with the path to your XML file
file_path = 'mahala3.xml'
file_content = File.read(file_path)

# Parsing the XML file
xml_doc = REXML::Document.new(file_content)

# Iterating over each <sms> element
xml_doc.elements.each('smses/mms') do |sms|
  contact_name = 'mahala'
  sms.elements.each('parts/part') do |part|
    next unless part.attributes['ct'] == 'text/plain'

    text = part.attributes['text']
    puts "#{contact_name}: #{text}"
  end
end
