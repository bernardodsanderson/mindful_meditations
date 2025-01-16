const telegram = window.Telegram.WebApp;

// Initialize the Web App
telegram.ready();

// Set the main button to expand to full size
telegram.expand();

// Configure theme
document.documentElement.style.setProperty('--tg-theme-button-color-rgb', hexToRgb(telegram.themeParams.button_color));

// Get DOM elements
const player = document.getElementById('meditation-player');
const playerSection = document.getElementById('player-section');
const nowPlaying = document.getElementById('now-playing');
const tabButtons = document.querySelectorAll('.tab-button');
const tabPanes = document.querySelectorAll('.tab-pane');

// Meditation data
const meditations = [
    {title: "Beyond 3 Bodies", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/beyond_3_bodies.mp3"},
    {title: "Conscious Visualization", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/conscious_visualization.mp3"},
    {title: "Holistic Abundance", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/holistic_abundance.mp3"},
    {title: "Morning Meditation on Brahman", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/morning_meditation_brahman.mp3"},
    {title: "Purusha Suktam - Vedic Meditation on the Cosmic Being", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/purusha_suktam.mp3"},
    {title: "Nididhyasana", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/nididhyasana.mp3"},
    {title: "Non-duality Experience", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/non_duality_experience.mp3"},
    {title: "Prana Vikshana", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/prana_vikshana.mp3"},
    {title: "Deep breathing", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/deep_breathing.mp3"},
    {title: "5 Minute Breathing", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/5_minute_breathing.mp3"},
    {title: "10 Minute Breathing", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/10_minute_breathing.mp3"},
    {title: "Nadi Shodhana", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/nadi_shodhana.mp3"},
    {title: "Soham Pranayama", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/soham_pranayama.mp3"},
    {title: "Ujjayi Pranayama", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/ujjayi_pranayama.mp3"},
    {title: "Trataka - Yogic Gazing", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/trataka.mp3"},
    {title: "Bhramari Pranayama", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/bhramari_pranayama.mp3"},
    {title: "Mantra Meditation", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/mantra.mp3"},
    {title: "Developing Concentration", file_path: "https://regal-entremet-b1420b.netlify.app/meditations/developing_concentration.mp3"}
];

// Affirmation data
const affirmations = [
    {
        category: "Health",
        text: "I am the infinite consciousness. The source of creation is within me and works for me. My body is now glowing with perfect health and wellbeing."
    },
    {
        category: "Wealth",
        text: "I am the limitless ocean of abundance, I am now experiencing unlimited flow of wealth and resources consistently."
    },
    {
        category: "Relationships",
        text: "I see myself in everyone and in everything. I radiate love towards all and I experience beautiful relationships."
    },
    {
        category: "Success",
        text: "I am limitless and I am now absolutely fulfilled. I experience success in all things and I am naturally lucky."
    },
    {
        category: "Spirituality",
        text: "I am living consciously and I create my life consciously. I'm knowing myself more and more everyday. I am now calm."
    }
];

// Initialize the app
function initApp() {
    renderMeditations();
    renderAffirmations();
    setupTabHandlers();
    
    // Set up player event listeners
    player.addEventListener('play', () => {
        telegram.expand(); // Ensure the window is expanded when playing
    });
    
    player.addEventListener('ended', () => {
        nowPlaying.textContent = 'Meditation completed 🙏';
    });
}

// Set up tab handlers
function setupTabHandlers() {
    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            const tabId = button.dataset.tab;
            switchTab(tabId);
        });
    });
}

// Switch tabs
function switchTab(tabId) {
    // Update buttons
    tabButtons.forEach(button => {
        button.classList.toggle('active', button.dataset.tab === tabId);
    });
    
    // Update panes
    tabPanes.forEach(pane => {
        pane.classList.toggle('active', pane.id === tabId);
    });
}

// Render meditation cards
function renderMeditations() {
    const meditationList = document.getElementById('meditation-list');
    meditationList.innerHTML = meditations.map((meditation, index) => `
        <div class="meditation-card" onclick="playMeditation(${index})">
            <h3>${meditation.title}</h3>
        </div>
    `).join('');
}

// Render affirmation cards
function renderAffirmations() {
    const affirmationList = document.getElementById('affirmation-list');
    affirmationList.innerHTML = affirmations.map(affirmation => `
        <div class="affirmation-card">
            <div class="category">${affirmation.category}</div>
            <div class="text">${affirmation.text}</div>
        </div>
    `).join('');
}

// Handle meditation playback
function playMeditation(index) {
    const meditation = meditations[index];
    
    // Update player
    player.src = meditation.file_path;
    nowPlaying.textContent = '🎵 Now Playing: ' + meditation.title;
    playerSection.style.display = 'block';
    
    // Scroll to player
    playerSection.scrollIntoView({ behavior: 'smooth' });
    
    // Start playing
    player.play().catch(error => {
        console.error('Error playing meditation:', error);
        nowPlaying.textContent = 'Error playing meditation. Please try again.';
    });
}

// Utility function to convert hex color to RGB
function hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? `${parseInt(result[1], 16)}, ${parseInt(result[2], 16)}, ${parseInt(result[3], 16)}` : '36, 129, 204';
}

// Initialize the app when the document is loaded
document.addEventListener('DOMContentLoaded', initApp); 