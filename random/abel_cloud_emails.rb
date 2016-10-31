require 'rest-client'
require 'json'
require 'csv'

#
# Instructions:
#
# 1. Change the value of the cls_urn variable on line 79 to match the CLS you are wanting to export emails for
# 2. Save your changes
# 3. Open Terminal
# 4. Navigate to the folder that the cloud_emails.rb file is saved
# 5. Type the following command in your terminal window: ruby cloud_emails.rb
# 6. You're done! A confirmation message should display on the screen.
# 
# Note: Any new executions of this script will overrite the data in the location-emails csv. 
# 
# 

# build our csv to add data to
def build_csv(file_name)
						arr = ["Location URN", "Email List"]
								CSV.open(file_name, "wb") do |csv|
																csv << arr
																		end
end

# add rows to our csv from dataset
def add_to_csv(arr)
						CSV.open("location-emails.csv", "a+") do |csv|
														csv << arr
																end
end

# Grab response from the CLS API
# set flag and return flag to trigger next method
def get_response(url)
						res_flag = false
								response = RestClient.get(url){|response, request, result| response 
																if response.code != 200
																										puts response.code
																																res_flag = true
																																						puts "Skipped due to #{response.code}"
																																										end
																		}
																				return res_flag
end

# Get cls data if response is valid
def get_data(flag, url)
						data = ""
								response = 0
										if flag == false
																		response = RestClient.get(url)
																						data = JSON.load response
																								end
												return data
end

# Grab emails and location urn
def export_emails(data)
						my_string = ""
								match_val = 0
										loc_urn = ""
												emails = ""
														data["configurable_attributes"].each do |item|
																						arr = []
																										if item["category"] == "Location" && item["location_urn"] != nil
																																				# only push values that are emails
																																										my_string = item["value"]
																																																# puts my_string
																																																						match_val = /@/ =~ my_string
																																																												# puts match_val
																																																																		if match_val >= 0
																																																																														# add data to csv
																																																																																						arr.push(item["location_urn"], item["value"])
																																																																																														add_to_csv arr
																																																																																																				end
																																																																						end
																												end
end


# script start
data = {}
# example cls URN: 
# cls_urn = "g5-cls-ifu2jcq3-pensam-capital"
cls_urn = "g5-cls-ifu2jcq3-pensam-capital"
base_url = "https://#{cls_urn}.herokuapp.com/api/v1/configurable_attributes"
puts "Gathering data for...."

build_csv "location-emails.csv"
flag = get_response base_url
data = get_data flag, base_url
export_emails data

puts "Emails for #{cls_urn} exported!"
