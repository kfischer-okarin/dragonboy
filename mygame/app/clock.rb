class Clock
  attr_reader :schedule, :cycle

  CYCLES_PER_SECOND = 4_194_304

  def initialize(cpu:)
    @cpu = cpu
    @schedule = [
      { cycle: 0, method: :execute_next_operation }
    ]
    @cycle = 0
  end

  def schedule_method(cycle, method)
    @schedule << { cycle: cycle, method: method }
    @schedule = @schedule.sort_by { |item| effective_cycle(item[:cycle]) }
  end

  def clear_schedule
    @schedule = []
  end

  def advance_to_cycle(cycle)
    advance while @schedule.any? && @schedule.first[:cycle] <= effective_cycle(cycle)

    @cycle = cycle
  end

  def advance
    return if @schedule.empty?

    next_cycle_with_method = @schedule.first[:cycle]
    @cycle = next_cycle_with_method
    while @schedule.any? && @schedule.first[:cycle] == next_cycle_with_method
      method = @schedule.shift[:method]
      send method
    end
  end

  def execute_next_operation
    cycles_taken = @cpu.execute_next_operation
    schedule_method @cycle + cycles_taken, :execute_next_operation
  end

  private

  def effective_cycle(cycle)
    if cycle < @cycle
      cycle + CYCLES_PER_SECOND
    else
      cycle
    end
  end
end

