require 'spec_helper'
require 'crichton/alps/deserialization'

module Crichton
  module ALPS 
    describe Deserialization do
      let (:simple_xml_profile) do
        profile = <<-XML
          <?xml version="1.0" encoding="UTF-8"?>
          <alps>
            <doc>Describes the semantics, states and state transitions associated with DRDs.</doc>
            <link rel="profile" href="http://alps.example.org/DRDs"/>
            <link rel="help" href="http://documentation.example.org/DRDs#help"/>
            <descriptor id="name" type="semantic" href="http://alps.io/schema.org/Text">
            </descriptor>
            <descriptor id="update" type="idempotent" rt="none">
              <link rel="profile" href="http://alps.example.org/DRDs#update"/>
              <descriptor href="#name"/>
            </descriptor>
          </alps>
        XML
      end
      describe '.new' do
        let (:schema_org_airport_profile) do
          profile = <<-XML
            <alps>
             <descriptor id="Airport" type="semantic" href="http://alps.io/schema.org/CivicStructure">
              <doc format="html">
               An airport.
              </doc>
              <descriptor href="http://alps.io/schema.org/Thing#additionalType"/>
              <descriptor href="http://alps.io/schema.org/Place#address"/>
              <descriptor href="http://alps.io/schema.org/Place#aggregateRating"/>
              <descriptor href="http://alps.io/schema.org/Place#containedIn"/>
              <descriptor href="http://alps.io/schema.org/Thing#description"/>
              <descriptor href="http://alps.io/schema.org/Place#event"/>
              <descriptor href="http://alps.io/schema.org/Place#events"/>
              <descriptor href="http://alps.io/schema.org/Place#faxNumber"/>
              <descriptor href="http://alps.io/schema.org/Place#geo"/>
              <descriptor href="http://alps.io/schema.org/Place#globalLocationNumber"/>
              <descriptor href="http://alps.io/schema.org/Thing#image"/>
              <descriptor href="http://alps.io/schema.org/Place#interactionCount"/>
              <descriptor href="http://alps.io/schema.org/Place#isicV4"/>
              <descriptor href="http://alps.io/schema.org/Place#logo"/>
              <descriptor href="http://alps.io/schema.org/Place#map"/>
              <descriptor href="http://alps.io/schema.org/Place#maps"/>
              <descriptor href="http://alps.io/schema.org/Thing#name"/>
              <descriptor href="http://alps.io/schema.org/CivicStructure#openingHours"/>
              <descriptor href="http://alps.io/schema.org/Place#openingHoursSpecification"/>
              <descriptor href="http://alps.io/schema.org/Place#photo"/>
              <descriptor href="http://alps.io/schema.org/Place#photos"/>
              <descriptor href="http://alps.io/schema.org/Place#review"/>
              <descriptor href="http://alps.io/schema.org/Place#reviews"/>
              <descriptor href="http://alps.io/schema.org/Place#telephone"/>
              <descriptor href="http://alps.io/schema.org/Thing#url"/>
             </descriptor>
            </alps>
          XML
        end

        let (:machine_xml_profile) do
          profile =<<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <alps>
              <doc>Describes the semantics, states and state transitions associated with DRDs.</doc>
              <link rel="profile" href="http://alps.example.org/DRDs"/>
              <link rel="help" href="http://documentation.example.org/DRDs#help"/>
              <descriptor id="update" type="idempotent" rt="none">
                <link rel="profile" href="http://alps.example.org/DRDs#update"/>
                <descriptor id="name" type="semantic" href="http://alps.io/schema.org/Text"/>
              </descriptor>
              <descriptor id="create" type="unsafe" rt="drds" href="update">
                <link rel="profile" href="http://alps.example.org/DRDs#create"/>
                <descriptor id="name" type="semantic" href="http://alps.io/schema.org/Text"/>
              </descriptor>
            </alps>
          XML
        end

        let (:json_profile) do
          json_profile = <<-HERE
          {
            "alps":{
              "doc":{"value":"Describes the semantics, states and state transitions associated with DRDs."},
              "link": [
                {"rel":"profile","href":"http://alps.example.org/DRDs"},
                {"rel":"help","href":"http://documentation.example.org/DRDs#help"}
              ],
              "descriptor":[
                {"id":"name","type":"semantic","href":"http://alps.io/schema.org/Text"},
                {
                  "link": [{"rel":"profile","href":"http://alps.example.org/DRDs#update"}],
                  "id":"update","type":"idempotent","rt":"none", "descriptor":[{"href":"name"}]
                }
              ]
            }
          }
          HERE
        end

        it 'handles empty XML data' do
          deserializer = Deserialization.new('')
          expect(deserializer.to_hash.keys).to be_empty
        end

        it 'handles nil XML data' do
          deserializer = Deserialization.new(nil)
          expect(deserializer.to_hash.keys).to be_empty
        end

        it 'deserializes simple XML profile' do
          deserializer = Deserialization.new(simple_xml_profile)
          expect(deserializer.to_hash.keys).to eq(['doc', 'links', 'descriptors'])
        end

        context 'when schema.org airport profile' do
          let (:deserialized_hash) { Deserialization.new(schema_org_airport_profile).to_hash }

          it 'deserializes complex profile' do
            expect(deserialized_hash.to_hash.keys).to eq(['descriptors'])
          end

          it 'returns top level descriptor id' do
            expect(deserialized_hash['descriptors'].keys).to eq(['Airport'])
          end

          it 'returns type of top level descriptor' do
            expect(deserialized_hash['descriptors']['Airport']['type']).to eq('semantic')
          end

          it 'returns nested descriptors' do
            expect(deserialized_hash['descriptors']['Airport']['descriptors'].size).to eq(25)
          end
        end

        context 'when standard XML profile' do
          let (:deserialized_hash) { Deserialization.new(machine_xml_profile).to_hash }

          it 'deserializes machine profile' do
            expect(deserialized_hash.keys).to eq(['doc', 'links', 'descriptors'])
          end

          it 'returns nested descriptors' do
            expect(deserialized_hash['descriptors'].keys.sort).to eq(['create', 'update'].sort)
          end
        end

        it 'deserializes JSON data' do
          deserializer = Deserialization.new(json_profile)
          expect(deserializer.to_hash.keys).to eq(['doc', 'links', 'descriptors'])
        end
      end

      describe '#alps_to_hash' do
        it 'populates the link section properly' do
          deserializer = Deserialization.new(simple_xml_profile)
          deserialized_hash = deserializer.to_hash
          expected_hash = {
              "links" => {
                  "profile" => "http://alps.example.org/DRDs",
                  "help" => "http://documentation.example.org/DRDs#help"
              }
          }
          expect(deserialized_hash).to include(expected_hash)
        end
      end
    end
  end
end
