# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'

def imdb_scraper
  movies_with_link = Hash.new(0)
  url = 'https://www.imdb.com/user/ur36814528/ratings?ref_=nv_usr_rt_4'

  # First scrape to get the total amount of movies
  html_content = open(url).read
  imdb_page = Nokogiri::HTML(html_content)
  total_ratings = imdb_page.search('#lister-header-current-size').text.to_i

  # Using the total amount, calculate the number of pages
  current_page = 0
  max_page = (total_ratings / 100.0).ceil

  # Iterate through the pages and save all the movienames found as a
  # hashkey, with the link to the movie page as its value.
  while current_page < max_page
    html_content = open(url).read
    imdb_page = Nokogiri::HTML(html_content)
    imdb_page.search('.lister-item-header a').each do |movie|
      movies_with_link[movie.text] = movie.attributes['href'].text
    end
    # Save link to next imdb-ratings page as url
    next_page = imdb_page.search('.list-pagination .next-page')[0].attributes['href'].text
    url = "https://www.imdb.com#{next_page}"
    # p url
    current_page += 1
  end

  movies_with_link
end

p imdb_scraper
# [#<Nokogiri::XML::Element:0x3fe08fd3f6d0 name="a" attributes=[#<Nokogiri::XML::Attr:0x3fe08fd3f658 name="class" value="flat-button lister-page-next next-page">, #<Nokogiri::XML::Attr:0x3fe08fd3f644 name="href" value="/user/ur36814528/ratings?sort=date_added%2Cdesc&mode=detail&paginationKey=mfq5ijak6z7uymjwuuwsomnsegl34knnqsdztp6xeepepyyfxdfiwpol52uhtjimq3iwclnm7gq7uk2y4kjyazipmv7dko7t7nchy6m47iyfrvleknv4axfhhxudjs5nyx6ild2xqjdqljg6bqac2wheaznk2ouqhjumdrosczr2xdmt25ats7f757neon4q5epni76376m3hnckb4&lastPosition=100">] children=[#<Nokogiri::XML::Text:0x3fe08fd3eff0 "\n                Next\n            ">]>]
