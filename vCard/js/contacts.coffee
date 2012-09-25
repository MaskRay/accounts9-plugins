SITE = 'http://maskray.tk/accounts9-contacts/'
#SITE = 'http://localhost/accounts9-contacts/'
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


accounts9_access_token = null

showGroup = ->
  return unless accounts9_access_token
  group = $(this).text()
  $('#colleague tr:not(:first)').remove()
  $('#groups a').removeClass 'navy'
  $(this).addClass 'navy'
  console.log this
  $.getJSON GROUPINFO, access_token: accounts9_access_token, group: group, (data) ->
    vcards = []
    cnt = data.group.users.length

    $('#export').unbind().click (ev) ->
      ev.preventDefault()
      vcards = []
      $('#colleague tr:gt(0)').each ->
        vcards.push 'BEGIN:VCARD'
        vcards.push 'VERSION:4.0'
        vcards.push 'FN:' + @cells[0].textContent
        vcards.push 'NICKNAME:' + @cells[1].textContent
        vcards.push 'EMAIL:' + @cells[2].textContent
        vcards.push 'TEL:' + @cells[3].textContent
        vcards.push 'BDAY:' + this.cells[4].textContent
        vcards.push 'REL:' + isoDate(new Date())
        vcards.push 'END:VCARD'
      window.location.href = 'data:text/vcard;base64,' + Base64.encode(vcards.join('\n'))

    for user in data.group.users
      $.getJSON USERINFO, access_token: accounts9_access_token, user: user, (data) ->
        u = data.user
        td = (s) -> $('<td contenteditable>').text s
        $('#colleague').append $('<tr/>')
          .append(td(u.fullname))
          .append(td(u.nickname))
          .append(td(u.email))
          .append(td(u.mobile))
          .append(td(u.birthdate))


showGroups = () ->
  return unless accounts9_access_token
  $('#nav').empty().append('<li><a class="btn" id="username"></a></li>').append '<li><a class="btn" href="/accounts9_contacts">登出</a></li>'
  $.getJSON USERINFO, access_token: accounts9_access_token, (data) ->
    $('#username').text data.user.fullname
    clas = null
    for group in data.user.groups
      a = $('<a class="btn" href="#">').text(group).click showGroup
      $('#groups').append $('<li>').append a
      if /^class/.test group
        clas = a
    showGroup.call clas if clas

$ ->
  $('#login').prop 'href', AUTHORIZE+'?'+$.param(
    response_type: 'code'
    redirect_uri: SITE
    scope: 'https://accounts.net9.org/api'
    client_id: CLIENT_ID
  )

  query = parseComps window.location.search

  if query.access_token
    accounts9_access_token = query.access_token
    showGroups()
  else if query.code
    comps =
      response_type: 'token'
      redirect_uri: SITE
      scope: 'https://accounts.net9.org/api'
      client_id: CLIENT_ID
      client_secret: CLIENT_SECRET
      code: query['code']
    $.getJSON ACCESS_TOKEN, comps, (data) ->
      history.replaceState null, document.title, '?access_token=' + data.access_token
      accounts9_access_token = data.access_token
      showGroups()
