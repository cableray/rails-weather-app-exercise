require "rails_helper"
require "capybara/rspec"

RSpec.describe "Main web interface", type: :feature do
  let!(:api_key) do
    "some_api_key".tap do |key|
      allow(Rails.application.config).to receive(:api_key).and_return(key)
    end
  end
  let(:raw_response) do
    File.new('spec/support/http_responses/weather.vc.drurylane.http')
  end
  before do
    stub_request(:get, "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/123+Drury+Lane").
      with(query: hash_including(include: 'current', key: api_key)).
      to_return(raw_response)
  end

  it "has an address input field" do
    visit '/'

    expect(page).to have_field("address", placeholder: "Address")
    expect(page).to have_button
  end

  it "displays forcast for address" do
    visit '/'

    fill_in "address", with: "123 Drury Lane"
    click_button

    expect(page).to have_content "Currently: 42 degrees"
    expect(page).to have_field("address", with: "123 Drury Lane")
    expect(page).to have_content("Resolved Address: 42 Drury Ln, Barrie, ON L4M, Canada")
  end
end