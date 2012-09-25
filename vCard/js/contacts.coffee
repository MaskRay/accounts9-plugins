SITE = 'http://maskray.tk/accounts9-contacts/'
USERINFO = 'https://accounts9.net9.org/api/userinfo'
GROUPINFO = 'https://accounts9.net9.org/api/groupinfo'
AUTHORIZE = 'https://accounts9.net9.org/api/authorize'
ACCESS_TOKEN = 'https://accounts9.net9.org/api/access_token'

CLIENT_ID = 'sXhBNg89Mso8ncrN99DmIiMR4Eg'
CLIENT_SECRET = 'AsSlZxpyi2VW3RHdN4Ei'

isoDate = (d) ->
  pad = (n) -> if n < 10 then '0'+n else n
  ''+d.getUTCFullYear()+
    pad(d.getUTCMonth()+1) +
    pad(d.getUTCDate())+'T'+
    pad(d.getUTCHours())+
    pad(d.getUTCMinutes())+
    pad(d.getUTCSeconds())+'Z'

parseComps = (loc) ->
  loc = loc.substring 1 if '?#'.indexOf(loc[0]) != -1
  res = {}
  for q in loc.split '&'
    pair = q.split '='
    res[decodeURIComponent pair[0]] = decodeURIComponent pair[1]
  res

comps =
  response_type: 'code'
  redirect_uri: SITE
  scope: 'https://accounts.net9.org/api'
  client_id: CLIENT_ID

accounts9_access_token = null

showClassmates = () ->
  return unless accounts9_access_token
  $('#nav').empty().append('<li id="username"></li>').append '<li><a class="btn" href="/accounts9_contacts">登出</a></li>'
  $.getJSON USERINFO, access_token: accounts9_access_token, (data) ->
    $('#username').text data.user.fullname
    for clas in data.user.groups
      if /^class/.test clas
        $('#export').show()
        $.getJSON GROUPINFO, access_token: accounts9_access_token, group: clas, (data) ->
          vcards = []
          cnt = data.group.users.length
          for user in data.group.users
            $.getJSON USERINFO, access_token: accounts9_access_token, user: user, (data) ->
              u = data.user
              td = (s) -> $('<td/>').text s
              $('#classmates').append $('<tr/>')
                .append(td(u.fullname))
                .append(td(u.nickname))
                .append(td(u.email))
                .append(td(u.mobile))
                .append(td(u.birthdate))

              vcards.push 'BEGIN:VCARD'
              vcards.push 'VERSION:4.0'
              vcards.push 'FN:' + u.fullname
              vcards.push 'NICKNAME:' + u.nickname
              vcards.push 'BDAY:' + u.birthdate
              vcards.push 'TEL:' + u.mobile
              vcards.push 'EMAIL:' + u.email
              vcards.push 'REL:' + isoDate(new Date())
              vcards.push 'END:VCARD'

              if --cnt is 0
                $('#export').prop 'href', 'data:text/vcard;base64,' + Base64.encode(vcards.join('\n'))
                $('#export').prop 'download', 'contacts.vcf'

$ ->
  $('#export').hide()
  $('#login').prop 'href', AUTHORIZE+'?'+$.param(comps)

  query = parseComps window.location.search

  if query.code
    comps =
      response_type: 'token'
      redirect_uri: SITE
      scope: 'https://accounts.net9.org/api'
      client_id: CLIENT_ID
      client_secret: CLIENT_SECRET
      code: query['code']
    $.getJSON ACCESS_TOKEN, comps, (data) ->
      accounts9_access_token = data.access_token
      showClassmates()
