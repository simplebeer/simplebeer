require "highline/import"

admin_email = ask("Email address for admin:") {|q| q.default = "admin@codelation.com" }
admin_password = ask("password for admin:")   {|q| q.echo = "*"; q.default = "password123" }

admin_user = AdminUser.create({
  email:    admin_email,
  password: admin_password
})
