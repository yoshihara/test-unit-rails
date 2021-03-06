# -*- coding: utf-8 -*-
#
# Copyright (C) 2012-2016  Kouhei Sutou <kou@clear-code.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

if Rails.env.production?
  abort("Abort testing: Your Rails environment is running in production mode!")
end

require "test/unit/active_support"
require "test/unit/notify"
require "test/unit/rr"
require "test/unit/capybara"

require "test/unit/assertion-failed-error"

require "capybara/rails"
require "active_support/testing/constant_lookup"
require "action_controller"
require "action_controller/test_case"
require "action_dispatch/testing/integration"

if defined?(ActiveRecord::Migration)
  if ActiveRecord::Migration.respond_to?(:maintain_test_schema!)
    ActiveRecord::Migration.maintain_test_schema!
  else
    ActiveRecord::Migration.check_pending!
  end
end

class ActiveSupport::TestCase
  self.file_fixture_path = "#{Rails.root}/test/fixtures/files" if respond_to?(:file_fixture_path=)
end

if defined?(ActiveRecord::Base)
  class ActiveSupport::TestCase
    include ActiveRecord::TestFixtures
    self.fixture_path = "#{Rails.root}/test/fixtures/"

    setup do
      setup_fixtures
    end

    teardown do
      teardown_fixtures
    end
  end

  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
end

class ActionController::TestCase
  setup do
    @routes = Rails.application.routes
  end

  if defined?(ActiveRecord::Base)
    include ActiveRecord::TestFixtures

    self.fixture_path = "#{Rails.root}/test/fixtures/"
  end
end

class ActionDispatch::IntegrationTest
  setup do
    @routes = Rails.application.routes
  end
  include Capybara::DSL
end
