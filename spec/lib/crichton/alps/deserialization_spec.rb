require 'spec_helper'
require 'crichton/alps/deserialization'

module Crichton
  module ALPS 
    describe Deserialization do
      describe '.new' do
        after do
          # Rewind file so the next user can read it
          alps_xml_string.rewind
        end

        it 'deserializes XML data' do
          deserializer = Deserialization.new(alps_xml_string)
          deserializer.to_hash.keys.should == ["doc", "ext", "links", "descriptors"]
        end

        it 'deserializes JSON data' do
          xmldeserializer = Crichton::ALPS::Deserialization.new(alps_xml_string.read)
          deserializer = Deserialization.new("{\"alps\": #{xmldeserializer.to_json}}")
          deserializer.to_hash.keys.should == ["doc", "ext", "links", "descriptors"]
        end

        it 'deserializes a JSON DRD' do
          deserializer = Deserialization.new(alps_json_data)
          deserializer.to_hash.keys.should == ['doc', "links", "datalists", "descriptors"]
        end

        it 'deserializes a XML DRD' do
          deserializer = Deserialization.new(alps_xml_data)
          deserializer.to_hash.keys.should == ['doc', "links", "descriptors", "datalists"]
        end
      end

      describe '#alps_to_hash' do
        it 'populates the link section properly' do
          deserializer = Deserialization.new(alps_xml_string)
          deserialized_hash = deserializer.to_hash
          deserialized_hash.should include({
            "links" => {
              "self" => "http://alps.example.com/Leviathans",
              "help" => "http://docs.example.org/Things/Leviathans"
              }
            })
        end
      end
    end
  end
end
