require 'spec_helper'
require 'crichton/middleware/alps_profle_response'
require 'crichton/helpers'

module Crichton
  module Middleware
    describe AlpsProfileResponse do
      include Crichton::Helpers::ConfigHelper

      let (:rack_app) { double('rack_app') }

      before do
        Crichton.clear_registry
        # Can't apply methods without a stubbed configuration and registered descriptors
        stub_example_configuration
        stub_configured_profiles
        stub_alps_requests
      end

      after do
        clear_configured_profiles
      end

      describe '#call' do
        let(:env) { {'REQUEST_URI' => "#{config.alps_base_uri}/DRDs", 'HTTP_ACCEPT' => @media_type} }
        let(:headers) { {'Content-Type' => @media_type, 'expires' => @expires} }
        let(:home_responder) { AlpsProfileResponse.new(rack_app) }
        let(:ten_minutes) { 600 }

        context 'when the alps path' do
          %w(text/html application/alps+xml application/alps+json).each do |media_type|
            it "responds with an alps document associated with the profile id for #{media_type} requests" do
              @media_type = media_type
              @expires = (Time.new + ten_minutes).httpdate
              home_responder.call(env).should == [200, headers, [alps_xml_data]]
            end
          end

          it 'uses the first supported media type in the HTTP_ACCEPT header' do
            @media_type = 'bogus/media_type,*/a,text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*'
            first_content_type_header = {'Content-Type' => 'text/html', 'expires' => (Time.new + ten_minutes).httpdate}
            home_responder.call(env).should == [200, first_content_type_header, [alps_xml_data]]
          end

          it 'responds correctly with a non standard HTTP_ACCEPT header' do
            @media_type = 'bogus/media_type, text/html,  application/xhtml+xml, application/xml;q=0.9,  image/webp, */*'
            first_content_type_header = {'Content-Type' => 'text/html', 'expires' => (Time.new + ten_minutes).httpdate}
            home_responder.call(env).should == [200, first_content_type_header, [alps_xml_data]]
          end

          %w(text/html application/alps+xml application/alps+json).each do |media_type|
            it "responds with the expected content-type for #{media_type} requests" do
              @media_type = media_type
              response = home_responder.call(env)
              response[1]['Content-Type'].should == media_type
            end
          end

          it 'responds with the correct expiration date when it a timeout  is specified as an option' do
            responder = AlpsProfileResponse.new(rack_app, {'expiry' => 20}) #minutes instead of default of 10
            @media_type = 'text/html'
            @expires = (Time.new + 1200).httpdate
            responder.call(env).should == [200, headers, [alps_xml_data]]
          end

          it 'responds with the correct expiration date when a symbolized timeout in specified' do
            responder = AlpsProfileResponse.new(rack_app, {:expiry => 20}) #minutes instead of default of 10
            @media_type = 'text/html'
            @expires = (Time.new + 1200).httpdate
            responder.call(env).should == [200, headers, [alps_xml_data]]
          end

          it 'returns a 406 status for unsupported media_types' do
            @media_type = 'application/jrd+json'
            home_responder.call(env)[0].should == 406
          end

          it 'returns a 406 status for an empty list of acceptable media types' do
            @media_type = ''
            home_responder.call(env)[0].should == 406
          end

          it 'returns a 404 if the profile in the request is not valid' do
            @media_type = 'text/html'
            response = home_responder.call({'REQUEST_URI' => "#{config.alps_base_uri}/BLAH",
              'HTTP_ACCEPT' => @media_type})
            response.should == [404, {'Content-Type' => 'text/html'}, ["Profile BLAH not found"]]
          end

          it 'returns a 404 if the alps request contains no resource' do
            @media_type = 'text/html'
            response = home_responder.call({'REQUEST_URI' => "#{config.alps_base_uri}",
              'HTTP_ACCEPT' => @media_type})
            response.should == [404, {'Content-Type' => 'text/html'}, ["Profile not found"]]
          end
        end

        context 'when not an alps path' do
          it 'invokes the parent rack app from the middleware' do
            @media_type = 'text/html'
            env = {'REQUEST_URI' => "http://www.example.org/drds", 'HTTP_ACCEPT' => @media_type}
            rack_app.should_receive(:call).with(env)
            home_responder.call(env)
          end
        end
      end
    end
  end
end

