RSpec.describe ResultsFileParser do
  let(:filename) { "spec/support/fixtures/results/timescaledb/4h_10s_cpu-only_4000_16w" }

  subject(:parser) {ResultsFileParser.new filename }
  describe '#attributes' do
    it 'includes file into attributes' do
      expect(parser.attributes).to eq({
        :target=>"timescaledb",
        :chunk_time=>"4h",
        :log_interval=>"10s",
        :use_case=>"cpu-only",
        :scale=>"4000",
        :workers=>16,
        :started=> Time.at(1625152513),
        :ended=> Time.at(1625152766),
        :duration=>253343,
        :metric_rate=>4092466.509558407,
        :row_rate=>409246.6509558407,
        :batch_size=>5000
      })
    end
  end
end
