require 'capybara/cucumber'
require 'selenium-webdriver'
require 'site_prism'
require_relative 'helper.rb'
require_relative 'page_helper.rb'

BROWSER = ENV['BROWSER']

AMBIENTE = ENV['AMBIENTE']
CONFIG = YAML.load_file(File.dirname(__FILE__) + "/ambientes/#{AMBIENTE}.yml")

World(Helper)
World(Pages)

Capybara.register_driver :selenium do |app|
  if BROWSER.eql?('chrome')
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  elsif BROWSER.eql?('chrome_headless')
    Capybara::Selenium::Driver.new(app, :browser => :chrome,
      desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
        'chromeOptions'=> { 'args' => ['--headless', 
                                      'disable-gpu',
                                      '--disable-dev-shm-usage',
                                      '--no-sandbox'] }
      )  
    )
  end
end

Capybara.configure do |config|
  config.default_driver = :selenium
  config.app_host = CONFIG['url_padrao']
  config.default_max_wait_time = 10
end