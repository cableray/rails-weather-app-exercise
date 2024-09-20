require "rails_helper"
require "capybara/rspec"

RSpec.describe "Main web interface", type: :feature do
  let!(:api_key) do
    "some_api_key".tap do |key|
      allow(Rails.application.config).to receive(:api_key).and_return(key)
    end
  end
  let(:raw_response) do
    File.new('spec/support/http_responses/weather.vc.whitehouse.http')
  end
  let!(:weather_api_request) do
    stub_request(:get, "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/1600+Pennsylvania+Ave+Washington+DC+20500").
      with(query: hash_including(include: 'current', key: api_key)).
      to_return(raw_response)
  end

  before(:each) do
    Rails.cache.clear
  end

  let(:query_address) {"1600 Pennsylvania Ave Washington DC 20500"}
  let(:expected_resolved_address) {"1600 Pennsylvania Ave NW, Washington, DC 20500, United States"}

  it "has an address input field" do
    visit '/'

    expect(page).to have_field("address", placeholder: "Address")
    expect(page).to have_button
  end

  it "validates that the address includes a parsable zipcode" do
    visit '/'

    # note that the address parser is greedy, so a large enough house number can be considered a zip. 
    # Skipping this edge case for now.
    fill_in "address", with: "123 Drury Lane"
    click_button

    expect(page).to have_content "Address is missing Zip Code"
    expect(page).to have_field("address", with: "123 Drury Lane")
    expect(page).to_not have_content("Currently")
    expect(page).to_not have_content("Cached") # caught this accidental regression
  end

  it "displays forcast for address" do
    visit '/'

    fill_in "address", with: query_address
    click_button

    expect(page).to have_content "Currently: 42 degrees"
    expect(page).to have_field("address", with: query_address)
    expect(page).to have_content("Resolved Address: #{expected_resolved_address}")
  end

  it "caches the request" do
    visit '/'

    fill_in "address", with: query_address
    click_button

    expect(page).to have_content "Currently: 42 degrees"
    expect(page).to_not have_content("Cached")

    # try again
    fill_in "address", with: "1601 Pennsylvania Ave Washington DC 20500" # note that this address is fake, and has a different zipcode IRL
    click_button

    expect(page).to have_content "Currently: 42 degrees"
    expect(page).to have_content("Cached")
    expect(page).to_not have_content("Resolved Address")
    expect(weather_api_request).to have_been_requested.at_most_once
  end
end