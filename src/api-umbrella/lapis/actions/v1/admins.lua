local respond_to = require("lapis.application").respond_to
local Admin = require "api-umbrella.lapis.models.admin"
local dbify_json_nulls = require "api-umbrella.utils.dbify_json_nulls"
local lapis_json = require "api-umbrella.utils.lapis_json"
local json_params = require("lapis.application").json_params
local lapis_helpers = require "api-umbrella.utils.lapis_helpers"
local lapis_datatables = require "api-umbrella.utils.lapis_datatables"

local capture_errors_json = lapis_helpers.capture_errors_json

local _M = {}

local function set_current_admin(self)
  local current_admin
  local auth_token = ngx.var.http_x_admin_auth_token
  if auth_token then
    local admin = Admin:find({ authentication_token_hash = auth_token })
    if not admin:is_access_locked() then
      current_admin = admin
    end
  end

  self.current_admin = current_admin
end

function _M.index(self)
  return lapis_datatables.index(self, Admin, {
    search_fields = {
      "first_name",
      "last_name",
      "email",
      "username",
      "authentication_token",
    },
    preload = { "groups" },
  })
end

function _M.show(self)
  local response = {
    admin = self.admin:as_json(),
  }

  return lapis_json(self, response)
end

function _M.create(self)
  local admin = assert(Admin:create(_M.admin_params(self)))
  local response = {
    admin = admin:as_json(),
  }

  self.res.status = 201
  return lapis_json(self, response)
end

function _M.update(self)
  self.admin:update(_M.admin_params(self))

  return { status = 204 }
end

function _M.destroy(self)
  self.admin:delete()

  return { status = 204 }
end

function _M.admin_params(self)
  local params = {}
  if self.params and self.params["admin"] then
    local input = self.params["admin"]
    params = dbify_json_nulls({
      username = input["username"],
      password = input["password"],
      password_confirmation = input["password_confirmation"],
      current_password = input["current_password"],
      email = input["email"],
      name = input["name"],
      notes = input["notes"],
      superuser = input["superuser"],
      group_ids = input["group_ids"],
    })
    ngx.log(ngx.NOTICE, "INPUTS: " .. inspect(params))
  end

  return params
end

return function(app)
  app:match("/api-umbrella/v1/admins/:id(.:format)", respond_to({
    before = function(self)
      self.admin = Admin:find(self.params["id"])
      if not self.admin then
        self:write({"Not Found", status = 404})
      end
    end,
    GET = _M.show,
    POST = capture_errors_json(json_params(_M.update)),
    PUT = capture_errors_json(json_params(_M.update)),
    DELETE = _M.destroy,
  }))

  app:get("/api-umbrella/v1/admins(.:format)", _M.index)
  app:post("/api-umbrella/v1/admins(.:format)", capture_errors_json(json_params(_M.create)))
end
