def test_program_parse_operation_without_arguments(_args, assert)
  program = Program.new "\x00"

  operation = program.parse_operation(0)

  assert.equal! operation, { type: :NOP }
end
