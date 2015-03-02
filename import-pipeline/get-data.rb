require 'rubygems'
require 'nokogiri'
require_relative 'usgs-functions.rb'
require_relative 'process-functions.rb'
require_relative 'api-details.rb'

@s3_subfolder = "testing_pipeline"
@api_key = connect(@usgs_username,@usgs_password)

@places = {
	# "Chicago" => { "latitude" => 41.8369, "longitude" => -87.6847},
	# "Oxford" => { "latitude" => 51.7519, "longitude" => -1.2578},
	# "Dubai" => { "latitude" => 24.9500, "longitude" => 55.3333},
	# "Nishino-Shima" => { "latitude" => 27.2469, "longitude" => 140.8744},
	# "Tangier-Island" => { "latitude" => 37.8258, "longitude" => -75.9922},
	# "Ross" => { "latitude" => -81.5000, "longitude" => -175.0000},
	# "Serengeti" => { "latitude" => -2.3328, "longitude" => 34.5667}
	# "Tangier-Island" => { "latitude" => 37.8258, "longitude" => -75.9922}
	"Tasmania" => { "latitude" => -42.0000, "longitude" => 146.5000 }
}

@places.each do |sub, v|

	puts "Locating #{sub} at #{v["latitude"]}, #{v["longitude"]}"
	items = geo_search(v["latitude"],v["longitude"],"Jan 1 2000","Feb 26 2015",2.5)

	path_freq = items.map{|i| path(i) }.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
	row_freq = items.map{|i| row(i) }.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
	p_best = items.map{|i| path(i) }.max_by { |v| path_freq[v] }
	r_best = items.map{|i| row(i) }.max_by { |v| row_freq[v] }

	new_items = items.select{|i| path(i)==p_best && row(i)==r_best }

	scenes = new_items.map{|i| i[:entity_id]}
	dates = new_items.map{|i| i[:acquisition_date]}
	datasets = new_items.map{|i| i[:data_access_url][i[:data_access_url].index("?dataset_name=")+14..i[:data_access_url].index("&ordered")-1] }

	# Create subfolder if it doesn't exist
	value = `mkdir -p #{sub}`

	# Save data to subfolder
	puts "\n##########\nSaving all the #{sub} tiles to the #{sub} folder"
	value = `mkdir -p #{sub}`
	scenes.each_with_index do |scene_id, i|
		url = download_scene(scene_id, datasets[i], sub)
	end

	# Process the data
	process_data(sub, @s3_subfolder)

end
