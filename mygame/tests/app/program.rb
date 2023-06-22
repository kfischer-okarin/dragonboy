[
  {
    name: :operation_without_arguments,
    program_code: "\x00",
    expected: { type: :NOP, arguments: [] }
  },
  {
    name: :operation_with_immediate_register_arguments,
    program_code: "\x09",
    expected: { type: :ADD, arguments: [:HL, :BC] }
  },
  {
    name: :operation_with_immediate_n8_arguments,
    program_code: "\x06\x42",
    expected: { type: :LD, arguments: [:B, 0x42] }
  },
  {
    name: :operation_with_immediate_n16_arguments,
    program_code: "\x21\x42\x33",
    expected: { type: :LD, arguments: [:HL, 0x3342] }
  },
  {
    name: :operation_with_nonimmediate_register_arguments,
    program_code: "\x02",
    expected: { type: :LD, arguments: [Program::Pointer[:BC], :A] }
  },
  {
    name: :operation_with_pointer_argument,
    program_code: "\x08\x42\x33",
    expected: { type: :LD, arguments: [Program::Pointer[0x3342], :SP] }
  },
  {
    name: :operation_with_signed_number_argument,
    program_code: "\x18\xFE", # Two's complement of 2 = 0b00000010 is 0b11111110 = 0xFE = -2
    expected: { type: :JR, arguments: [-2] }
  },
  {
    name: :LDI_HL_A,
    program_code: "\x22",
    expected: { type: :LDI, arguments: [Program::Pointer[:HL], :A] }
  },
  {
    name: :LDI_A_HL,
    program_code: "\x2A",
    expected: { type: :LDI, arguments: [:A, Program::Pointer[:HL]] }
  },
  {
    name: :LDHL_SP_e8,
    program_code: "\xF8\xFE", # Two's complement of 2 = 0b00000010 is 0b11111110 = 0xFE = -2
    expected: { type: :LDHL, arguments: [:HL, :SP, -2] }
  },
  {
    name: :LDD_HL_A,
    program_code: "\x32",
    expected: { type: :LDD, arguments: [Program::Pointer[:HL], :A] }
  },
  {
    name: :LDD_A_HL,
    program_code: "\x3A",
    expected: { type: :LDD, arguments: [:A, Program::Pointer[:HL]] }
  }
].each do |test_case|
  define_method "test_program_parse_#{test_case[:name]}" do |_args, assert|
    program = Program.new test_case[:program_code]

    operation = program.parse_operation(0)

    assert.equal! operation, test_case[:expected]
  end
end
