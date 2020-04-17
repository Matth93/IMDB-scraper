# frozen_string_literal: true

require 'CSV'
require 'open-uri'
require 'nokogiri'
# require 'pry-byebug'

def imdb_scraper
  movies_with_link = Hash.new(0)
  movies_with_budget = Array.new(0)
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

  # Search each movie's page for it's budget
  movies_with_link.each do |movie, link|
    url = "https://www.imdb.com#{link}"
    html_content = open(url).read
    movie_page = Nokogiri::HTML(html_content)

    # Search for the textblock that includes the budget
    budgetblock = nil
    textblocks = movie_page.search('#titleDetails .txt-block')
    textblocks.each do |textblock|
      budgetblock = textblock.text if textblock.text.include?('Budget')
    end
    # Format the budget to include just a numerical value
    unless budgetblock.nil?
      stripped_budgetblock = budgetblock.gsub(/\n/, '').strip
      matchresult = stripped_budgetblock.match(/.{7}\D*(?<budget>\S+)\s+/)
      formatted_budget = matchresult[:budget].gsub(',', '').to_i

      # Find personal rating, NOTE: not possible yet

      # Add movie budget to a new hash with the name and budget, wich is then
      # put in another array
      movies_with_budget.push([movie, formatted_budget])
      p movie + formatted_budget.to_s
    end
  end

  p movies_with_budget
  return movies_with_budget
end

def write_csv_list(movies_with_budget, csv_file)
  ordered_movies = movies_with_budget.sort { |movie, next_movie| movie[1] <=> next_movie[1] }
  CSV.open(csv_file, 'wb') do |csv|
    ordered_movies.each do |movie|
      csv << movie
    end
  end
  p ordered_movies
end

# test_array = [["geralds spel", 434344 ],["geest verhalen", 7878878],["viezigheid", 10]]

# write_csv_list(test_array, 'imdb_movies_by_budget.csv')
write_csv_list(imdb_scraper, 'imdb_movies_by_budget.csv')

# rated_movies_with_budget = [["fefe", 10],["gert", 12],["deh de", 2]]
# p rated_movies_with_budget.select { |movie| movie[1] = 0 }

