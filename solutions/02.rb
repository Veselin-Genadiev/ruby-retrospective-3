class Task
  attr_reader :status, :description, :priority, :tags

  def initialize arguments
    @status = arguments[0].strip.downcase.to_sym
    @description = arguments[1].strip
    @priority = arguments[2].strip.downcase.to_sym
    @tags = arguments[3] ? arguments[3].split(',').each(&:strip!) : []
  end

  def self.create_task line
    Task.new line.split('|')
  end
end

class Criteria
  attr_accessor :block

  def initialize(&block)
    @block = block
  end

  def self.status(status)
    Criteria.new { |task| task.status.equal? status }
  end

  def self.priority(priority)
    Criteria.new { |task| task.priority.equal? priority }
  end

  def self.tags(tags)
    Criteria.new { |task| (tags & task.tags).size.equal? tags.size }
  end

  def &(other)
    Criteria.new { |task| block.call(task) && other.block.call(task) }
  end

  def |(other)
    Criteria.new { |task| block.call(task) || other.block.call(task) }
  end

  def !
    Criteria.new { |task| !block.call(task) }
  end
end

class TodoList
  include Enumerable

  attr_accessor :tasks

  def initialize(tasks)
    @tasks = tasks
  end

  def self.parse(text)
    tasks = text.lines.map { |line| Task.create_task(line) }
    TodoList.new(tasks)
  end

  def completed?
    tasks.all? { |task| task.status.equal? :done }
  end

  def tasks_todo
    tasks.select { |task| task.status.equal? :todo }.size
  end

  def tasks_in_progress
    tasks.select { |task| task.status.equal? :current }.size
  end

  def tasks_completed
    tasks.select { |task| task.status.equal? :done }.size
  end

  def filter(criteria)
    TodoList.new(tasks.select(&criteria.block))
  end

  def adjoin(other)
    TodoList.new(tasks | other.tasks)
  end

  def each
    tasks.each { |task| yield(task) }
  end
end