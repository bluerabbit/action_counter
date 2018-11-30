RSpec.describe ActionCounter do
  it 'has a version number' do
    expect(ActionCounter::VERSION).not_to be nil
  end

  describe '#audit' do
    before do
      @action_counter = ActionCounter.new(Redis::List.new('namespace'))
    end

    after do
      @action_counter.reset
    end

    it do
      @action_counter.audit('action1') { sleep 1 }
      @action_counter.audit('action1') { sleep 2 }
      rows = @action_counter.results
      expect(rows.size).to eq(1)

      row = rows.first
      expect(row[:action_name]).to eq('action1')
      expect(row[:count]).to eq(2)
      expect(row[:sum].to_i).to eq(3)
      expect(row[:min].to_i).to eq(1)
      expect(row[:max].to_i).to eq(2)
      expect(row[:avg].round(2)).to eq(1.5)
    end

    it do
      @action_counter.audit('action1') { sleep 1 }
      @action_counter.audit('action2') { sleep 1 }
      @action_counter.audit('action2') { sleep 1 }

      rows = @action_counter.results(sort_key: :sum)
      expect(rows.size).to eq(2)

      expect(rows[0][:action_name]).to eq('action2')
      expect(rows[0][:sum].to_i).to eq(2)

      expect(rows[1][:action_name]).to eq('action1')
      expect(rows[1][:sum].to_i).to eq(1)
    end

    it do
      audit = @action_counter.audit('action1').start
      sleep 1
      audit.stop

      rows = @action_counter.results(sort_key: :sum)
      expect(rows.size).to eq(1)

      expect(rows[0][:action_name]).to eq('action1')
      expect(rows[0][:sum].to_i).to eq(1)
    end

    it do
      @action_counter.disabled!
      audit = @action_counter.audit('action1').start
      sleep 0.1
      audit.stop

      @action_counter.audit('action2') { sleep 0.1 }

      rows = @action_counter.results
      expect(rows.size).to eq(0)
    end
  end
end
