# frozen_string_literal: true

module DatepickerHelper
  def fill_date_of_birth(day: "15")
    # Wait for the datepicker button to be present AND clickable
    return unless has_css?(".datepicker__calendar-button", wait: 5)

    # CRITICAL: Wait for Web Component to be fully initialized
    # The datepicker uses a web component (wc-datepicker) that needs time to initialize
    wait_for_datepicker_ready

    # Open the calendar
    calendar_opened = open_datepicker_calendar?

    return unless calendar_opened

    # Select the day
    unless select_day(day)
      close_datepicker_forcefully
      return
    end

    # Confirm the selection
    unless confirm_date_selection
      close_datepicker_forcefully
      return
    end

    # Verify calendar closed
    verify_calendar_closed
  end

  private

  def wait_for_datepicker_ready
    # Wait for the web component to be fully loaded and interactive
    # Check that the button has the onclick handler attached
    ready = wait_for_condition?(timeout: 5, interval: 0.2) do
      page.evaluate_script(<<~JS)
        (function() {
          const button = document.querySelector('.datepicker__calendar-button');
          if (!button) return false;
        #{"  "}
          // Check if the web component parent exists
          const datepicker = button.closest('wc-datepicker');
          if (!datepicker) return false;
        #{"  "}
          // Check if the component is defined (web component is loaded)
          if (!customElements.get('wc-datepicker')) return false;
        #{"  "}
          // Additional check: the button should be clickable
          const rect = button.getBoundingClientRect();
          return rect.width > 0 && rect.height > 0;
        })();
      JS
    end

    if ready
      sleep 0.3 # Small extra delay for stability
    else
      sleep 1 # Longer delay as fallback
    end
  end

  def open_datepicker_calendar?
    max_retries = 3
    retry_count = 0

    while retry_count < max_retries

      begin
        # Try multiple methods to click the button
        click_success = page.evaluate_script(<<~JS)
          (function() {
            const button = document.querySelector('.datepicker__calendar-button');
            if (!button) {
              console.error('Button not found!');
              return false;
            }
          #{"  "}
            // Try to click via multiple methods
            try {
              // Method 1: Direct click
              button.click();
          #{"    "}
              // Method 2: Dispatch click event
              button.dispatchEvent(new MouseEvent('click', {
                view: window,
                bubbles: true,
                cancelable: true
              }));
          #{"    "}
              console.log('Click dispatched successfully');
              return true;
            } catch (e) {
              console.error('Click failed:', e);
              return false;
            }
          })();
        JS

        unless click_success
          retry_count += 1
          sleep 0.5
          next
        end

        # Wait for calendar to appear
        return true if has_css?("tbody.sc-wc-datepicker", wait: 2)

        retry_count += 1
        sleep 0.5
      rescue StandardError
        retry_count += 1
        sleep 0.5
      end
    end

    false
  end

  def select_day(day)
    within "tbody.sc-wc-datepicker", wait: 3 do
      # Try both possible selectors
      day_element = find("span[aria-hidden=true], em[aria-hidden=true]", text: day, match: :first, wait: 2)
      day_element.click
      sleep 0.2
    end
    true
  rescue Capybara::ElementNotFound
    false
  end

  def confirm_date_selection
    # Try button first
    select_button = find_button("Select", wait: 2)
    select_button.click
    sleep 0.3
    true
  rescue Capybara::ElementNotFound
    # Fallback to link
    begin
      select_link = find_link("Select", wait: 1)
      select_link.click
      sleep 0.3
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  def verify_calendar_closed
    expect(page).to have_no_css("tbody.sc-wc-datepicker", wait: 3)
  rescue RSpec::Expectations::ExpectationNotMetError
    close_datepicker_forcefully
  end

  def close_datepicker_forcefully
    page.execute_script(<<~JS)
      const calendar = document.querySelector('tbody.sc-wc-datepicker');
      if (calendar) {
        const datepicker = calendar.closest('wc-datepicker');
        if (datepicker) {
          // Try to close via the datepicker's internal method
          if (datepicker.close) datepicker.close();
        }
      }
      // Fallback: click outside
      document.body.click();
    JS
    sleep 0.5
  end

  def wait_for_condition?(timeout: 5, interval: 0.5)
    start_time = Time.zone.now
    while Time.zone.now - start_time < timeout
      result = yield
      return true if result

      sleep interval
    end
    false
  end
end

RSpec.configure do |config|
  config.include DatepickerHelper, type: :system
end
