require 'spec_helper'
require 'crichton/lint'

module Crichton
  module Lint
    describe StatesValidator do
      let(:validator) { Crichton::Lint }
      let(:filename) { create_drds_file(@descriptor, @filename) }

      before(:all) do
        @filename = 'drds_lint.yml'
      end

      before do
        allow_any_instance_of(Crichton::ExternalDocumentStore).to receive(:get).and_return('<alps></alps>')
      end

      describe '#validate' do
        after do
          expect(validation_report).to eq(@errors || @warnings || @message)
        end

        def validation_report
          capture(:stdout) { validator.validate(filename) }
        end

        it 'reports error when route does not have controller property' do
          @descriptor = drds_descriptor.tap do |document|
            document['routes']['create'].except!('controller')
          end
          @errors = expected_output(:error, 'routes.missing_key', resource: 'DRDs', key: 'controller', route: 'create',
            filename: filename, section: :routes, sub_header: :error)
        end

        it 'reports error when route does not have action property' do
          @descriptor = drds_descriptor.tap do |document|
            document['routes']['create'].except!('action')
          end
          @errors = expected_output(:error, 'routes.missing_key', resource: 'DRDs', key: 'action', route: 'create',
            filename: filename, section: :routes, sub_header: :error)
        end

        it 'reports error when there is no corresponding transition in protocols section' do
          @descriptor = drds_descriptor.tap do |document|
            document['routes'].merge!({ 'create2' => { 'controller' => 'drds', 'action' => 'create2' } })
          end
          @errors = expected_output(:error, 'routes.missing_protocol_transitions', resource: 'DRDs', route: 'create2',
            filename: filename, section: :routes, sub_header: :error)
        end

        it 'reports error when there is no corresponding transition in routes section' do
          @descriptor = drds_descriptor.tap do |document|
            document['routes'].except!('create')
          end
          @errors = expected_output(:error, 'routes.missing_route', resource: 'DRDs', transition: 'create',
            filename: filename, section: :routes, sub_header: :error)
        end
      end
    end
  end
end
