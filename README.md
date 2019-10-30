[gem]: https://rubygems.org/gems/api-blocks
[code_climate]: https://codeclimate.com/github/tymate/api-blocks
[inch]: https://inch-ci.org/github/tymate/api-blocks?branch=master

# ApiBlocks

[![Gem](https://img.shields.io/gem/v/api-blocks?style=flat-square)][gem]
[![Code Climate](https://img.shields.io/codeclimate/maintainability/tymate/api-blocks?style=flat-square)][code_climate]
[![Inch](https://inch-ci.org/github/tymate/api-blocks.svg?branch=master)][inch]

ApiBlocks provides simple and consistent Rails API extensions.

Links:

- [API Documentation](https://www.rubydoc.info/gems/api-blocks/0.1.1)
- [Source Code](https://github.com/tymate/api-blocks)

## Installation

```ruby
gem 'api-blocks'
```

## ApiBlocks::Controller

Include `ApiBlocks::Controller` in your api controller:

```ruby
class Api::V1::ApplicationController < ActionController::API
  include ApiBlocks::Controller

  pundit_scope :api, :v1
end
```

Including the module will:

- Setup [ApiBlocks::Responder](#ApiBlocks::Responder) as a responder.
- Add the `verify_request_format!` before_action hook.
- Setup Pundit, rescue its errors, setup its validation hooks and provide the `pundit_scope` method.

## ApiBlocks::Responder

An `ActionController::Responder` with better error handling and `Dry::Monads::Result` support.

Errors are handled for the following cases:

- The responded resource is an `ApplicationRecord` subclass and has error.
- The responded resource is a `ActiveRecord::RecordInvalid` exception.
- Otherwise the error is re-raised to be handled through the usual Ruby On Rails
  error handlers.

In addition, the responder will render resources on `POST` and `PUT` rather than
returning a redirection.

## ApiBlocks::Interactor

It implements a basic interactor base class using `dry-transaction` and `dry-validation` under the hood.

It provides to predefined steps:

- `validate_input!` which will validate the interactor input according to its schema.
- `database_transaction!` an around step that wraps the interactor in an
  ActiveRecord transaction.

Example:

```ruby
class Requests::MarkAsRead < ApiBlocks::Interactor
  input do
    schema do
      required(:request).filled(type?: Request)
    end
  end

  around :database_transaction!
  step :validate_input!

  try :update_request!, catch: ActiveRecord::RecordInvalid
  try :create_history_item!, catch: ActiveRecord::RecordInvalid

  def update_request!(request:)
    request.update!(read_at: Time.now.utc)
    request
  end

  def create_history_item!(request)
    request.request_history_items.create!(kind: :read)
    request
  end
end
```

## ApiBlocks::Doorkeeper::Passwords

Implement an API for passwords reset using doorkeeper and devise.

Include the `ApiBlocks::Doorkeeper::Passwords::Controller` module in your
passwords api controller and define the `user_model` method to return the
concerned devise user model.

```ruby
# app/controllers/api/v1/passwords_controller.rb
class Api::V1::PasswordsController < Api::V1::ApplicationController
  include ApiBlocks::Doorkeeper::Passwords::Controller

  private

  def user_model
    User
  end
end
```

Then add the approriate routes to your configuration.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  scope module: :api do
    namespace :v1 do
      resources :passwords, only: %i[create] do
        get :callback, on: :collection
        put :update, on: :collection
      end
    end
  end
end
```

Include the `ApiBlocks::Doorkeeper::ResetPassword` module so devise will forward
the doorkeeper application to the mailer.

```ruby
# app/models/user.rb
class User < ApplicationRecord
  include ApiBlocks::Doorkeeper::ResetPassword
end
```

Override your devise mailer `#reset_password_instructions` method to add the
`application` parameter.

```ruby
# app/mailers/devise_mailer.rb

class DeviseMailer < Devise::Mailer
  def reset_password_instructions(record, token, application = nil, _opts = {})
    @token = token
    @application = application
  end
end
```

Update the devise mailer template to link to the callback API.

```erb
# app/views/devise/mailer/invitation_instructions.html.erb
<p><%= link_to t("devise.mailer.invitation_instructions.accept"), callback_v1_invitations_url(invitation_token: @token, client_id: @application.uid) %></p>
```

Finally, generate the required migrations:

```sh
bundle exec rails g api_blocks:doorkeeper:passwords:migration
```

# External Resources

- [Pundit](https://github.com/varvet/pundit)
- [Responders](https://github.com/plataformatec/responders)
- [Dry Transaction](https://dry-rb.org/gems/dry-transaction/0.13/)
- [Dry Validation](https://dry-rb.org/gems/dry-validation/1.3/)

# License

Licensed under the MIT license, see the separate LICENSE.txt file.
