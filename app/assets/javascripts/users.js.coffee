
$ ->
  $('input[type=checkbox][name="user[send_standup_report]"], 
     input[type=checkbox][name="user[disabled]"], 
     input[type=checkbox][name="user[admin]"]').on 'change', ->
    $(this).parents('form').submit()

