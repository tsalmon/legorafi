require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'json'

@URL = 'http://www.legorafi.fr'
@FILE = "js/legorafi.json"
@YEAR_MIN = 2012
@YEAR_MAX = DateTime.now.year

class Page
	attr_reader :title, :likes, :shares, :id

	@@nb_pages = 0

	def initialize(title, link, comments, shares)
		@@nb_pages += 1
		@id = @@nb_pages
		@title = title
		@link = link
		@comments = comments
		@shares = shares
	end

	def link
		@URL + @link
	end

	def to_json
		{:title => @title, :link => @link, :comments => @comments, :shares => @shares}
	end

	def to_s
		self.to_json
	end
end

def get_links_by_month_of_year(month, year)
	page_year = Nokogiri::XML(open("#{@URL}/#{year}/#{month}/feed/"))
	xml_links = page_year.xpath("//link")
	clean_links(xml_links)
end

def clean_links(links)
	links_cleaned = []
	links.each do |link|
		content_link = link.to_s
		if content_link.size > 36
			links_cleaned << content_link.to_s[28..-8]
		end
	end
	links_cleaned
end

def get_all_link
	links = []
	(@YEAR_MIN..@YEAR_MAX).each do |year|
		(1..12).each do |month|
			links = links + get_links_by_month_of_year(month, year)
		end
	end
	links
end

def get_all_pages
	pages = []
	links = get_all_link
	links.each do |link|
		pages << read_page(link)
	end
	pages
end

def write_to_file(pages)
	hash= pages.map { |page| page.to_json }

	File.open(@FILE, "a") do |file|
		file.write "pages = " + hash.to_json
	end
end

def test_link
	page = read_page "2015/12/04/il-tente-de-pirater-la-cia-pour-dominer-le-monde-et-echoue-apres-une-panne-de-wifi/"
	page
end

def test_page
	pages = []
	pages << Page.new("A", "B", "C", "D")
	pages << Page.new("A", "B", "C", "D")
	pages << Page.new("A", "B", "C", "D")
	pages
end

def read_page(link)
	puts link
	nokogiri_page = Nokogiri::HTML(open("#{@URL}/#{link}"))
	title = nokogiri_page.css('h1').to_s[4..-6]
	shares = nokogiri_page.css('span.total').to_s[20..-8]
	comments = nokogiri_page.css('a.comments_blue').to_s[46..-5]
	page = Page.new(title, link, comments, shares)
	page
end

def legorafi
	write_to_file(get_all_pages)
end

legorafi
