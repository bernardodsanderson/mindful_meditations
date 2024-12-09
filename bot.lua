-- config.lua
-- return {
--   bot_token = "<YOUR_BOT_TOKEN>",
--   meditations = {
--     {title = "Beyond 3 Bodies", file_id = ""},
--     {title = "Conscious Visualization", file_id = ""},
--     {title = "Morning Meditation on Brahman", file_id = ""},
--     {title = "Purusha Suktam - Vedic Meditation on the Cosmic Being", file_id = ""},
--     {title = "Nididhyasana", file_id = ""},
--     {title = "Non-duality Experience", file_id = ""}
--   }
-- }


local config = require('config')
local api = require('telegram-bot-lua.core').configure(config.bot_token)

-- Use config.meditations instead of the hardcoded meditations table
local meditations = config.meditations

-- Function to create the meditation list keyboard
local function get_meditation_keyboard()
  local keyboard = {}
  local current_row = {}
  
  for i, meditation in ipairs(meditations) do
    table.insert(current_row, meditation.title)
    
    -- Create a new row after every 2 items or at the end
    if #current_row == 2 or i == #meditations then
      table.insert(keyboard, current_row)
      current_row = {}
    end
  end
  
  return keyboard
end

-- Handle incoming messages
function api.on_message(message)
  if message.text == "/start" then
    api.send_message(
      message.chat.id,
      "Welcome to Mindful Meditations! Choose a meditation to begin:",
      nil,
      "markdown",
      nil,
      nil,
      nil,
      nil,
      nil,
      {
        keyboard = get_meditation_keyboard(),
        resize_keyboard = true,
        one_time_keyboard = true
      }
    )
  else
    -- Check if the message matches any meditation title
    for i, meditation in ipairs(meditations) do
      if message.text == meditation.title then
        api.send_audio(
          message.chat.id,
          meditation.file_id,
          nil,
          meditation.title
        )
        -- Show the meditation list keyboard again
        api.send_message(
          message.chat.id,
          "Choose another meditation:",
          nil,
          "markdown",
          nil,
          nil,
          nil,
          nil,
          nil,
          {
            keyboard = get_meditation_keyboard(),
            resize_keyboard = true,
            one_time_keyboard = true
          }
        )
        return
      end
    end
  end
end

-- Start the bot
api.run()