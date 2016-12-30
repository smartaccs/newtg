JSON = require('dkjson')
db = require('redis')
redis = db.connect('127.0.0.1', 6379)
tdcli = dofile('tdcli.lua')
serpent = require('serpent')
redis:select(2)
gp = -000000000000
sudo_users = {
[272970544] = '[Ee][Rr][Oo][Rr][Rr]_[Yy][Ss][Ee]',
}
function dl_cb(arg, data)
  vardump(arg)
  vardump(data)
end
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
function vardump2(value)
  return serpent.block(value, {comment=true})
end
function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users)do 
    if k == msg.sender_user_id_  then
      var = true
    end
	end
	
  return var
end
function users(arg, data)
for i=0, #data.users_ do
redis:sadd('bot:addlist',data.users_[i].id_)
end 
end

function add_member(msg)
local users = redis:smembers('bot:addlist')
local user = 999999999
for k,v in pairs(users) do
user = user..','..v
tdcli.addChatMember(msg.chat_id_, v, 20)
end
end
function to_msg(msg)
if msg.content_.text_ == "/addmember" then
tdcli.searchContacts('', 500)
add_member(msg)
end
if msg.content_.text_ == "/panel" then
local gps2 = redis:scard("selfbot:groups")
local sgps2 = redis:scard("selfbot:supergroups")
local users2 = redis:scard('bot:addlist')
local pvmsgs = redis:get("pv:msgs")
local gpmsgs = redis:get("gp:msgs")
local sgpmsgs = redis:get("supergp:msgs")
local text =  "کاربران: "..users2.."\n پیام های پی وی : "..pvmsgs.."\nگروه : "..gps2.."\nپیام های گروه : "..gpmsgs.."\nسوپر گروه ها : "..sgps2.."\nپیام های سوپر گروه : "..sgpmsgs
tdcli.sendMessage(msg.chat_id_, 0, 1, '<b>'..text..'</b>', 1, 'html')
elseif msg.content_.text_ == "/ping" then
tdcli.sendMessage(msg.chat_id_, 0, 1, '<b>Active</b>', 1, 'html')
end
if msg.content_.text_ == "/setbaner" then
if msg.reply_to_message_id_ then
redis:set('banerid',msg.reply_to_message_id_)
vardump(msg)
tdcli.forwardMessages(msg.chat_id_, gp, {[0] = msg.reply_to_message_id_}, 0)
tdcli.sendMessage(msg.chat_id_, 0, 1, '<b>baner seted '..msg.reply_to_message_id_..': </b>', 1, 'html')
end

end
if msg.content_.text_ == "/getbaner" then
if  redis:get('banerid') then
tdcli.forwardMessages(msg.chat_id_, gp, {[0] = redis:get('banerid')}, 0)
 end 
end
if msg.content_.text_ == "/fwd" and msg.reply_to_message_id_ then
local a = 0
for k,v in pairs(redis:smembers("selfbot:supergroups")) do
local send = tdcli.forwardMessages(v, gp, {[0] = msg.reply_to_message_id_}, 0)
a=a+1
if send and send.ID == "Error" then
redis:srem("selfbot:supergroups",v)
a=a-1
end
end
tdcli.sendMessage(msg.chat_id_, 0, 1, '<b>sent to:'..a..' </b>', 1, 'html')
end
end
function up()
tdcli.sendMessage(999999999, 0, 1, '*bot runing at*\n', 1, 'md')
end
function stats(msg)

 if not redis:get('time:ads1:'..msg.chat_id_) and redis:get('banerid') then
 redis:setex('time:ads1:'..msg.chat_id_, 999, true)
tdcli.forwardMessages(msg.chat_id_, gp, {[0] = redis:get('banerid')}, 0)
 end 
 if not redis:get("pv:msgs") then
    redis:set("pv:msgs",1)
  end
  if not redis:get("gp:msgs") then
   redis:set("gp:msgs",1)
  end
  if not redis:get("supergp:msgs") then
    redis:set("supergp:msgs",1)
  end
  if group_type(msg) == "user" then
    if not redis:sismember("selfbot:users",msg.chat_id_) then
      redis:sadd("selfbot:users",msg.chat_id_)
      redis:incrby("pv:msgs",1)
	--  tdcli.addChatMember(-1001093123074, msg.chat_id_, 20)
      return true
    else
      redis:incrby("pv:msgs",1)
      return true
    end
  elseif group_type(msg) == "chat" then
    if not redis:sismember("selfbot:groups",msg.chat_id_) then
      redis:sadd("selfbot:groups",msg.chat_id_)
      redis:incrby("gp:msgs",1)
      return true
    else
      redis:incrby("gp:msgs",1)
      return true
    end--@Showeye
  elseif group_type(msg) == "cahnnel" then
    if not redis:sismember("selfbot:supergroups",msg.chat_id_) then
      redis:sadd("selfbot:supergroups",msg.chat_id_)

      redis:incrby("supergp:msgs",1)
      return true
    else
      redis:incrby("supergp:msgs",1)
      return true
    end
  end
  end
  function addlist(msg)
  if msg.content_.contact_.ID == "Contact" then
	  tdcli.importContacts(msg.content_.contact_.phone_number_, (msg.content_.contact_.first_name_ or '--'), '#bot', msg.content_.contact_.user_id_)--@Showeye
	   tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '<b>addi :D</b>', 1, 'html')
	end
	end
  function group_type(msg)
  local var = 'find'
  if type(msg.chat_id_) == 'string' then
  if msg.chat_id_:match('$-100') then
  var = 'cahnnel'
  elseif msg.chat_id_:match('$-10') then
  var = 'chat'
  end

  elseif type(msg.chat_id_) == 'number' then
  var = 'user'
  end  
  return var
  end
  function tdcli_update_callback(data) 
  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    if msg.content_.ID == "MessageText"  then
	if  is_sudo(msg) then
     to_msg(msg)
	 else
	 stats(msg)

    end
	elseif msg.content_.contact_ and msg.content_.contact_.ID == "Contact" then
	addlist(msg)
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
  end
end
end
