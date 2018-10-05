require 'savon'

module PromoStandards
  module SOAP
    class Client
      COMMON_SAVON_CLIENT_CONFIG = {
        # pretty_print_xml: true,
        # log: true,
        env_namespace: :soapenv,
        namespace_identifier: :ns
      }

      def initialize(access_id:, password:)
        @access_id = access_id
        @password = password
      end

      def get_sellable_product_ids(product_data_service_url:)
        client = build_savon_client_for_product(product_data_service_url)
        response = client.call('GetProductSellableRequest',
          message: {
            'shar:wsVersion' => '1.0.0',
            'shar:id' => @access_id,
            'shar:password' => @password,
            'shar:isSellable' => true
          },
          soap_action: 'getProductSellable'
        )
        response.body[:get_product_sellable_response][:product_sellable_array][:product_sellable]
      end

      def get_product(product_data_service_url:, product_id:)
        client = build_savon_client_for_product(product_data_service_url)
        response = client.call('GetProductRequest',
          message: {
            'shar:wsVersion' => '1.0.0',
            'shar:id' => @access_id,
            'shar:password' => @password,
            'shar:localizationCountry' => 'US',
            'shar:localizationLanguage' => 'en',
            'shar:productId' => product_id,
          },
          soap_action: 'getProduct'
        )
        response.body[:get_product_response][:product]
      end

      def get_primary_image(media_content_service_url:, product_id:)
        client = build_savon_client_for_media(media_content_service_url)
        response = client.call('GetMediaContentRequest',
          message: {
            'shar:wsVersion' => '1.1.0',
            'shar:id' => @access_id,
            'shar:password' => @password,
            'shar:mediaType' => 'Image',
            'shar:productId' => product_id,
            'ns:classType' => '1006'
          },
          soap_action: 'getMediaContent'
        )
        if response.body[:get_media_content_response][:media_content_array][:media_content].is_a? Array
          response.body[:get_media_content_response][:media_content_array][:media_content].first
        else
          response.body[:get_media_content_response][:media_content_array][:media_content]
        end
      end

      private

      def common_message_parts
        {
          'shar:id' => @access_id,
          'shar:password' => @password
        }
      end

      def build_savon_client_for_product(service_url)
        Savon.client COMMON_SAVON_CLIENT_CONFIG.merge(
          endpoint: service_url,
          namespace: 'http://www.promostandards.org/WSDL/ProductDataService/1.0.0/',
          namespaces: {
            'xmlns:shar' => 'http://www.promostandards.org/WSDL/ProductDataService/1.0.0/SharedObjects/'
          }
        )
      end

      def build_savon_client_for_media(service_url)
        Savon.client COMMON_SAVON_CLIENT_CONFIG.merge(
          endpoint: service_url,
          namespace: 'http://www.promostandards.org/WSDL/MediaService/1.0.0/',
          namespaces: {
            'xmlns:shar' => 'http://www.promostandards.org/WSDL/MediaService/1.0.0/SharedObjects/'
          }
        )
      end

    end
  end
end
