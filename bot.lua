-- config.lua
-- return {
--   bot_token = "<YOUR_BOT_TOKEN>",
--   meditations = {
--     {title = "Beyond 3 Bodies", file_path = "meditations/beyond_3_bodies.mp3"},
--     {title = "Conscious Visualization", file_path = "meditations/conscious_visualization.mp3"},
--     {title = "Morning Meditation on Brahman", file_path = "meditations/morning_meditation_brahman.mp3"},
--     {title = "Purusha Suktam - Vedic Meditation on the Cosmic Being", file_path = "meditations/purusha_suktam.mp3"},
--     {title = "Nididhyasana", file_path = "meditations/nididhyasana.mp3"},
--     {title = "Non-duality Experience", file_path = "meditations/non_duality_experience.mp3"}
--   },
--   affirmations = {
--     {
--       category = "Health",
--       text = "I am the infinite consciousness. The source of creation is within me and works for me. My body is now glowing with perfect health and wellbeing."
--     },
--   }
-- }


local config = require('config')
local api = require('telegram-bot-lua.core').configure(config.bot_token)
local json = require('cjson') -- Make sure to require json

-- Use config.meditations and config.affirmations
local meditations = config.meditations
local affirmations = config.affirmations

-- Function to get the main menu keyboard with the Mini App button
local function get_main_menu_keyboard()
  return {
    keyboard = {
      {
        {
          text = "Open Mindful Meditations",
          web_app = {url = config.webapp_url}
        }
      }
    },
    resize_keyboard = true
  }
end

-- Handle incoming messages
function api.on_message(message)
  if message.text == "/start" then
    api.send_message(
      message.chat.id,
      "Welcome to Mindful Meditations! Click the button below to open the app:",
      nil,
      "markdown",
      nil,
      nil,
      nil,
      nil,
      nil,
      get_main_menu_keyboard()
    )
  elseif message.web_app_data then
    -- Handle web app data
    local success, data = pcall(json.decode, message.web_app_data.data)
    if not success then
      api.send_message(
        message.chat.id,
        "Sorry, there was an error processing your request. Please try again.",
        nil,
        "markdown"
      )
      return
    end
    
    if data.action == "play_meditation" then
      local meditation_index = data.meditation_index + 1 -- +1 because Lua arrays start at 1
      local meditation = meditations[meditation_index]
      
      if not meditation then
        api.send_message(
          message.chat.id,
          "Sorry, couldn't find the selected meditation. Please try another one.",
          nil,
          "markdown"
        )
        return
      end

      -- First, inform the user that we're processing their request
      api.send_message(
        message.chat.id,
        "🎵 Preparing your meditation: *" .. meditation.title .. "*",
        nil,
        "markdown"
      )
      
      -- Send the meditation audio
      local success, result = pcall(function()
        return api.send_audio(
          message.chat.id,
          meditation.file_path, -- This is now a URL
          nil, -- duration
          "Mindful Meditations", -- performer
          meditation.title, -- title
          nil, -- disable_notification
          nil, -- reply_to_message_id
          nil, -- reply_markup
          "🧘‍♂️ " .. meditation.title .. "\n\nTake a moment to center yourself and find peace." -- caption
        )
      end)
      
      if not success then
        print("Error sending audio:", result) -- Log the error
        api.send_message(
          message.chat.id,
          "Sorry, there was an error playing this meditation. Please try again later.",
          nil,
          "markdown"
        )
      end
    end
  end
end

-- Start the bot
api.run()