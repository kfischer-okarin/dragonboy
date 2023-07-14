require 'tests/test_helper.rb'

def test_clock_new_clock_has_cpu_scheduled_on_cycle0(_args, assert)
  clock = Clock.new cpu: build_cpu

  assert.contains! clock.schedule, { cycle: 0, method: :execute_next_operation }
end

def test_clock_schedule_method_adds_method_at_the_right_point_in_schedule(_args, assert)
  clock = Clock.new cpu: build_cpu

  clock.schedule_method 10, :foo
  clock.schedule_method 5, :bar

  only_foo_bar_schedule = clock.schedule.select { |item|
    item[:method] == :foo || item[:method] == :bar
  }
  assert.equal! only_foo_bar_schedule, [
    { cycle: 5, method: :bar },
    { cycle: 10, method: :foo }
  ]
end

def test_clock_clear_schedule(_args, assert)
  clock = Clock.new cpu: build_cpu

  clock.schedule_method 10, :foo
  clock.schedule_method 5, :bar
  clock.clear_schedule

  assert.equal! clock.schedule, []
end

def test_clock_advance_executes_all_methods_scheduled_next(_args, assert)
  clock = Clock.new cpu: build_cpu
  executed = []
  [:foo, :bar].each do |method|
    clock.define_singleton_method method do
      executed << method
    end
  end
  clock.clear_schedule
  clock.schedule_method 12, :foo
  clock.schedule_method 12, :bar
  clock.schedule_method 15, :explode

  clock.advance

  assert.equal! executed, [:foo, :bar]
end

def test_clock_advance_removes_executed_methods_from_schedule(_args, assert)
  clock = Clock.new cpu: build_cpu
  clock.define_singleton_method :foo do; end
  clock.clear_schedule
  clock.schedule_method 12, :foo
  clock.schedule_method 15, :bar

  clock.advance

  assert.equal! clock.schedule, [{ cycle: 15, method: :bar }]
end

def test_clock_advance_does_nothing_when_schedule_is_empty(_args, assert)
  clock = Clock.new cpu: build_cpu
  clock.clear_schedule

  clock.advance

  assert.ok!
end

def test_clock_advance_can_process_the_last_schedule_item(_args, assert)
  clock = Clock.new cpu: build_cpu
  clock.define_singleton_method :foo do; end
  clock.clear_schedule
  clock.schedule_method 12, :foo

  clock.advance

  assert.equal! clock.schedule, []
end

def test_clock_advance_updates_cycle(_args, assert)
  clock = Clock.new cpu: build_cpu
  clock.define_singleton_method :foo do; end
  clock.clear_schedule
  clock.schedule_method 12, :foo

  clock.advance

  assert.equal! clock.cycle, 12
end

def test_clock_advance_to_cycle_updates_cycle(_args, assert)
  clock = Clock.new cpu: build_cpu
  clock.clear_schedule

  clock.advance_to_cycle 12

  assert.equal! clock.cycle, 12
end

def test_clock_advance_to_cycle_executes_all_methods_scheduled_until_that_cycle(_args, assert)
  clock = Clock.new cpu: build_cpu
  executed = []
  [:foo, :bar].each do |method|
    clock.define_singleton_method method do
      executed << method
    end
  end
  clock.clear_schedule
  clock.schedule_method 12, :foo
  clock.schedule_method 13, :bar
  clock.schedule_method 15, :explode

  clock.advance_to_cycle 14

  assert.equal! executed, [:foo, :bar]
  assert.equal! clock.cycle, 14
end

def test_clock_schedule_method_should_schedule_past_items_after_4mhz(_args, assert)
  clock = Clock.new cpu: build_cpu
  clock.clear_schedule
  clock.advance_to_cycle 2000
  clock.schedule_method 4_194_303, :foo
  clock.schedule_method 1000, :bar

  assert.equal! clock.schedule, [
    { cycle: 4_194_303, method: :foo },
    { cycle: 1000, method: :bar }
  ]
end
