Given(/^I am on Events index page$/) do
  visit('/events')
end

Given(/^following events exist:$/) do |table|

  table.hashes.each do |hash|

p "TEST::creating_event =>"
p "    start_time            = " + hash[:start_time] + " (this is the correct dt)"
p "    end_time              = " + hash[:end_time] + " (this is the correct dt)"

    Event.create!(hash)
  end
end

Then(/^I should be on the Events "([^"]*)" page$/) do |page|
  case page.downcase
    when 'index'
      current_path.should eq events_path

    when 'create'
      current_path.should eq new_event_path

    else
      pending
  end
end

Then(/^I should see multiple "([^"]*)" events$/) do |event|
  #puts Time.now
  page.all(:css, 'a', text: event, visible: false).count.should be > 1
end

When(/^the next event should be in:$/) do |table|
  table.rows.each do |period, interval|
    page.should have_content([period, interval].join(' '))
  end
end

Given(/^I am on the show page for event "([^"]*)"$/) do |name|
  steps %Q{
      Given I am on Events index page
      And I click "#{name}"
  }
end

Then(/^I should be on the event "([^"]*)" page for "([^"]*)"$/) do |page, name|
  event = Event.find_by_name(name)
  page.downcase!
  case page
    when 'show'
      current_path.should eq event_path(event)
    else
      current_path.should eq eval("#{page}_event_path(event)")
  end
end

Given(/^the date is "([^"]*)"$/) do |jump_date|
  Delorean.time_travel_to(Time.parse(jump_date))
end


### event_expire_url.feature steps ###

Given(/^I am signed in$/) { create_user ; sign_in }

Given(/^the HOA link for the "(.*?)" event is (.*?)set$/) do | name , is_not_set |
  event     = Event.find_by_name name
  event.url = ((is_not_set)? "" : MOCK_HANGOUT_URL) ; event.save!
end

# Given(/^the HOA link for the "(.*?)" event is not set$/) do | name |
#   event = Event.find_by_name name
#   event.url = "" ; event.save!
# end

Then(/^I should see the "(.*?)" message$/) do | msg_name |
  case msg_name
    when 'hangout url unset'
      expected_msg = HANGOUT_UNSET_MSG
  end

p "TEST::matching_message =>"
p "    Time.now              = " + Time.now.to_s + " (this is the correct dt)"

  page.should have_content expected_msg
end

Then(/^I should see the "(.*?)" link$/) do | link_name |
  case link_name
    when 'HOA'
      page.should have_content MOCK_HANGOUT_URL
  end
end
