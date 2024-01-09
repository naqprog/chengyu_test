require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.register_driver :headless_chrome do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << "--headless"
    opts.args << "--disable-gpu"
    opts.args << "--no-sandbox"
    opts.args << "window-size=1600,900"
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end
