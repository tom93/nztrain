authorization do
  role :superadmin do
    has_omnipotence
  end
  role :admin do
    includes :staff
    has_permission_on :roles, :to => :inspect
    has_permission_on :roles, :to => :regrant do
      if_attribute :name => is_not{'superadmin'}
    end
    has_permission_on :users, :to => :manage do
      if_attribute :is_superadmin? => is_not{true}, :id => is_not{0}
    end
    has_permission_on :groups, :to => :manage do
      if_attribute :id => is_not{0}
    end
    has_permission_on [:problems, :problem_sets, :contests, :test_cases, :test_sets, :evaluators, :submissions], :to => :manage
  end
  role :staff do
    includes :organiser
    has_permission_on :users, :to => [:inspect, :add_brownie]
    has_permission_on :groups, :to => :inspect
    has_permission_on :problems, :problem_sets, :contest, :test_cases, :test_sets, :evaluators, :to => :inspect
    has_permission_on :roles, :to => :read
    has_permission_on :roles, :to => :regrant, :join_by => :and do
      if_attribute :name => is_not{'superadmin'}
      if_attribute :name => is_not{'admin'}
      if_attribute :name => is_not{'staff'}
    end
    has_permission_on [:problems, :problem_sets, :contests, :test_cases, :test_sets, :evaluators, :submissions], :to => :inspect
    has_permission_on :problems, :to => :submit
    has_permission_on [:problems, :problem_sets], :to => :transfer do
      if_attribute :owner => is{user}
    end
  end
  role :organiser do
    includes :author
    has_permission_on :groups, :to => :manage do
      if_attribute :owner => is{user}
    end
    has_permission_on :contests, :to => :manage do
      if_attribute :owner => is{user}
    end
  end
  role :author do
    has_permission_on :problem_sets, :to => :manage do
      if_attribute :owner => is{user}
    end
  end
  role :user do
    has_permission_on :users, :to => :read
    has_permission_on :groups, :to => :read do
      if_attribute :users => contains{user}
      if_attribute :id => 0
    end
    has_permission_on :contests, :to => :index do
      if_attribute :groups => {:id => 0}
      if_attribute :groups => {:users => contains{user}}
      if_attribute :contest_relations => {:user => is{user}}
    end
    has_permission_on :contests, :to => :show do
      if_attribute :contest_relations => {:user => is{user}}
    end
    has_permission_on :contests, :to => :start, :join_by => :and do
      if_attribute :users => does_not_contain{user}, :start_time => lte{DateTime.now}, :end_time => gt{DateTime.now}
      if_permitted_to :index
    end
    has_permission_on :problems, :to => :read do
      if_permitted_to :read, :problem_sets
    end
    has_permission_on :groups, :to => :read
    has_permission_on :groups, :to => :join do
      if_attribute :users => does_not_contain{user}, :id => is_not{0}
    end
    has_permission_on :groups, :to => :leave do
      if_attribute :users => is{user}
    end
    has_permission_on :submissions, :to => :read do
      if_attribute :problem => {:problem_set => {:contests => {:contest_relations => {:user => is{user}, :started_at => lte{DateTime.now}, :finish_at => gt{DateTime.now}}}}}
    end
    has_permission_on :problems, :to => :submit do
      if_permitted_to :read
    end
  end
  # user in closed book contest
  role :closedbook do
    has_permission_on :problem_sets, :to => :read do
      if_attribute :contests => {:contest_relations => {:user => is{user}, :started_at => lte{DateTime.now}, :finish_at => gt{DateTime.now}}}
    end
  end
  # users not in a contest or in open book contest
  role :openbook do
    has_permission_on :problem_sets, :to => :read do
      if_attribute :groups => {:id => 0}
      if_attribute :groups => {:users => contains{user}}
      if_attribute :contests => {:contest_relations => {:user => is{user}, :started_at => lte{DateTime.now}, :finish_at => gt{DateTime.now}}}
    end
    has_permission_on :submissions, :to => :read do
      if_permitted_to :submit, :problem
    end
    has_permission_on :problems, :to => :manage do
      if_attribute :owner => is{user}
    end
  end
  role :guest do

  end
end
privileges do
  privilege :manage do
    includes :create, :inspect, :update, :delete
  end
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
  privilege :regrant, :includes => [:grant, :revoke]
  privilege :read, :includes => [:index, :show]
  privilege :inspect, :includes => :read
end
