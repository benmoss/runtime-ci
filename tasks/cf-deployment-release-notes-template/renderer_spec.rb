require 'rspec'
require_relative './renderer.rb'

describe 'Renderer' do
  describe '#render' do
    subject(:renderer) { Renderer.new }

    let(:release_update_1) do
      update = double('ReleaseUpdate')
      allow(update).to receive(:old_version) { '1.1.0' }
      allow(update).to receive(:new_version) { '1.3.0' }
      update
    end

    let(:release_update_2) do
      update = double('ReleaseUpdate')
      allow(update).to receive(:old_version) { '1.2.0' }
      allow(update).to receive(:new_version) { '1.4.0' }
      update
    end

    let(:release_updates) do
      updates = double('ReleaseUpdates')
      allow(updates).to receive(:each).and_yield('release-1', release_update_1).and_yield('release-2', release_update_2)
      updates
    end

    describe 'Release and stemcell table' do
      it 'includes a header' do
        expect(renderer.render(release_updates: release_updates)).to include(
<<-HEADER
| Release | New Version | Old Version |
| ------- | ----------- | ----------- |
HEADER
        )
      end

      it 'shows the release name, new version, and old version for each release' do
        rendered_output = renderer.render(release_updates: release_updates)
        expect(rendered_output).to include('| release-1 | 1.3.0 | 1.1.0 |')
        expect(rendered_output).to include('| release-2 | 1.4.0 | 1.2.0 |')
      end

      context 'when some versions are nil' do
        let(:release_update_1) do
          update = double('ReleaseUpdate')
          allow(update).to receive(:old_version) { '1.1.0' }
          allow(update).to receive(:new_version) { nil }
          update
        end

        let(:release_update_2) do
          update = double('ReleaseUpdate')
          allow(update).to receive(:old_version) { nil }
          allow(update).to receive(:new_version) { '1.4.0' }
          update
        end

        it 'renders them as empty strings' do
          rendered_output = renderer.render(release_updates: release_updates)
          expect(rendered_output).to include('| release-1 |  | 1.1.0 |')
          expect(rendered_output).to include('| release-2 | 1.4.0 |  |')
        end
      end
    end
  end
end
