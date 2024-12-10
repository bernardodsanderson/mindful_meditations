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

-- Function to get the main options inline keyboard
local function get_main_options_keyboard()
  return {
    inline_keyboard = {
      {
        {text = "🧘 Meditations", callback_data = "show_meditations"},
        {text = "✨ Conscious Affirmations", callback_data = "show_affirmations"}
      }
    }
  }
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
  elseif message.text == "/showaffirmations" then
    -- Send all affirmations as a single formatted message
    api.send_message(
      message.chat.id,
      get_all_affirmations_text(),
      nil,
      "markdown"
    )
    -- Show the main menu again
    api.send_message(
      message.chat.id,
      "Choose what you'd like to explore:",
      nil,
      "markdown",
      nil,
      nil,
      nil,
      nil,
      nil,
      get_main_options_keyboard()
    )
  elseif message.text == "/showmeditations" then
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

-- Handle callback queries (button presses)
function api.on_callback_query(callback_query)
  local data = callback_query.data
  local chat_id = callback_query.message.chat.id
  
  if data == "show_meditations" then
    api.answer_callback_query(callback_query.id)
    api.send_message(
      chat_id,
      "Choose a meditation to begin:",
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
  elseif data == "show_affirmations" then
    api.answer_callback_query(callback_query.id)
    -- Send all affirmations as a single formatted message
    api.send_message(
      chat_id,
      get_all_affirmations_text(),
      nil,
      "markdown"
    )
    -- Show the main menu again
    api.send_message(
      chat_id,
      "Choose what you'd like to explore:",
      nil,
      "markdown",
      nil,
      nil,
      nil,
      nil,
      nil,
      get_main_options_keyboard()
    )
  end
end

-- Start the bot
api.run()