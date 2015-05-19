module VoipmsRates
  module ControllerMethods

    require 'rest-client'
    require 'nokogiri'

    # Parameters:
    # phone_number [Int] The number for which we want to get the rate
    def get_rate_for(phone_number)
      if phone_number.match(/[^\d]+/)
        @digits = phone_number.match(/(\d*)@.*/)[1]

        raise TypeError, "Unexpected input, received '#{phone_number}'", caller unless @digits
      else
        @digits = phone_number
      end

      return try_patterns(@digits)
    end

    def try_patterns(digits)
      rates_endpoint = Adhearsion.config[:voipms_rates].rates_endpoint
      # The rates API only works with part of the phone number. If it gets the full phone number, it won't find the
      # rate. If it doesn't get enough digits, it won't find the rate either. And if it gets too many digits, it won't
      # find the rate...
      # For example:
      # To get the rate for '33912345678' (France), you would need to send '339'
      # To get the rate for '15145551234' (Canada), you would need to send '1514'
      # To get the rate for '12125551234' (USA), you would need to send '1'
      #
      high_count = digits.length >= 5 ? 5 : digits.length # This speeds things up with shorter numbers
      for i in high_count.downto(1) do
        pattern = digits[0, i]
        api_response = RestClient.get(rates_endpoint, {
          params: {
            pattern: pattern 
          }
        })
        
        xml_doc = Nokogiri::XML(api_response)
        
        if xml_doc.xpath('/results')[0]
          country = xml_doc.at_xpath('/results/item/short_description').content.to_s
          return xml_doc.at_xpath('/results/item/rate_premium').content.to_f if ((country === 'Canada' && Adhearsion.config[:voipms_rates].canada_use_premium) || ((country != 'Canada' || country != 'USA') && Adhearsion.config[:voipms_rates].intl_use_premium))
          return xml_doc.at_xpath('/results/item/rate').content.to_f

          # We use the premium route for Canada but the value route for all other destinations.
          # Because the API sends back both premium and value rates, this has to be done:
          #
          # country = xml_doc.at_xpath('/results/item/short_description').content.to_s
          # case country
          # when 'Canada'
          #   return xml_doc.at_xpath('/results/item/rate_premium').content.to_f
          # else
          #   return xml_doc.at_xpath('/results/item/rate').content.to_f
          # end
        elsif i === 1 && xml_doc.xpath('error')[0]
          error_code = xml_doc.at_xpath('/error/code').content.to_s
          error_desc = xml_doc.at_xpath('/error/description').content.to_s

          logger.error("No rate found for '#{pattern}', error code '#{error_code}' (#{error_desc})")
          return nil
        end
      end
    end 

    private :try_patterns
  end
end
