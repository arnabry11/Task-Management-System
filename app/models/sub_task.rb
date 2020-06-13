class SubTask < ApplicationRecord
  belongs_to :task, required: true

  before_validation { self.name = name.to_s.squeeze(" ").strip.capitalize }

  validates :name, presence: true, length: { in: 3..255 }

  scope :find_subtasks, ->(task_id = null) { where(task_id: task_id) }
  scope :find_not_submitted_subtasks, ->(task_id = null) { where(task_id: task_id, submit: false)}

  def self.all_subtasks_submitted(task)
    @subtasks = SubTask.find_not_submitted_subtasks(task.id)
    return @subtasks.blank? 
  end
end
