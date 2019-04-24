require_relative 'parser'

class RssParser < Parser
  def self.can_parse?(xml)
    if !xml.xpath("//rss").text.eql?("")
      true
    else
      false
    end
  end

  def transform_hash(hash)
    content_storage = Array.new
    result_storage = Hash.new

    # print hash['rss']['channel']['item'].class

    hash['rss']['channel']['item'].each do |item|
      list = Array.new
      list.append(item["title"])
      list.append(scrap_link(item["link"]))
      list.append(item["pubDate"])
      list.append(item["description"])
      content_storage.append(list)
    end

    result_storage[:title] = hash['rss']['channel']['title']
    result_storage[:link] = scrap_link(hash['rss']['channel'])
    result_storage[:content] = content_storage

    result_storage
  end

  protected

  def scrap_link(links)
    if links.class.to_s.eql?('Array')
      link = links[0]
    elsif links.class.to_s.eql?('Hash')
      link = links['link'][0]
    else
      link = links
    end
  end
end
