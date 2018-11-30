require 'action_counter/version'

require 'active_support/all'
require 'redis-objects'
require 'action_counter/version'

class ActionCounter
  def initialize(list)
    @list   = list
    @enable = true
  end

  def disabled!
    @enable = false
  end

  def enable!
    @enable = true
  end

  def audit(action_name)
    audit = build_audit(action_name)

    if block_given?
      begin
        audit.start
        return yield
      ensure
        audit.stop
      end
    end
    audit
  end

  def results(sort_key: :sum)
    groups = rows.group_by { |v| v['action_name'] }

    stats = groups.each.with_object([]) do |(action_name, array), results|
      stat = { action_name: action_name, count: array.size, sum: 0, min: 0, max: 0, avg: 0 }

      array.each do |hash|
        time = hash['time_sec']

        stat[:sum] += time
        stat[:min] = time if stat[:min].zero? || stat[:min] > time

        stat[:max] = time if time > stat[:max]
      end

      stat[:avg] = stat[:sum] / stat[:count]
      results << stat
    end

    sort_key = sort_key.to_sym
    stats.sort { |a, b| b[sort_key] - a[sort_key] }
  end

  def reset
    @list.clear
  end

  private

  # ex) [{action_name: 'hoge', time_sec: 1.1}]
  def rows
    @list.map { |json| JSON.parse(json) }
  end

  def build_audit(action_name)
    if @enable
      ActionCounter::Audit.new(action_name: action_name, list: @list)
    else
      ActionCounter::AuditNullObject.new
    end
  end

  class Audit
    def initialize(action_name:, list:)
      @action_name = action_name
      @list        = list
    end

    def start
      @start_time = Time.now
      self
    end

    def stop
      @end_time = Time.now
      time_sec  = @end_time - @start_time
      h         = { action_name: @action_name, time_sec: time_sec }
      @list << h.to_json
      h
    end
  end

  class AuditNullObject
    def initialize; end

    def start
      self
    end

    def stop; end
  end
end
