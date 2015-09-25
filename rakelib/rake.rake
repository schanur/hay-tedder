require 'securerandom'

def rand_task_string
  return SecureRandom.hex
end

def rand_task_symbol
  return rand_task_string().to_sym
end

def task_list_with_options(task_list, *opt_list)
  meta_task_list = []
  task_list.each do |task_item|
    meta_task_name = 'meta_task' \
                     + '__rand:' + rand_task_string \
                     + '__type:' + task_item.class.to_s \
                     + '__name:' + task_item.to_s
    task meta_task_name do
      Rake::Task[task_item].invoke(*opt_list)
    end
    meta_task_list.push(meta_task_name)
  end
  return meta_task_list
end

def parallel_invoke(task_list)
  rand_task = rand_task_symbol()
  multitask  rand_task => task_list
  Rake::Task[rand_task].invoke
end
