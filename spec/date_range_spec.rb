require 'spec_helper'

feature "date-range directive", js: true do
  before do
    visit "/"
  end

  def date_from
    find("input[ng-model='dateFrom']")
  end

  def open_date_range_popup
    date_from.click
  end

  def select_next_month
    find('.date-range-popup .next-month').click
  end

  def select_first_day
    within('.date-range-popup') do
      select_day_buttons = all('button.select-day')
      day = select_day_buttons.detect{|b| !b.disabled?}
      day.click
      day.text.to_i
    end
  end

  def type_date(date)
    date_from.set(date.strftime("%Y-%m-%d"))
  end

  def should_have_date(date)
    page.should have_content(date.strftime("%b %-d, %Y"))
  end

  scenario "changing the month" do
    open_date_range_popup
    select_next_month
    day = select_first_day

    next_date = Time.now.end_of_month + day.days
    should_have_date(next_date)
  end

  scenario "typing in the date" do
    date = Time.now + 1.week

    type_date(date)

    should_have_date(date)
  end

  scenario "closing the popup" do
    open_date_range_popup

    within ".date-range-popup" do
      find(".close-popup").click
    end

    page.should_not have_selector('.date-range-popup')
  end
end
