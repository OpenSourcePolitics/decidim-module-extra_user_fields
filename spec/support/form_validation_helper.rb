# frozen_string_literal: true

module FormValidationHelper
  def wait_for_form_submission(timeout: 10)
    start_time = Time.zone.now

    loop do
      break if Time.zone.now - start_time > timeout

      is_complete = page.evaluate_script(<<~JS)
        (function() {
          const form = document.querySelector('form.new_user');
          if (!form) return true;
        #{"  "}
          const submitButton = form.querySelector('*[type=submit]');
          if (!submitButton) return true;
        #{"  "}
          const isSubmitting = submitButton.disabled ||#{" "}
                              submitButton.classList.contains('disabled') ||
                              form.classList.contains('is-submitting') ||
                              form.classList.contains('submitting');
        #{"  "}
          return !isSubmitting;
        })();
      JS

      break if is_complete

      sleep 0.1
    end
  rescue StandardError
    sleep 1
  end

  def field_has_validation_error?(field_name)
    field_id = "registration_user_#{field_name}"

    [
      "label[for='#{field_id}'] .form-error",
      "label[for='#{field_id}'] .error",
      "##{field_id}.is-invalid-input",
      "##{field_id}[aria-invalid='true']",
      ".field_with_errors ##{field_id}",
      "##{field_id}_error"
    ].any? { |selector| page.has_css?(selector, wait: 0.5) }
  end

  def wait_for_field_error(field_name, timeout: 5)
    Timeout.timeout(timeout) do
      loop do
        return true if field_has_validation_error?(field_name)

        sleep 0.2
      end
    end
  rescue Timeout::Error
    false
  end

  def expect_field_error(field_name, error_message = nil)
    wait_for_form_submission

    field_id = "registration_user_#{field_name}"

    has_error = wait_for_field_error(field_name)
    expect(has_error).to be(true),
                         "Expected field '#{field_name}' to have validation error indicators"

    return unless error_message

    error_selectors = [
      "label[for='#{field_id}']",
      "##{field_id}_error",
      ".form-error",
      ".error"
    ]

    found = error_selectors.any? do |selector|
      page.has_css?(selector, text: error_message, wait: 1)
    end

    expect(found).to be(true), "Expected to find error message '#{error_message}' for field '#{field_name}'"
  end

  def expect_no_form_errors
    wait_for_form_submission

    [
      ".form-error",
      ".error.active",
      ".is-invalid-input",
      "[aria-invalid='true']"
    ].each do |selector|
      expect(page).to have_no_css(selector, wait: 1)
    end
  end
end

RSpec.configure do |config|
  config.include FormValidationHelper, type: :system
end
