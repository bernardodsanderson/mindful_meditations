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

-- Use config.meditations and config.affirmations
local meditations = config.meditations
local affirmations = config.affirmations

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

-- Function to format all affirmations as a single message
local function get_all_affirmations_text()
  local text = "*Daily Conscious Affirmations*\n\n"
  for _, affirmation in ipairs(affirmations) do
    text = text .. "*" .. affirmation.category .. "*\n" .. affirmation.text .. "\n\n"
  end
  return text
end

-- Function to get the main options keyboard (changed to regular keyboard)
local function get_main_options_keyboard()
  return {
    keyboard = {
      {
        {text = "🧘 Meditations"},
        {text = "✨ Conscious Affirmations"}
      }
    },
    resize_keyboard = true
  }
end

-- Function to get meditation inline keyboard
local function get_meditation_inline_keyboard()
  local keyboard = {inline_keyboard = {}}
  local current_row = {}
  
  for i, meditation in ipairs(meditations) do
    table.insert(current_row, {
      text = meditation.title,
      callback_data = "meditation_" .. i
    })
    
    -- Create a new row after every 2 items or at the end
    if #current_row == 2 or i == #meditations then
      table.insert(keyboard.inline_keyboard, current_row)
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
      "Welcome! Choose what you'd like to explore:",
      nil,
      "markdown",
      nil,
      nil,
      nil,
      nil,
      nil,
      get_main_options_keyboard()
    )
  elseif message.text == "🧘 Meditations" then
    api.send_message(
      message.chat.id,
      "Choose a meditation to begin:",
      nil,
      "markdown",
      nil,
      nil,
      nil,
      nil,
      nil,
      get_meditation_inline_keyboard()
    )
  elseif message.text == "✨ Conscious Affirmations" then
    -- Send all affirmations as a single formatted message
    api.send_message(
      message.chat.id,
      get_all_affirmations_text(),
      nil,
      "markdown"
    )
  end
end

-- Handle callback queries (button presses)
function api.on_callback_query(callback_query)
  local data = callback_query.data
  local chat_id = callback_query.message.chat.id
  
  -- Check if the callback is for a meditation
  if data:match("^meditation_") then
    local meditation_index = tonumber(data:match("meditation_(%d+)"))
    local meditation = meditations[meditation_index]
    
    api.answer_callback_query(callback_query.id)
    
    -- Check if the file exists
    local file = io.open(meditation.file_path, "r")
    if not file then
      api.send_message(
        chat_id,
        "Sorry, the meditation file is not available at the moment.",
        nil,
        "markdown"
      )
      return
    end
    file:close()
    
    local success, result = pcall(function()
      return api.send_audio(
        chat_id,
        meditation.file_path,  -- Now sending the local file path
        nil,  -- duration
        nil,  -- performer
        meditation.title,  -- title
        nil,  -- disable_notification
        nil,  -- reply_to_message_id
        nil,  -- reply_markup
        meditation.title  -- caption
      )
    end)
    
    if not success then
      print("Error sending audio:", result)
      api.send_message(
        chat_id,
        "Sorry, there was an error playing this meditation. Error: " .. tostring(result),
        nil,
        "markdown"
      )
    end
  end
end

-- Start the bot
api.run()