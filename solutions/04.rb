module Asm
  module Instructions
    class Mov < Struct.new :destination, :source
      def execute(cpu)
        cpu.registers[destination] = cpu.get_value source
      end
    end

    class Inc < Struct.new :destination, :value
      def execute(cpu)
        cpu.registers[destination] += value.nil? ? 1 : cpu.get_value(value)
      end
    end

    class Dec < Struct.new :destination, :value
      def execute(cpu)
        cpu.registers[destination] -= value.nil? ? 1 : cpu.get_value(value)
      end
    end

    class Cmp < Struct.new :register, :value
      def execute(cpu)
        cpu.cmp_result = cpu.registers[register] <=> cpu.get_value(value)
      end
    end

    class Jmp < Struct.new :where
      def execute(cpu)
        cpu.jump_to where
      end
    end

    CONDITIONAL_JUMPS = {
        je:  :==,
        jne: :'!=',
        jl:  :<,
        jle: :<=,
        jg:  :>,
        jge: :>=,
    }.freeze

    def self.define_jump_instruction(instruction_name, comparator)
      jump_class = Struct.new :where do
        define_method :execute do |cpu|
          cpu.jump_to where if cpu.cmp_result.public_send comparator, 0
        end
      end

      const_set instruction_name.capitalize, jump_class
    end

    CONDITIONAL_JUMPS.each do |class_name, comparator|
      define_jump_instruction(class_name, comparator)
    end
  end

  class CPU
    attr_reader   :registers, :labels
    attr_accessor :instructions, :cmp_result

    def initialize(registers)
      @registers           = Hash[registers.map { |name| [name.to_sym, 0] }]
      @labels              = {}
      @instructions        = []
      @instruction_pointer = 0
    end

    def method_missing(name, *args)
      if Instructions.const_defined?(name.capitalize)
        instructions.push Instructions.const_get(name.capitalize).new *args
      else
        name
      end
    end

    def get_value(value_or_register)
      if value_or_register.is_a? Symbol
        registers[value_or_register]
      else
        value_or_register
      end
    end

    def jump_to(value_or_label)
      if value_or_label.is_a? Symbol
        @instruction_pointer = labels[value_or_label] - 1
      else
        @instruction_pointer = value_or_label - 1
      end
    end

    def label(name)
      labels[name] = instructions.size
    end

    def run
      while @instruction_pointer.between?(0, instructions.size - 1)
        instructions[@instruction_pointer].execute self
        @instruction_pointer += 1
      end

      registers.values
    end
  end

  def self.asm(&block)
    cpu = CPU.new %w(ax bx cx dx)
    cpu.instance_eval(&block)

    cpu.run
  end

end