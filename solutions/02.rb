class Task
  attr_reader :status, :description, :priority, :tags

  def initialize arguments
    @status = arguments[0].strip.downcase.to_sym
    @description = arguments[1].strip
    @priority = arguments[2].strip.downcase.to_sym
    @tags = arguments[3].nil? ? %w[] : arguments[3].split(%r{\s*\,\s*})
  end
end

class Criteria
  attr_reader :criterias

  def initialize criterias
    @criterias = criterias
  end

  def self.status status
    Criteria.new lambda{ |todo| todo.equals_status?(status) }
  end

  def self.priority priority
    Criteria.new lambda { |todo| todo.equals_priority?(priority) }
  end

  def self.tags tag_list
    Criteria.new lambda { |todo| todo.contains_all_tags?(tag_list) }
  end

  def &(other)
    intnersect_criterias = lambda do |todo|
      criterias.call(todo) && other.criterias.call(todo)
    end
    Criteria.new intnersect_criterias
  end

  def |(other)
    union_criterias = lambda do |todo|
      criterias.call(todo) || other.criterias.call(todo)
    end
    Criteria.new union_criterias
  end

  def !
    Criteria.new lambda { |todo| !criterias.call(todo) }
  end
end

class TodoList
  include Enumerable
  attr_reader :todo_list

  def initialize(list)
    @todo_list = list
  end

  def self.parse text
    todo = TodoList.new []
    text.each_line(separator=$/) do |line|
      todo.todo_list << Todo.new(line.split(%r{\s*\|\s*}))
    end
    todo
  end

  def each(&block)
    @todo_list.each(&block)
  end

  def filter(criteria)
    TodoList.new select(&criteria.criterias)
  end

  def adjoin(other)
    TodoList.new(@todo_list | other.todo_list)
  end

  def tasks_todo
    @todo_list.count{|task| task.status == :todo}
  end

  def tasks_in_progress
    @todo_list.count{|task| task.status == :current}
  end

  def tasks_completed
    @todo_list.count{|task| task.status == :done}
  end

  def completed?
    tasks_completed == self.length
  end
end