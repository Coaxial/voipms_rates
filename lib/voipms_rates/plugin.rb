module VoipmsRates
  class Plugin < Adhearsion::Plugin

    require_relative "version"

    # Actions to perform when the plugin is loaded
    #
    init :voipms_rates do
      logger.warn "VoipmsRates has been loaded"
    end

    # Basic configuration for the plugin
    #
    config :voipms_rates do
      rates_endpoint 'https://www.voip.ms/rates/xmlapi.php', desc: "The URL for voip.ms' rates API endpoint"
      canada_use_premium false, desc: "Set to true if you are using premium routing for calls to Canada or false for
      standard routing (change this setting on voip.ms > Account Settings > Account Routing)"
      intl_use_premium false, desc: "Set to true if you are using premium routing for International calls or false for
      standard routing (change this setting on voip.ms > Account Settings > Account Routing)"
    end

    # Defining a Rake task is easy
    # The following can be invoked with:
    #   rake plugin_demo:info
    #
    tasks do
      namespace :voipms_rates do
        desc "Prints the PluginTemplate information"
        task :info do
          STDOUT.puts "VoipmsRates plugin v. #{VERSION}"
        end

        desc "Checks the current Canada routing setting (Should match your settings on voip.ms > Account Settings >
        Account Routing)"
        task :canada_use_premium do
          rate = Adhearsion.config[:voipms_rates].canada_use_premium ? 'premium' : 'standard'
          STDOUT.puts "Using Canada #{rate} routes rate."
          STDOUT.puts "The value can be changed in your app's config file at config/adhearsion.rb"
        end

        desc "Checks the current International routing setting (Should match your settings on voip.ms > Account
        Settings > Account Routing)"
        task :intl_use_premium do
          rate = Adhearsion.config[:voipms_rates].intl_use_premium ? 'premium' : 'standard'
          STDOUT.puts "Using international #{rate} routes rate."
          STDOUT.puts "The value can be changed in your app's config file at config/adhearsion.rb"
        end
      end
    end

  end
end
