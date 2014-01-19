module Asm
  def self.asm(&block)
    memory = Memory.new
    memory.read(&block)
  end

  class BasicOperations
    def initialize memory
      @memory = memory
    end

    def cmp register, value
      @memory.last_compare = @memory.registers[register] <=> get_value(value)
      nil
    end

    def dec destination_register, value
      @memory.registers[destination_register] -= get_value(value)
      nil
    end

    def inc destination_register, value
      @memory.registers[destination_register] += get_value(value)
      nil
    end

    def mov destination_register, source
      @memory.registers[destination_register] = get_value(source)
      nil
    end

    private

    def get_value source
      if source.is_a?(Symbol)
        @memory.registers[source]
      else
        source
      end
    end
  end

  class JumpOperations
    def initialize memory
      @memory = memory
    end

    def jmp where
      @memory.labels[where]
    end

    def je where
      return @memory.labels[where] if @memory.last_compare == 0
      nil
    end

    def jne where
      return @memory.labels[where] if @memory.last_compare != 0
      nil
    end

    def jl where
      return @memory.labels[where] if @memory.last_compare < 0
      nil
    end

    def jle where
      return @memory.labels[where] if @memory.last_compare <= 0
      nil
    end

    def jg where
      return @memory.labels[where] if @memory.last_compare > 0
      nil
    end

    def jge where
      return @memory.labels[where] if @memory.last_compare >= 0
      nil
    end
  end

  class Memory
    attr_accessor :registers, :instructions, :labels, :last_compare

    BASIC_OPERATIONS = ["mov", "inc", "dec", "cmp"]
    JUMP_OPERATIONS = ["jmp", "je", "jne", "jl", "jle", "jg", "jge"]

    def initialize
      @registers = { ax: 0, bx: 0, cx: 0, dx: 0 }
      @instructions = []
      @labels = {}
      @last_compare = 0
      @basic_operations = Asm::BasicOperations.new self
      @jump_operations = Asm::JumpOperations.new self
    end

    def method_missing(name, *args)
      if BASIC_OPERATIONS.include?(name.to_s) || JUMP_OPERATIONS.include?(name.to_s)
        @instructions << [name.to_s, args]
      elsif name.to_s == "label"
        @labels[args.first] = @instructions.length
      else
        name
      end
    end

    def respond_to?(method_name, include_private = false)
      BASIC_OPERATIONS.include?(method_name) || JUMP_OPERATIONS.include?(method_name)
    end

    def load(&block)
      self.instance_exec(&block)
    end

    def run
      instruction_index = 0
      until(instruction_index == @instructions.length)
        instruction = @instructions[instruction_index]
        operation_result = execute_operation(instruction[0], *instruction[1])
        if operation_result
          instruction_index = operation_result
        else
          instruction_index += 1
        end
      end
    end

    def read(&block)
      load(&block)
      run
      @registers.values
    end

    private

    def execute_operation operation, *args
      if BASIC_OPERATIONS.include?(operation)
        @basic_operations.send(operation, *args)
      elsif JUMP_OPERATIONS.include?(operation)
        @jump_operations.send(operation, *args)
      else
        ::Kernel.raise "Unknown operation!"
      end
    end
  end
end