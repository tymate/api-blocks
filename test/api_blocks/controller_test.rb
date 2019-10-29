require "minitest/autorun"
require "mocha/minitest"
require "api_blocks"
require "action_controller"

describe ApiBlocks::Controller do
  class FooPolicy
    def initialize(_record, _user)
    end

    def bar?
      true
    end
  end

  class TestController < ActionController::API
    include ApiBlocks::Controller

    pundit_scope :api, :v1

    def current_user
      nil
    end
  end

  it 'overrides pundit policy finders to prepend scope' do
    controller = TestController.new

    policy_finder = mock('Pundit::PolicyFinder')
    policy_finder.expects(:scope!)
    policy_finder.expects(:policy!).returns(
      stub(new: stub(bar?: true))
    )

    Pundit::PolicyFinder
      .expects(:new)
      .with([:api, :v1, :foo])
      .returns(policy_finder)
      .twice

    controller.policy_scope(:foo)
    controller.instance_eval { authorize(:foo, :bar?) }
  end
end
